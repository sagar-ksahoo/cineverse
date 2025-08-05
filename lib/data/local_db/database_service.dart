import 'package:cineverse/models/movie.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern to ensure only one instance of the database service exists.
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // Getter for the database. Initializes it if it hasn't been already.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initializes the database, creating a file named 'cineverse.db'.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cineverse.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Called when the database is created for the first time.
  // Creates the 'bookmarks' table.
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

  // --- BOOKMARK METHODS ---

  /// Inserts a movie into the bookmarks table.
  /// If a movie with the same ID already exists, it will be replaced.
  Future<void> addBookmark(Movie movie) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      {
        'id': movie.id,
        'title': movie.title,
        'overview': movie.overview,
        'poster_path': movie.posterPath,
        'release_date': movie.releaseDate,
        'vote_average': movie.rating,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Removes a movie from the bookmarks table using its ID.
  Future<void> removeBookmark(int movieId) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [movieId],
    );
  }

  /// Checks if a movie with a given ID is already in the bookmarks table.
  /// Returns true if it exists, false otherwise.
  Future<bool> isBookmarked(int movieId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [movieId],
    );
    return maps.isNotEmpty;
  }

  /// Retrieves all movies from the bookmarks table and returns them as a List<Movie>.
  Future<List<Movie>> getBookmarkedMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks');

    // Convert the List<Map<String, dynamic>> into a List<Movie>.
    return List.generate(maps.length, (i) {
      return Movie(
        id: maps[i]['id'],
        title: maps[i]['title'],
        overview: maps[i]['overview'],
        posterPath: maps[i]['poster_path'],
        releaseDate: maps[i]['release_date'],
        rating: maps[i]['vote_average'],
      );
    });
  }
}
