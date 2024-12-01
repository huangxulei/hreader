import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hreader/model/book.dart';
import 'package:hreader/providers/book_list.dart';
import 'package:hreader/widgets/bookshelf/book_item.dart';

class BookFolder extends ConsumerStatefulWidget {
  const BookFolder({
    super.key,
    required this.books,
  });

  final List<Book> books;

  @override
  ConsumerState<BookFolder> createState() => _BookFolderState();
}

class _BookFolderState extends ConsumerState<BookFolder> {
  bool willAcceptBook = false;
  @override
  Widget build(BuildContext context) {
    void onAcceptBook(DragTargetDetails<Book> details) {
      int targetGroupId;
      if (widget.books.first.groupId == 0) {
        ref.read(bookListProvider.notifier).updateBook(
            widget.books.first.copyWith(groupId: widget.books.first.id));
        targetGroupId = widget.books.first.id;
      } else {
        targetGroupId = widget.books.first.groupId;
      }

      ref.read(bookListProvider.notifier).moveBook(details.data, targetGroupId);
    }

    return widget.books.length == 1
        ? DragTarget<Book>(
            onAcceptWithDetails: (book) => onAcceptBook(book),
            onWillAcceptWithDetails: (data) => onWillAcceptBook(data),
            onLeave: (data) => onLeaveBook(data),
            builder: (context, candidateData, rejectedData) {
              return scaleTransition(BookItem(book: widget.books[0]));
            })
        : Container();
  }

  void onLeaveBook(Book? book) {
    willAcceptBook = false;
  }

  bool onWillAcceptBook(DragTargetDetails<Book>? details) {
    if (details?.data.id == widget.books.first.id) {
      return false;
    }
    willAcceptBook = details?.data != null;
    return details?.data != null;
  }

  Widget scaleTransition(Widget child) {
    return willAcceptBook
        ? ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(
                  parent: const AlwaysStoppedAnimation(0.5),
                  curve: Curves.easeInOut),
            ),
            child: child,
          )
        : child;
  }
}
