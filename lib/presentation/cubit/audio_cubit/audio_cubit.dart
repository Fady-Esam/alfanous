import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/offline_audio_service.dart';
import '../../../core/services/settings_service.dart';
import 'audio_states.dart';

class AudioCubit extends Cubit<AudioState> {
  final OfflineAudioService _audioService;
  final SettingsService _settingsService;

  final int sura;
  final int aya;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<String?>? _playingIdSub;
  StreamSubscription<String?>? _deletionSub;

  AudioCubit({
    required this.sura,
    required this.aya,
    OfflineAudioService? audioService,
    SettingsService? settingsService,
  }) : _audioService = audioService ?? OfflineAudioService.instance,
      _settingsService = settingsService ?? SettingsService.instance,
      super(const AudioIdle(isDownloaded: false)) {
    _playingIdSub = _audioService.currentAudioIdStream.listen((playingId) {
      if (isClosed) return;
      if (playingId == '$sura:$aya') {
        _subscribeToPlayerState();
      } else {
        _cancelPlayerSub();

        if (state is AudioPlaying || state is AudioPaused) {
          emit(const AudioIdle(isDownloaded: true));
        }
      }
    });

    _deletionSub = _audioService.onDeletion.listen((deletedReciter) async {
      if (isClosed) return;
      if (deletedReciter == null) {
        await checkDownloaded();
      } else {
        final currentReciter = await _settingsService.getSelectedReciter();
        if (deletedReciter == currentReciter) {
          await checkDownloaded();
        }
      }
    });
  }

  Future<void> checkDownloaded() async {
    try {
      final reciter = await _settingsService.getSelectedReciter();
      final downloaded = await _audioService.isDownloaded(sura, aya, reciter);
      if (!isClosed) emit(AudioIdle(isDownloaded: downloaded));
    } catch (_) {
      if (!isClosed) emit(const AudioIdle(isDownloaded: false));
    }
  }

  Future<void> download() async {
    if (state is AudioDownloading) return;

    try {
      final reciter = await _settingsService.getSelectedReciter();

      await for (final progress in _audioService.download(sura, aya, reciter)) {
        if (isClosed) return;
        emit(AudioDownloading(progress: progress));
      }

      final exists = await _audioService.isDownloaded(sura, aya, reciter);
      if (!isClosed) emit(AudioIdle(isDownloaded: exists));
    } on AudioDownloadException catch (e) {
      if (!isClosed) {
        emit(AudioError(message: 'فشل التحميل: ${_friendlyError(e)}'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(AudioError(message: 'حدث خطأ غير متوقع أثناء التحميل.'));
      }
    }
  }

  Future<void> cancelDownload() async {
    _audioService.cancelDownload();
    await checkDownloaded();
  }

  Future<void> play() async {
    if (state is AudioPlaying) return;

    try {
      final reciter = await _settingsService.getSelectedReciter();

      await _audioService.play(sura, aya, reciter);
    } on AudioNotDownloadedException {
      if (!isClosed) {
        emit(
          const AudioError(
            message: 'الملف غير محمّل. اضغط على أيقونة التحميل أولاً.',
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(AudioError(message: 'تعذّر تشغيل الصوت: ${_friendlyError(e)}'));
      }
    }
  }

  Future<void> pause() => _audioService.pause();

  Future<void> resume() => _audioService.resume();

  Future<void> stop() async {
    await _audioService.stop();
  }

  void _subscribeToPlayerState() {
    _cancelPlayerSub();
    _playerStateSub = _audioService.playerStateStream.listen(
      (playerState) {
        if (isClosed) return;
        switch (playerState.processingState) {
          case ProcessingState.completed:
            _cancelPlayerSub();
            checkDownloaded();
          case ProcessingState.ready:
            if (playerState.playing) {
              emit(const AudioPlaying());
            } else {
              emit(const AudioPaused());
            }
          case ProcessingState.idle:
          case ProcessingState.loading:
          case ProcessingState.buffering:
            break;
        }
      },
      onError: (Object e) {
        if (!isClosed) {
          emit(AudioError(message: 'انقطع التشغيل: ${_friendlyError(e)}'));
        }
      },
    );
  }

  void _cancelPlayerSub() {
    _playerStateSub?.cancel();
    _playerStateSub = null;
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socket') || msg.contains('connect')) {
      return 'لا يوجد اتصال بالإنترنت.';
    }
    if (msg.contains('permission') || msg.contains('access')) {
      return 'لا توجد صلاحيات كافية للوصول إلى التخزين.';
    }
    if (msg.contains('disk') ||
        msg.contains('space') ||
        msg.contains('storage')) {
      return 'المساحة التخزينية غير كافية.';
    }
    return 'خطأ غير معروف.';
  }

  @override
  Future<void> close() {
    _playingIdSub?.cancel();
    _deletionSub?.cancel();
    _cancelPlayerSub();
    return super.close();
  }
}
