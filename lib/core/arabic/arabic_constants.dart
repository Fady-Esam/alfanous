library;

abstract final class ArabicConstants {
  static const String arabicComma = '\u060C';
  static const String semicolon = '\u061B';
  static const String question = '\u061F';
  static const String hamza = '\u0621';
  static const String alefMadda = '\u0622';
  static const String alefHamzaAbove = '\u0623';
  static const String wawHamza = '\u0624';
  static const String alefHamzaBelow = '\u0625';
  static const String yehHamza = '\u0626';
  static const String alef = '\u0627';
  static const String beh = '\u0628';
  static const String tehMarbuta = '\u0629';
  static const String teh = '\u062A';
  static const String theh = '\u062B';
  static const String jeem = '\u062C';
  static const String hah = '\u062D';
  static const String khah = '\u062E';
  static const String dal = '\u062F';
  static const String thal = '\u0630';
  static const String reh = '\u0631';
  static const String zain = '\u0632';
  static const String seen = '\u0633';
  static const String sheen = '\u0634';
  static const String sad = '\u0635';
  static const String dad = '\u0636';
  static const String tah = '\u0637';
  static const String zah = '\u0638';
  static const String ain = '\u0639';
  static const String ghain = '\u063A';
  static const String tatweel = '\u0640';
  static const String feh = '\u0641';
  static const String qaf = '\u0642';
  static const String kaf = '\u0643';
  static const String lam = '\u0644';
  static const String meem = '\u0645';
  static const String noon = '\u0646';
  static const String heh = '\u0647';
  static const String waw = '\u0648';
  static const String alefMaksura = '\u0649';
  static const String yeh = '\u064A';
  static const String maddaAbove = '\u0653';
  static const String hamzaAbove = '\u0654';
  static const String hamzaBelow = '\u0655';
  static const String fathatan = '\u064B';
  static const String dammatan = '\u064C';
  static const String kasratan = '\u064D';
  static const String fatha = '\u064E';
  static const String damma = '\u064F';
  static const String kasra = '\u0650';
  static const String shadda = '\u0651';
  static const String sukun = '\u0652';
  static const String miniAlef = '\u0670';
  static const String alefWasla = '\u0671';
  static const String smallAlef = '\u0670';
  static const String smallWaw = '\u06E5';
  static const String smallYeh = '\u06E6';
  static const String smallHighJeem = '\u06DA';
  static const String smallHighLigature = '\u06D6';
  static const String fullStop = '\u06D4';
  static const String byteOrderMark = '\uFEFF';
  static const String arabicZero = '\u0660';
  static const String arabicOne = '\u0661';
  static const String arabicTwo = '\u0662';
  static const String arabicThree = '\u0663';
  static const String arabicFour = '\u0664';
  static const String arabicFive = '\u0665';
  static const String arabicSix = '\u0666';
  static const String arabicSeven = '\u0667';
  static const String arabicEight = '\u0668';
  static const String arabicNine = '\u0669';
  static const String lamAlef = '\uFEFB';
  static const String lamAlefHamzaAbove = '\uFEF7';
  static const String lamAlefHamzaBelow = '\uFEF9';
  static const String lamAlefMaddaAbove = '\uFEF5';
  static const Set<String> tashkeel = {
    fathatan,
    dammatan,
    kasratan,
    fatha,
    damma,
    kasra,
    shadda,
    sukun,
  };

  static const Set<String> harakat = {
    fathatan,
    dammatan,
    kasratan,
    fatha,
    damma,
    kasra,
    sukun,
  };

  static const Set<String> shortHarakat = {fatha, damma, kasra, sukun};
  static const Set<String> tanwin = {fathatan, dammatan, kasratan};
  static const Set<String> ligatures = {
    lamAlef,
    lamAlefHamzaAbove,
    lamAlefHamzaBelow,
    lamAlefMaddaAbove,
  };

  static const Set<String> hamzat = {
    hamza,
    wawHamza,
    yehHamza,
    hamzaAbove,
    hamzaBelow,
    alefHamzaBelow,
    alefHamzaAbove,
  };

  static const Set<String> alefat = {
    alef,
    alefMadda,
    alefHamzaAbove,
    alefHamzaBelow,
    alefWasla,
    alefMaksura,
    smallAlef,
  };

  static const Set<String> weak = {alef, waw, yeh, alefMaksura};
  static const Set<String> yehLike = {yeh, yehHamza, alefMaksura, smallYeh};
  static const Set<String> wawLike = {waw, wawHamza, smallWaw};
  static const Set<String> tehLike = {teh, tehMarbuta};
  static const Set<String> small = {smallAlef, smallWaw, smallYeh};

  static const String letters =
      '\u0627\u0628\u0629\u062A\u062B\u062C\u062D\u062E'
      '\u062F\u0630\u0631\u0632\u0633\u0634\u0635\u0636'
      '\u0637\u0638\u0639\u063A\u0641\u0642\u0643\u0644'
      '\u0645\u0646\u0647\u0648\u064A'
      '\u0621\u0622\u0623\u0624\u0625\u0626';

  static const Map<String, int> alphabeticOrder = {
    alef: 1,
    beh: 2,
    teh: 3,
    tehMarbuta: 3,
    theh: 4,
    jeem: 5,
    hah: 6,
    khah: 7,
    dal: 8,
    thal: 9,
    reh: 10,
    zain: 11,
    seen: 12,
    sheen: 13,
    sad: 14,
    dad: 15,
    tah: 16,
    zah: 17,
    ain: 18,
    ghain: 19,
    feh: 20,
    qaf: 21,
    kaf: 22,
    lam: 23,
    meem: 24,
    noon: 25,
    heh: 26,
    waw: 27,
    yeh: 28,
    hamza: 29,
    alefMadda: 29,
    alefHamzaAbove: 29,
    wawHamza: 29,
    alefHamzaBelow: 29,
    yehHamza: 29,
  };

  static const Map<String, String> letterNames = {
    alef: 'ألف',
    beh: 'باء',
    teh: 'تاء',
    tehMarbuta: 'تاء مربوطة',
    theh: 'ثاء',
    jeem: 'جيم',
    hah: 'حاء',
    khah: 'خاء',
    dal: 'دال',
    thal: 'ذال',
    reh: 'راء',
    zain: 'زاي',
    seen: 'سين',
    sheen: 'شين',
    sad: 'صاد',
    dad: 'ضاد',
    tah: 'طاء',
    zah: 'ظاء',
    ain: 'عين',
    ghain: 'غين',
    feh: 'فاء',
    qaf: 'قاف',
    kaf: 'كاف',
    lam: 'لام',
    meem: 'ميم',
    noon: 'نون',
    heh: 'هاء',
    waw: 'واو',
    yeh: 'ياء',
    hamza: 'همزة',
    tatweel: 'تطويل',
    alefMadda: 'ألف ممدودة',
    alefMaksura: 'ألف مقصورة',
    alefHamzaAbove: 'همزة على الألف',
    wawHamza: 'همزة على الواو',
    alefHamzaBelow: 'همزة تحت الألف',
    yehHamza: 'همزة على الياء',
    fathatan: 'فتحتان',
    dammatan: 'ضمتان',
    kasratan: 'كسرتان',
    fatha: 'فتحة',
    damma: 'ضمة',
    kasra: 'كسرة',
    shadda: 'شدة',
    sukun: 'سكون',
  };
}
