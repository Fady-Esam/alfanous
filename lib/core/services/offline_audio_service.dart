import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AudioNotDownloadedException implements Exception {
  final String message;
  const AudioNotDownloadedException(this.message);
  @override
  String toString() => 'AudioNotDownloadedException: $message';
}

class AudioDownloadException implements Exception {
  final String message;
  final Object? cause;
  const AudioDownloadException(this.message, [this.cause]);
  @override
  String toString() => 'AudioDownloadException: $message (cause: $cause)';
}

class OfflineAudioService {
  static final OfflineAudioService instance = OfflineAudioService._();
  OfflineAudioService._() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _currentAudioIdCtrl.add(null);
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final _currentAudioIdCtrl = StreamController<String?>.broadcast();
  final _deletionController = StreamController<String?>.broadcast();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 5),
      followRedirects: true,
      maxRedirects: 3,
    ),
  );

  CancelToken? _cancelToken;

  static const String _baseUrl = 'https://everyayah.com/data';

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<String?> get currentAudioIdStream => _currentAudioIdCtrl.stream;

  Stream<String?> get onDeletion => _deletionController.stream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;
  String audioUrlFor(int sura, int aya, String reciter) {
    final file =
        '${sura.toString().padLeft(3, '0')}'
        '${aya.toString().padLeft(3, '0')}.mp3';
    return '$_baseUrl/$reciter/$file';
  }

  Future<String> localPathFor(int sura, int aya, String reciter) async {
    final appDir = await getApplicationDocumentsDirectory();
    final suraDir = sura.toString().padLeft(3, '0');
    final ayaFile = '${aya.toString().padLeft(3, '0')}.mp3';
    return p.join(appDir.path, 'audio', reciter, suraDir, ayaFile);
  }

  Future<bool> isDownloaded(int sura, int aya, String reciter) async {
    final path = await localPathFor(sura, aya, reciter);
    return File(path).exists();
  }

  Stream<double> download(int sura, int aya, String reciter) async* {
    _cancelToken?.cancel('New download started');
    _cancelToken = CancelToken();

    final url = audioUrlFor(sura, aya, reciter);
    final localPath = await localPathFor(sura, aya, reciter);

    if (await File(localPath).exists()) {
      yield 1.0;
      return;
    }

    try {
      await Directory(p.dirname(localPath)).create(recursive: true);
    } catch (e) {
      throw AudioDownloadException(
        'Failed to create directory. Storage might be full.',
        e,
      );
    }

    final controller = StreamController<double>();

    final future = _dio
        .download(
          url,
          localPath,
          cancelToken: _cancelToken,
          onReceiveProgress: (received, total) {
            if (total > 0 && !controller.isClosed) {
              controller.add(received / total);
            }
          },
          deleteOnError: true,
        )
        .then((_) {
          if (!controller.isClosed) {
            controller.add(1.0);
            controller.close();
          }
        })
        .catchError((Object e) {
          if (!controller.isClosed) {
            if (e is DioException && e.type == DioExceptionType.cancel) {
              controller.close();
            } else {
              controller.addError(
                AudioDownloadException('Download failed for $url', e),
              );
              controller.close();
            }
          }
          if (e is! DioException || e.type != DioExceptionType.cancel) {
            File(localPath).exists().then((exists) {
              if (exists) File(localPath).delete().ignore();
            });
          }
        });

    yield* controller.stream;

    await future;
  }

  void cancelDownload() {
    _cancelToken?.cancel('User cancelled');
    _cancelToken = null;
  }

  Future<void> play(int sura, int aya, String reciter) async {
    final localPath = await localPathFor(sura, aya, reciter);

    if (!await File(localPath).exists()) {
      throw AudioNotDownloadedException(
        'Audio not on disk: sura=$sura aya=$aya reciter=$reciter. '
        'Call download() first.',
      );
    }

    _currentAudioIdCtrl.add('$sura:$aya');
    await _player.stop();

    try {
      await _player.setAudioSource(AudioSource.uri(Uri.file(localPath)));
      await _player.play();
    } catch (e) {
      _currentAudioIdCtrl.add(null);
      rethrow;
    }
  }

  Future<void> pause() => _player.pause();

  Future<void> resume() => _player.play();

  Future<void> stop() async {
    _currentAudioIdCtrl.add(null);
    await _player.stop();
  }

  Future<void> dispose() async {
    _cancelToken?.cancel('Service disposed');
    _cancelToken = null;
    await _player.dispose();
    await _currentAudioIdCtrl.close();
    await _deletionController.close();
    _dio.close(force: true);
  }

  Future<int> calculateReciterSize(String reciter) async {
    final appDir = await getApplicationDocumentsDirectory();
    final reciterDir = Directory(p.join(appDir.path, 'audio', reciter));
    if (!await reciterDir.exists()) return 0;

    int totalSize = 0;
    try {
      await for (final file in reciterDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    } catch (e) {
      debugPrint(
        '[OfflineAudioService] Error calculating size for $reciter: $e',
      );
    }
    return totalSize;
  }

  Future<int> totalDownloadedBytes() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, 'audio'));
    if (!await audioDir.exists()) return 0;

    int total = 0;
    await for (final entity in audioDir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<void> clearReciter(String reciter) async {
    final appDir = await getApplicationDocumentsDirectory();
    final reciterDir = Directory(p.join(appDir.path, 'audio', reciter));
    if (await reciterDir.exists()) {
      await reciterDir.delete(recursive: true);
      debugPrint('[OfflineAudioService] Cleared cache for reciter: $reciter');
      _deletionController.add(reciter);
    }
  }

  Future<void> clearAll() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, 'audio'));
    if (await audioDir.exists()) {
      await audioDir.delete(recursive: true);
      debugPrint('[OfflineAudioService] Cleared entire audio cache.');
      _deletionController.add(null);
    }
  }
}
