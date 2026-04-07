import 'package:flutter/material.dart';

typedef AddOrderCallback = void Function({
  required TextEditingController nameInputStr,
  required TextEditingController moneyInputStr,
});

class OrderDialog extends StatefulWidget {
  const OrderDialog({super.key, required this.addOrder});

  final AddOrderCallback addOrder;

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  final TextEditingController nameInputStr = TextEditingController();
  final TextEditingController moneyInputStr = TextEditingController();

  @override
  void dispose() {
    nameInputStr.dispose();
    moneyInputStr.dispose();
    super.dispose();
  }

  void reset() {
    nameInputStr.clear();
    moneyInputStr.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            const Text(
              '添加',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameInputStr,
              decoration: const InputDecoration(label: Text('名字')),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: moneyInputStr,
              decoration: const InputDecoration(labelText: '金额'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameInputStr.text.isEmpty || moneyInputStr.text.isEmpty) {
                  return showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('提示'),
                      content: const Text('不可以为空？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  );
                }
                widget.addOrder(
                  moneyInputStr: moneyInputStr,
                  nameInputStr: nameInputStr,
                );
                Navigator.pop(context);
                reset();
              },
              child: const Text('新增'),
            )
          ],
        ),
      ),
    );
  }
}
