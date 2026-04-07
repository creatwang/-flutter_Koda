import 'package:flutter/material.dart';

class Bar extends StatelessWidget {
  const Bar({super.key, this.p = 0.0, this.s = '0'});

  final double p;
  final String s;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: p,
                widthFactor: 1.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.amberAccent,
                      ),
                    ),
                    Positioned(
                      width: 40,
                      top: -18,
                      child: Center(
                        child: FittedBox(
                          child: Text("${p * 100}%"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Text(s)
      ],
    );
  }
}
