import 'package:equatable/equatable.dart';

sealed class AudioState extends Equatable {
  const AudioState();
}

final class AudioIdle extends AudioState {
  final bool isDownloaded;
  const AudioIdle({required this.isDownloaded});

  @override
  List<Object?> get props => [isDownloaded];
}

final class AudioDownloading extends AudioState {
  final double progress;

  const AudioDownloading({required this.progress});

  @override
  List<Object?> get props => [progress];
}

final class AudioPlaying extends AudioState {
  const AudioPlaying();

  @override
  List<Object?> get props => [];
}

final class AudioPaused extends AudioState {
  const AudioPaused();

  @override
  List<Object?> get props => [];
}

final class AudioError extends AudioState {
  final String message;
  const AudioError({required this.message});

  @override
  List<Object?> get props => [message];
}
