library;

import 'package:flutter/material.dart';

import '../../../core/arabic/arabic_normalizer.dart';

class DiacriticHighlightText extends StatelessWidget {
  final String originalText;

  final List<String> highlightTerms;

  final TextStyle baseStyle;

  final TextStyle highlightStyle;

  final TextDirection textDirection;

  const DiacriticHighlightText({
    super.key,
    required this.originalText,
    required this.highlightTerms,
    required this.baseStyle,
    required this.highlightStyle,
    this.textDirection = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    if (originalText.isEmpty || highlightTerms.isEmpty) {
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

    final (shadow, normToOrig) = _buildNormShadow(displayText);

    if (shadow.isEmpty) {
      return [TextSpan(text: displayText, style: baseStyle)];
    }

    final intervals = <(int, int)>[];

    for (final term in highlightTerms) {
      if (term.isEmpty) continue;

      final normTerm = ArabicNormalizer.normalizeQuery(term);
      if (normTerm.isEmpty) continue;

      final searchTerm = normTerm.endsWith('*')
          ? normTerm.substring(0, normTerm.length - 1)
          : normTerm;

      final pattern = RegExp(
        RegExp.escape(searchTerm),
        unicode: true,
        caseSensitive: false,
      );

      for (final m in pattern.allMatches(shadow)) {
        final origStart = normToOrig[m.start];

        final origEnd = m.end < normToOrig.length
            ? normToOrig[m.end]
            : displayText.length;
        if (origStart < origEnd) {
          intervals.add((origStart, origEnd));
        }
      }
    }

    if (intervals.isEmpty) {
      return [TextSpan(text: displayText, style: baseStyle)];
    }

    intervals.sort((a, b) => a.$1.compareTo(b.$1));
    final merged = _mergeIntervals(intervals);

    final spans = <TextSpan>[];
    int cursor = 0;

    for (final (start, end) in merged) {
      if (start > cursor) {
        spans.add(
          TextSpan(
            text: displayText.substring(cursor, start),
            style: baseStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: displayText.substring(start, end),
          style: highlightStyle,
        ),
      );
      cursor = end;
    }

    if (cursor < displayText.length) {
      spans.add(
        TextSpan(text: displayText.substring(cursor), style: baseStyle),
      );
    }

    return spans;
  }

  (String, List<int>) _buildNormShadow(String text) {
    final shadowBuf = StringBuffer();
    final normToOrig = <int>[];

    for (var oi = 0; oi < text.length; oi++) {
      final ch = text[oi];
      final cp = ch.codeUnitAt(0);

      if (cp >= 0x064B && cp <= 0x0652) continue;

      if (cp == 0x0670) continue;

      if (cp == 0x0640) continue;

      if (cp == 0x06DC || (cp >= 0x06DF && cp <= 0x06ED)) continue;

      if (cp == 0x06E5 || cp == 0x06E6) continue;

      if (cp == 0xFEF5 || cp == 0xFEF7 || cp == 0xFEF9 || cp == 0xFEFB) {
        shadowBuf.write('\u0644\u0627');
        normToOrig.add(oi);
        normToOrig.add(oi);
        continue;
      }

      if (cp == 0x0671) {
        shadowBuf.write('\u0627');
        normToOrig.add(oi);
        continue;
      }

      if (cp == 0x0622 || cp == 0x0623 || cp == 0x0625) {
        shadowBuf.write('\u0627');
        normToOrig.add(oi);
        continue;
      }

      if (cp == 0x0624 || cp == 0x0626) {
        shadowBuf.write('\u0621');
        normToOrig.add(oi);
        continue;
      }

      if (cp == 0x0629) {
        shadowBuf.write('\u0647');
        normToOrig.add(oi);
        continue;
      }

      if (cp == 0x0649) {
        shadowBuf.write('\u064A');
        normToOrig.add(oi);
        continue;
      }

      shadowBuf.write(ch);
      normToOrig.add(oi);
    }

    normToOrig.add(text.length);

    return (shadowBuf.toString(), normToOrig);
  }

  List<(int, int)> _mergeIntervals(List<(int, int)> sorted) {
    final merged = <(int, int)>[];
    var (curStart, curEnd) = sorted.first;

    for (var i = 1; i < sorted.length; i++) {
      final (s, e) = sorted[i];
      if (s <= curEnd) {
        curEnd = curEnd > e ? curEnd : e;
      } else {
        merged.add((curStart, curEnd));
        curStart = s;
        curEnd = e;
      }
    }
    merged.add((curStart, curEnd));
    return merged;
  }
}
