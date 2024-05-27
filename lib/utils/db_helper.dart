import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String _databaseName = 'flashcards.db';
  static const int _databaseVersion = 1;

  DBHelper._(); // private constructor (can't be called from outside)

  // the single instance
  static final DBHelper _singleton = DBHelper._();

  // factory constructor that always returns the single instance
  factory DBHelper() => _singleton;

  // the singleton will hold a reference to the database once opened
  Database? _database;

  // initialize the database when it's first requested
  get db async {
    _database ??= await _initDatabase(); // if null, initialize it
    return _database;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);

    // print(dbPath);
    // await deleteDatabase(dbPath); // nuke the database (for testing)

    var db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        // create the customer table
        await db.execute('''
          CREATE TABLE deck(
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE flashcard(
            id INTEGER PRIMARY KEY,
            question TEXT NOT NULL,
            answer TEXT NOT NULL,
            deckId INTEGER,
            FOREIGN KEY (deckId) REFERENCES deck (id)
          )
        ''');
      }
    );
    return db;
  }

  // fetch records from a table with an optional "where" clause
  Future<List<Map<String, dynamic>>> query(String table, {String? where}) async {
    final db = await this.db;
    return where == null ? db.query(table)
                         : db.query(table, where: where);
  }

  // insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // update a record in a table
  Future<void> update(String table, Map<String, dynamic> data, String whereClause, List<dynamic> whereArgs) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  // delete a record from a table
  Future<void> delete(String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await this.db;
    await db.delete(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }
  Future<void> deleteDeckAndRelatedFlashcards(int deckId) async {
    final db = await this.db;
    await db.transaction((txn) async {
      await txn.delete('flashcard', where: 'deckId = ?', whereArgs: [deckId]);
      await txn.delete('deck', where: 'id = ?', whereArgs: [deckId]);
  });
}
}