import 'package:hreader/dao/database.dart';
import 'package:hreader/model/book.dart';
import 'package:hreader/utils/log/common.dart';

Future<int> insertBook(Book book) async {
  if (book.id != -1) {
    updateBook(book);
    return book.id;
  }
  final db = await DBHelper().database;
  return db.insert('tb_books', book.toMap());
}

Future<List<Book>> selectBooks() async {
  final db = await DBHelper().database;
  final List<Map<String, dynamic>> maps =
      await db.query('tb_books', orderBy: 'update_time DESC');
  return List.generate(maps.length, (i) {
    return Book(
      id: maps[i]['id'],
      title: maps[i]['title'],
      coverPath: maps[i]['cover_path'],
      filePath: maps[i]['file_path'],
      lastReadPosition: maps[i]['last_read_position'],
      readingPercentage: maps[i]['reading_percentage'],
      author: maps[i]['author'],
      isDeleted: maps[i]['is_deleted'] == 1 ? true : false,
      description: maps[i]['description'],
      rating: maps[i]['rating'] ?? 0.0,
      groupId: maps[i]['group_id'],
      createTime: DateTime.parse(maps[i]['create_time']),
      updateTime: DateTime.parse(maps[i]['update_time']),
    );
  });
}

Future<void> updateBook(Book book) async {
  book.updateTime = DateTime.now();
  final db = await DBHelper().database;
  HLog.info('dao: update book: ${book.toMap()}');
  await db.update(
    'tb_books',
    book.toMap(),
    where: 'id = ?',
    whereArgs: [book.id],
  );
}
