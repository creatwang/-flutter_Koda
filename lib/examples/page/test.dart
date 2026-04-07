import 'package:flutter/material.dart';
import '../widget/text_wrapper.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    const c1 = Textwrapper(text: 'Apple');
    const c2 = Textwrapper(text: 'Apple');
    // ignore: avoid_print
    debugPrint('Textwrapper identical = ${identical(c1, c2)}');
    const a = Object();
    const b = Object();
    // ignore: avoid_print
    debugPrint('object identical = ${identical(a, b)}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('data'),
      ),
      body: const SizedBox(
        height: 200,
        child: Text('展示告诉你'),
      ),
    );
  }
}
