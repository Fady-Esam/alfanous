import 'package:equatable/equatable.dart';
import '../../../data/models/aya_model.dart';

sealed class SurahState extends Equatable {
  const SurahState();
}

final class SurahInitial extends SurahState {
  const SurahInitial();
  @override
  List<Object?> get props => [];
}

final class SurahLoading extends SurahState {
  final int suraId;
  const SurahLoading({required this.suraId});
  @override
  List<Object?> get props => [suraId];
}

final class SurahLoaded extends SurahState {
  final List<AyaModel> ayat;

  final int suraId;

  const SurahLoaded({required this.ayat, required this.suraId});

  @override
  List<Object?> get props => [suraId, ayat];
}

final class SurahError extends SurahState {
  final String message;
  final Object? exception;
  const SurahError({required this.message, this.exception});
  @override
  List<Object?> get props => [message];
}
