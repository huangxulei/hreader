import 'package:hreader/model/book.dart';
import 'package:hreader/dao/book.dart' as bookDao;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_list.g.dart';

@riverpod
class BookList extends _$BookList {
  @override
  Future<List<Book>> build() async {
    final books = await bookDao.selectNotDeleteBooks();

    return books;
  }

  Future<void> refresh() async {
    // ignore: invalid_use_of_protected_member
    state = AsyncData(await build());
  }

  void moveBook(Book data) {
    updateBook(data);
    refresh();
  }

  void updateBook(Book book) {
    bookDao.updateBook(book);
    refresh();
  }
}
