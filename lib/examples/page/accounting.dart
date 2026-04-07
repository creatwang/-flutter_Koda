import 'package:flutter/material.dart';
import '../module/order.dart';
import '../widget/bar.dart';
import '../widget/order_dialog.dart';
import '../widget/order_preview.dart';

class Accounting extends StatefulWidget {
  const Accounting({super.key});

  @override
  State<Accounting> createState() => _AccountingState();
}

class _AccountingState extends State<Accounting> {
  late List<Order> orderList;

  @override
  void initState() {
    super.initState();
    orderList = List.generate(20, (index) {
      return Order(
        time: DateTime.now().subtract(Duration(hours: index)),
        name: '订单 #$index',
        money: 100.0 + index,
      );
    });
  }

  void addOrder({
    required TextEditingController nameInputStr,
    required TextEditingController moneyInputStr,
  }) {
    orderList.add(
      Order(
        time: DateTime.now(),
        name: nameInputStr.text,
        money: double.tryParse(moneyInputStr.text) ?? 0.0,
      ),
    );
    setState(() {});
  }

  void deleteOrder(int index) {
    orderList.removeAt(index);
    setState(() {});
  }

  double get maxPrice {
    if (orderList.isEmpty) return 0;
    return orderList.fold(0.0, (max, e) => e.money > max ? e.money : max);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记账功能'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            builder: (_) {
              return OrderDialog(addOrder: addOrder);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemCount: orderList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  final price = orderList[index].money / maxPrice;
                  return Bar(
                    p: double.parse(price.toStringAsFixed(2)),
                    s: orderList[index].money.toString(),
                  );
                },
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Card(
              color: Colors.amberAccent,
              elevation: 4,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: orderList.length,
                itemBuilder: (_, index) {
                  return OrderPreview(
                    order: orderList[index],
                    deleteOrder: () => deleteOrder(index),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
