import 'package:cineverse/models/movie.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
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

    await db.execute('''
      CREATE TABLE movie_cache(
        id INTEGER,
        category TEXT,
        title TEXT,
        overview TEXT,
        poster_path TEXT,
        release_date TEXT,
        vote_average REAL,
        PRIMARY KEY (id, category)
      )
    ''');
  }

  // --- Bookmark Methods ---

  /// Inserts a movie into the bookmarks table.
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
  Future<bool> isBookmarked(int movieId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [movieId],
    );
    return maps.isNotEmpty;
  }

  /// Retrieves all movies from the bookmarks table.
  Future<List<Movie>> getBookmarkedMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks');
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

  // --- Caching Methods ---

  Future<void> cacheMovies(List<Movie> movies, String category) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('movie_cache', where: 'category = ?', whereArgs: [category]);
    for (final movie in movies) {
      batch.insert(
        'movie_cache',
        {
          'id': movie.id,
          'category': category,
          'title': movie.title,
          'overview': movie.overview,
          'poster_path': movie.posterPath,
          'release_date': movie.releaseDate,
          'vote_average': movie.rating,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves a list of cached movies for a specific category.
  Future<List<Movie>> getCachedMovies(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movie_cache',
      where: 'category = ?',
      whereArgs: [category],
    );
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
