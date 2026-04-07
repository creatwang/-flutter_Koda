import 'package:flutter/material.dart';

class Textwrapper extends StatelessWidget {
  const Textwrapper({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
