import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class StatefulRichText extends StatefulWidget {

  final AutoSizeText richText;
  const StatefulRichText({super.key, required this.richText});

  @override
  State<StatefulRichText> createState() {
    return _StatefulRichTextState();
  }
}

class _StatefulRichTextState extends State<StatefulRichText> {
  @override
  Widget build(BuildContext context) {
    return widget.richText;
  }
}