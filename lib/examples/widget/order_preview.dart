import 'package:flutter/material.dart';
import '../module/order.dart';

class OrderPreview extends StatelessWidget {
  const OrderPreview({super.key, required this.order, required this.deleteOrder});

  final Order order;
  final void Function() deleteOrder;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(order.money.toString()),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(order.time.toString()),
            ],
          ),
        ),
        IconButton(
          onPressed: deleteOrder,
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
