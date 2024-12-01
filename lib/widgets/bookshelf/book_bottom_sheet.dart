import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hreader/model/book.dart';
import 'package:hreader/page/book_detail.dart';
import 'package:hreader/widgets/bookshelf/book_cover.dart';
import 'package:hreader/widgets/delete_confirm.dart';
import 'package:hreader/widgets/icon_and_text.dart';
import 'package:icons_plus/icons_plus.dart';

class BookBottomSheet extends ConsumerWidget {
  const BookBottomSheet({super.key, required this.book});
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void handleDetail(BuildContext context) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetail(book: book),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bookCover(context, book, width: 40),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
            book.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          )),
          iconAndText(
            icon: const Icon(EvaIcons.more_vertical),
            text: "笔记",
            onTap: () {
              handleDetail(context);
            },
          ),
          DeleteConfirm(
            delete: () {},
            deleteIcon: iconAndText(
              icon: const Icon(EvaIcons.trash),
              text: "common_delete",
            ),
            confirmIcon: iconAndText(
              icon: const Icon(
                EvaIcons.checkmark_circle_2,
                color: Colors.red,
              ),
              text: "common_confirm",
            ),
          )
        ],
      ),
    );
  }
}
