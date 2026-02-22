library;

abstract final class ArabicNormalizer {
  static final RegExp _tashkeelPattern = RegExp(
    r'[\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652]',
    unicode: true,
  );

  static final RegExp _harakatPattern = RegExp(
    r'[\u064B\u064C\u064D\u064E\u064F\u0650\u0652]',
    unicode: true,
  );

  static final RegExp _tatweelPattern = RegExp(r'\u0640', unicode: true);

  static final RegExp _alefatPattern = RegExp(
    r'[\u0622\u0623\u0625\u0671]',
    unicode: true,
  );

  static final RegExp _hamzatPattern = RegExp(r'[\u0624\u0626]', unicode: true);

  static final RegExp _lamAlefPattern = RegExp(
    r'[\uFEF5\uFEF7\uFEF9\uFEFB]',
    unicode: true,
  );

  static final RegExp _uthmaniSymbolsPattern = RegExp(
    r'[\u0670\u06DC\u06DF\u06E0\u06E2\u06E3\u06E5\u06E6\u06E8\u06EA\u06EB\u06EC\u06ED]',
    unicode: true,
  );

  static String stripTashkeel(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll(_tashkeelPattern, '');
  }

  static String stripHarakat(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll(_harakatPattern, '');
  }

  static String stripShadda(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll('\u0651', '');
  }

  static String stripTatweel(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll(_tatweelPattern, '');
  }

  static String normalizeHamza(String text) {
    if (text.isEmpty) return text;

    return text
        .replaceAll(_alefatPattern, '\u0627')
        .replaceAll(_hamzatPattern, '\u0621');
  }

  static String normalizeLamAlef(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll(_lamAlefPattern, '\u0644\u0627');
  }

  static String normalizeSpellerrors(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll('\u0629', '\u0647').replaceAll('\u0649', '\u064A');
  }

  static String normalizeUthmaniSymbols(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll('\u0671', '\u0627')
        .replaceAll(_uthmaniSymbolsPattern, '');
  }

  static String normalize(String text) {
    if (text.isEmpty) return text;
    text = normalizeLamAlef(text);
    text = stripTatweel(text);
    text = stripTashkeel(text);
    text = normalizeHamza(text);
    text = normalizeSpellerrors(text);
    return text;
  }

  static String normalizeUthmani(String text) {
    if (text.isEmpty) return text;
    text = normalizeUthmaniSymbols(text);
    text = normalizeLamAlef(text);
    text = stripTatweel(text);
    text = stripTashkeel(text);
    text = normalizeHamza(text);
    text = normalizeSpellerrors(text);
    return text;
  }
}
