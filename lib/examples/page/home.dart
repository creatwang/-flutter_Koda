import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final dataList = const [
    {
      'q': '你喜欢什么颜色',
      'w': [
        {
          'label': '红色',
          'score': 5,
        },
        {
          'label': '红色',
          'score': 5,
        }
      ]
    },
    {
      'q': '你喜欢什么动物',
      'w': [
        {
          'label': '小猫',
          'score': 5,
        },
        {
          'label': '小狗',
          'score': 5,
        }
      ]
    },
    {
      'q': '1+1=？',
      'w': [
        {
          'label': '2',
          'score': 5,
        },
        {
          'label': '3',
          'score': 5,
        }
      ]
    }
  ];

  var count = 0;
  var total = 0;

  void reset() {
    setState(() {
      count = 0;
      total = 0;
    });
  }

  void next(int idx) {
    setState(() {
      count++;
      if (count >= dataList.length) return;
      total += (dataList[count]['w'] as List)[idx]['score'] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Expanded(
          child: Center(
            child: const Text(
              'home',
              textAlign: TextAlign.center,
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
        ),
      ),
      body: () {
        if (count < dataList.length) {
          return Column(
            children: [
              Text('第${count + 1}题-'),
              Container(
                alignment: Alignment.center,
                child: Text(dataList[count]['q'] as String),
              ),
              ...(dataList[count]['w'] as List).mapIndexed((index, val) {
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () => next(index),
                    child: Text(val['label']),
                  ),
                );
              })
            ],
          );
        } else {
          return Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Done'),
                    TextButton(onPressed: reset, child: const Text('重新答题'))
                  ],
                ),
                Text('总得分为$total')
              ],
            ),
          );
        }
      }(),
    );
  }
}
