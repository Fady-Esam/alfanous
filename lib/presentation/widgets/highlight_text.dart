library;

import 'package:flutter/material.dart';

import '../../core/arabic/arabic_normalizer.dart';

class HighlightText extends StatelessWidget {
  final String originalText;

  final String searchQuery;

  final TextStyle baseStyle;

  final TextStyle highlightStyle;

  final TextDirection textDirection;

  const HighlightText({
    super.key,
    required this.originalText,
    required this.searchQuery,
    required this.baseStyle,
    required this.highlightStyle,
    this.textDirection = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isEmpty || originalText.isEmpty) {
      return Text(originalText, style: baseStyle, textDirection: textDirection);
    }

    final spans = _buildSpans();

    if (spans.length == 1 && spans.first.style == baseStyle) {
      return Text(originalText, style: baseStyle, textDirection: textDirection);
    }

    return RichText(
      text: TextSpan(children: spans),
      textDirection: textDirection,
    );
  }

  List<TextSpan> _buildSpans() {
    final displayText = ArabicNormalizer.fixJalalaHighlighting(originalText);

    final normQuery = ArabicNormalizer.normalizeQuery(searchQuery.trim());
    if (normQuery.isEmpty) {
      return [TextSpan(text: originalText, style: baseStyle)];
    }

    final (normShadow, normToOrig) = _buildNormMap(displayText);

    if (normShadow.isEmpty) {
      return [TextSpan(text: originalText, style: baseStyle)];
    }

    final queryRe = RegExp(
      RegExp.escape(normQuery),
      caseSensitive: false,
      unicode: true,
    );

    final intervals = <(int, int)>[];
    for (final m in queryRe.allMatches(normShadow)) {
      final origStart = normToOrig[m.start];

      final origEnd = m.end < normToOrig.length
          ? normToOrig[m.end]
          : displayText.length;
      intervals.add((origStart, origEnd));
    }

    if (intervals.isEmpty) {
      return [TextSpan(text: originalText, style: baseStyle)];
    }

    final spans = <TextSpan>[];
    int cursor = 0;
    for (final (start, end) in intervals) {
      if (start > cursor) {
        spans.add(
          TextSpan(
            text: originalText.substring(cursor, start),
            style: baseStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: originalText.substring(start, end),
          style: highlightStyle,
        ),
      );
      cursor = end;
    }

    if (cursor < originalText.length) {
      spans.add(
        TextSpan(text: originalText.substring(cursor), style: baseStyle),
      );
    }

    return spans;
  }

  (String, List<int>) _buildNormMap(String text) {
    final shadow = StringBuffer();
    final normToOrig = <int>[];

    for (int i = 0; i < text.length; i++) {
      final ch = text[i];

      if (_isTashkeel(ch)) continue;

      if (ch == '\u0670') continue;

      if (ch == '\u0640') continue;

      if (_isUthmaniDecoration(ch)) continue;

      if (_isLamAlefLigature(ch)) {
        shadow.write('\u0644\u0627');
        normToOrig.add(i);
        normToOrig.add(i);
        continue;
      }

      if (_isAlefVariant(ch)) {
        shadow.write('\u0627');
        normToOrig.add(i);
        continue;
      }

      if (ch == '\u0624' || ch == '\u0626') {
        shadow.write('\u0621');
        normToOrig.add(i);
        continue;
      }

      if (ch == '\u0629') {
        shadow.write('\u0647');
        normToOrig.add(i);
        continue;
      }

      if (ch == '\u0649') {
        shadow.write('\u064A');
        normToOrig.add(i);
        continue;
      }

      shadow.write(ch);
      normToOrig.add(i);
    }

    normToOrig.add(text.length);

    return (shadow.toString(), normToOrig);
  }

  static bool _isTashkeel(String ch) {
    final cp = ch.codeUnitAt(0);
    return cp >= 0x064B && cp <= 0x0652;
  }

  static bool _isUthmaniDecoration(String ch) {
    final cp = ch.codeUnitAt(0);
    return cp == 0x06DC || (cp >= 0x06DF && cp <= 0x06ED);
  }

  static bool _isLamAlefLigature(String ch) {
    final cp = ch.codeUnitAt(0);
    return cp == 0xFEF5 || cp == 0xFEF7 || cp == 0xFEF9 || cp == 0xFEFB;
  }

  static bool _isAlefVariant(String ch) {
    final cp = ch.codeUnitAt(0);
    return cp == 0x0622 || cp == 0x0623 || cp == 0x0625 || cp == 0x0671;
  }
}
