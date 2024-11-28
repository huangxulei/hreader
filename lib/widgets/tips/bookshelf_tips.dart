import 'package:flutter/material.dart';

class BookshelfTips extends StatelessWidget {
  const BookshelfTips({super.key});

  final TextStyle textStyleBig = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  final TextStyle textStyle = const TextStyle(
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('(´。＿。｀)',
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 50),
          Text(
            '书架上没有书',
            style: textStyleBig,
          ),
          const SizedBox(height: 10),
          Text(
            '点击添加按钮，添加一本 epub ！',
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
