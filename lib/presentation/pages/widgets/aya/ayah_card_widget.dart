import 'package:flutter/material.dart';
import '../../../../data/models/aya_model.dart';
import 'card_body.dart';

class AyahCardWidget extends StatelessWidget {
  final AyaModel aya;

  final List<String> highlightTerms;

  final bool isHighlight;

  const AyahCardWidget({
    super.key,
    required this.aya,
    this.highlightTerms = const [],
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return CardBody(
      aya: aya,
      highlightTerms: highlightTerms,
      isHighlight: isHighlight,
    );
  }
}




