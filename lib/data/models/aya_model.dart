library;

import 'package:equatable/equatable.dart';

class AyaModel extends Equatable {
  final int gid;

  final int suraId;

  final int ayaId;

  final String standard;

  final String standardFull;

  final String? uthmani;

  final String? uthmaniMin;

  final String? chapter;

  final String? topic;

  final String? subtopic;

  final String? subject;

  final int? juzId;
  final int? hizbId;
  final int? rubId;
  final int? nisfId;
  final int? pageId;
  final int? pageIdIndian;
  final int? rukuId;
  final int? manzilId;

  final String? sajda;
  final int? sajdaId;

  final String? sajdaType;

  final int? suraOrder;

  final String? suraName;

  final String? suraNameEn;

  final String? suraNameRomanization;

  final String? suraType;

  final String? suraTypeEn;

  final int? suraAyasNb;
  final int? suraWordsNb;
  final int? suraLettersNb;
  final int? suraRukusNb;

  final int? ayaWordsNb;
  final int? ayaLettersNb;

  const AyaModel({
    required this.gid,
    required this.suraId,
    required this.ayaId,
    required this.standard,
    required this.standardFull,
    this.uthmani,
    this.uthmaniMin,
    this.chapter,
    this.topic,
    this.subtopic,
    this.subject,
    this.juzId,
    this.hizbId,
    this.rubId,
    this.nisfId,
    this.pageId,
    this.pageIdIndian,
    this.rukuId,
    this.manzilId,
    this.sajda,
    this.sajdaId,
    this.sajdaType,
    this.suraOrder,
    this.suraName,
    this.suraNameEn,
    this.suraNameRomanization,
    this.suraType,
    this.suraTypeEn,
    this.suraAyasNb,
    this.suraWordsNb,
    this.suraLettersNb,
    this.suraRukusNb,
    this.ayaWordsNb,
    this.ayaLettersNb,
  });

  factory AyaModel.fromMap(Map<String, dynamic> map) {
    return AyaModel(
      gid: map['gid'] as int,
      suraId: map['sura_id'] as int,
      ayaId: map['aya_id'] as int,
      standard: map['standard'] as String? ?? '',
      standardFull: map['standard_full'] as String? ?? '',
      uthmani: map['uthmani'] as String?,
      uthmaniMin: map['uthmani_min'] as String?,
      chapter: map['chapter'] as String?,
      topic: map['topic'] as String?,
      subtopic: map['subtopic'] as String?,
      subject: map['subject'] as String?,
      juzId: map['juz_id'] as int?,
      hizbId: map['hizb_id'] as int?,
      rubId: map['rub_id'] as int?,
      nisfId: map['nisf_id'] as int?,
      pageId: map['page_id'] as int?,
      pageIdIndian: map['page_id_indian'] as int?,
      rukuId: map['ruku_id'] as int?,
      manzilId: map['manzil_id'] as int?,
      sajda: map['sajda'] as String?,
      sajdaId: map['sajda_id'] as int?,
      sajdaType: map['sajda_type'] as String?,
      suraOrder: map['sura_order'] as int?,
      suraName: map['sura_name'] as String?,
      suraNameEn: map['sura_name_en'] as String?,
      suraNameRomanization: map['sura_name_romanization'] as String?,
      suraType: map['sura_type'] as String?,
      suraTypeEn: map['sura_type_en'] as String?,
      suraAyasNb: map['sura_ayas_nb'] as int?,
      suraWordsNb: map['sura_words_nb'] as int?,
      suraLettersNb: map['sura_letters_nb'] as int?,
      suraRukusNb: map['sura_rukus_nb'] as int?,
      ayaWordsNb: map['aya_words_nb'] as int?,
      ayaLettersNb: map['aya_letters_nb'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gid': gid,
      'sura_id': suraId,
      'aya_id': ayaId,
      'standard': standard,
      'standard_full': standardFull,
      'uthmani': uthmani,
      'uthmani_min': uthmaniMin,
      'chapter': chapter,
      'topic': topic,
      'subtopic': subtopic,
      'subject': subject,
      'juz_id': juzId,
      'hizb_id': hizbId,
      'rub_id': rubId,
      'nisf_id': nisfId,
      'page_id': pageId,
      'page_id_indian': pageIdIndian,
      'ruku_id': rukuId,
      'manzil_id': manzilId,
      'sajda': sajda,
      'sajda_id': sajdaId,
      'sajda_type': sajdaType,
      'sura_order': suraOrder,
      'sura_name': suraName,
      'sura_name_en': suraNameEn,
      'sura_name_romanization': suraNameRomanization,
      'sura_type': suraType,
      'sura_type_en': suraTypeEn,
      'sura_ayas_nb': suraAyasNb,
      'sura_words_nb': suraWordsNb,
      'sura_letters_nb': suraLettersNb,
      'sura_rukus_nb': suraRukusNb,
      'aya_words_nb': ayaWordsNb,
      'aya_letters_nb': ayaLettersNb,
    };
  }

  AyaModel copyWith({
    int? gid,
    int? suraId,
    int? ayaId,
    String? standard,
    String? standardFull,
    String? uthmani,
    String? uthmaniMin,
    String? chapter,
    String? topic,
    String? subtopic,
    String? subject,
    int? juzId,
    int? hizbId,
    int? rubId,
    int? nisfId,
    int? pageId,
    int? pageIdIndian,
    int? rukuId,
    int? manzilId,
    String? sajda,
    int? sajdaId,
    String? sajdaType,
    int? suraOrder,
    String? suraName,
    String? suraNameEn,
    String? suraNameRomanization,
    String? suraType,
    String? suraTypeEn,
    int? suraAyasNb,
    int? suraWordsNb,
    int? suraLettersNb,
    int? suraRukusNb,
    int? ayaWordsNb,
    int? ayaLettersNb,
  }) {
    return AyaModel(
      gid: gid ?? this.gid,
      suraId: suraId ?? this.suraId,
      ayaId: ayaId ?? this.ayaId,
      standard: standard ?? this.standard,
      standardFull: standardFull ?? this.standardFull,
      uthmani: uthmani ?? this.uthmani,
      uthmaniMin: uthmaniMin ?? this.uthmaniMin,
      chapter: chapter ?? this.chapter,
      topic: topic ?? this.topic,
      subtopic: subtopic ?? this.subtopic,
      subject: subject ?? this.subject,
      juzId: juzId ?? this.juzId,
      hizbId: hizbId ?? this.hizbId,
      rubId: rubId ?? this.rubId,
      nisfId: nisfId ?? this.nisfId,
      pageId: pageId ?? this.pageId,
      pageIdIndian: pageIdIndian ?? this.pageIdIndian,
      rukuId: rukuId ?? this.rukuId,
      manzilId: manzilId ?? this.manzilId,
      sajda: sajda ?? this.sajda,
      sajdaId: sajdaId ?? this.sajdaId,
      sajdaType: sajdaType ?? this.sajdaType,
      suraOrder: suraOrder ?? this.suraOrder,
      suraName: suraName ?? this.suraName,
      suraNameEn: suraNameEn ?? this.suraNameEn,
      suraNameRomanization: suraNameRomanization ?? this.suraNameRomanization,
      suraType: suraType ?? this.suraType,
      suraTypeEn: suraTypeEn ?? this.suraTypeEn,
      suraAyasNb: suraAyasNb ?? this.suraAyasNb,
      suraWordsNb: suraWordsNb ?? this.suraWordsNb,
      suraLettersNb: suraLettersNb ?? this.suraLettersNb,
      suraRukusNb: suraRukusNb ?? this.suraRukusNb,
      ayaWordsNb: ayaWordsNb ?? this.ayaWordsNb,
      ayaLettersNb: ayaLettersNb ?? this.ayaLettersNb,
    );
  }

  @override
  List<Object?> get props => [gid];

  @override
  String toString() =>
      'AyaModel(gid: $gid, sura: $suraId:$ayaId '
      '[${suraNameEn ?? suraName ?? "?"}], '
      'text: "${standard.length > 30 ? '${standard.substring(0, 30)}…' : standard}")';
}
