// TODO: Add local database service implementation
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cineverse.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // This function is called when the database is created for the first time.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmarks(
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        poster_path TEXT,
        release_date TEXT,
        vote_average REAL
      )
    ''');
  }

  // We will add methods here to add, remove, and get bookmarks.
}