import 'package:flutter/material.dart';
import '../module/router.dart';

class CustomMenu extends StatelessWidget {
  const CustomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: routerList.map((el) {
        return Center(
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => el.widget),
              );
            },
            child: Text(el.label),
          ),
        );
      }).toList(),
    );
  }
}
