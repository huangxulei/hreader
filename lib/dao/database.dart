import 'package:flutter/foundation.dart';
import 'package:hreader/utils/get_path/databases_path.dart';
import 'package:hreader/utils/log/common.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const CREATE_BOOK_SQL = '''
CREATE TABLE tb_books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  cover_path TEXT,
  file_path TEXT,
  last_read_position TEXT,
  reading_percentage REAL,
  author TEXT,
  is_deleted INTEGER,
  description TEXT,
  create_time TEXT,
  update_time TEXT
)
''';

const CREATE_THEME_SQL = '''
CREATE TABLE tb_themes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  background_color TEXT,
  text_color TEXT,
  background_image_path TEXT
)
''';

const CREATE_STYLE_SQL = '''
CREATE TABLE tb_styles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  font_size REAL,
  font_family TEXT,
  line_height REAL,
  letter_spacing REAL,
  word_spacing REAL,
  paragraph_spacing REAL,
  side_margin REAL,
  top_margin REAL,
  bottom_margin REAL,
  rating REAL,
  group_id INTEGER
)
''';

const PRIMARY_THEME_1 = '''
INSERT INTO tb_themes (background_color, text_color, background_image_path) VALUES ('fffbfbf3', 'ff343434', '')
''';
const PRIMARY_THEME_2 = '''
INSERT INTO tb_themes (background_color, text_color, background_image_path) VALUES ('ff040404', 'fffeffeb', '')
''';

const CREATE_NOTE_SQL = '''
CREATE TABLE tb_notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER,
  content TEXT,
  cfi TEXT,
  chapter TEXT,
  type TEXT,
  color TEXT,
  create_time TEXT,
  update_time TEXT
)
''';

const CREATE_READING_TIME_SQL = '''
CREATE TABLE tb_reading_time (
  id INTEGER PRIMARY KEY,
  book_id INTEGER,
  date TEXT,
  reading_time INTEGER
)
''';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static void close() {
    _database?.close();
    _database = null;
  }

  Future<Database> initDB() async {
    int dbVersion = 5;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final databasePath = await getHDataBasesPath();
        final path = join(databasePath, 'app_database.db');
        return await openDatabase(
          path,
          version: dbVersion,
          onCreate: (db, version) async {
            onUpgradeDatabase(db, 0, version);
          },
          onUpgrade: onUpgradeDatabase,
        );
      case TargetPlatform.windows:
        sqfliteFfiInit();
        var databaseFactory = databaseFactoryFfi;
        final databasePath = await getHDataBasesPath();

        HLog.info('Database: database path: $databasePath');
        final path = join(databasePath, "app_database.db");
        return await databaseFactory.openDatabase(path,
            options: OpenDatabaseOptions(
              version: dbVersion,
              onCreate: (db, version) async {
                onUpgradeDatabase(db, 0, version);
              },
              onUpgrade: onUpgradeDatabase,
            ));
      default:
        throw Exception('Unsupported platform');
    }
  }

  Future<void> onUpgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    HLog.info('Database: upgrade database from $oldVersion to $newVersion');
    switch (oldVersion) {
      case 0:
        HLog.info('Database: create database version $newVersion');
        await db.execute(CREATE_BOOK_SQL);
        await db.execute(CREATE_NOTE_SQL);
        await db.execute(CREATE_THEME_SQL);
        await db.execute(CREATE_STYLE_SQL);
        await db.execute(CREATE_READING_TIME_SQL);
        await db.execute(PRIMARY_THEME_1);
        await db.execute(PRIMARY_THEME_2);
    }
  }
}
