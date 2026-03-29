import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/post.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Initialize database factory for web
  static void init() {
    if (kIsWeb) {
      // Initialize FFI for web support
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database with error handling
  Future<Database> _initDatabase() async {
    try {
      Database db;
      
      if (kIsWeb) {
        // For web: Use in-memory database or IndexedDB
        db = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: _onCreate,
            onOpen: _onOpen,
          ),
        );
      } else {
        // For mobile: Use file system
        final documentsDirectory = await getApplicationDocumentsDirectory();
        final path = join(documentsDirectory.path, 'posts.db');
        
        db = await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
          onOpen: _onOpen,
        );
      }
      
      return db;
    } catch (e) {
      throw DatabaseException('Failed to initialize database: $e');
    }
  }

  // Create table
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE posts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    } catch (e) {
      throw DatabaseException('Failed to create table: $e');
    }
  }

  // Database opened callback
  Future<void> _onOpen(Database db) async {
    // Verify table exists
    try {
      final result = await db.query('sqlite_master', 
        where: 'type = ? AND name = ?', 
        whereArgs: ['table', 'posts']
      );
      if (result.isEmpty) {
        await _onCreate(db, 1);
      }
    } catch (e) {
      throw DatabaseException('Database verification failed: $e');
    }
  }

  // CRUD Operations with comprehensive error handling

  // CREATE - Add new post
  Future<int> insertPost(Post post) async {
    try {
      final db = await database;
      if (post.title.trim().isEmpty) {
        throw DatabaseException('Title cannot be empty');
      }
      if (post.content.trim().isEmpty) {
        throw DatabaseException('Content cannot be empty');
      }
      
      return await db.insert('posts', post.toMap());
    } catch (e) {
      throw DatabaseException('Failed to insert post: $e');
    }
  }

  // READ - Get all posts
  Future<List<Post>> getAllPosts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'posts',
        orderBy: 'updated_at DESC',
      );
      
      return List.generate(maps.length, (i) {
        try {
          return Post.fromMap(maps[i]);
        } catch (e) {
          throw DatabaseException('Failed to parse post data: $e');
        }
      });
    } catch (e) {
      throw DatabaseException('Failed to fetch posts: $e');
    }
  }

  // READ - Get single post by ID
  Future<Post?> getPostById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'posts',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        try {
          return Post.fromMap(maps.first);
        } catch (e) {
          throw DatabaseException('Failed to parse post data: $e');
        }
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to fetch post: $e');
    }
  }

  // UPDATE - Update existing post
  Future<int> updatePost(Post post) async {
    try {
      final db = await database;
      if (post.id == null) {
        throw DatabaseException('Post ID is required for update');
      }
      if (post.title.trim().isEmpty) {
        throw DatabaseException('Title cannot be empty');
      }
      if (post.content.trim().isEmpty) {
        throw DatabaseException('Content cannot be empty');
      }
      
      return await db.update(
        'posts',
        post.toMap(),
        where: 'id = ?',
        whereArgs: [post.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update post: $e');
    }
  }

  // DELETE - Delete post
  Future<int> deletePost(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'posts',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete post: $e');
    }
  }

  // Search posts by title or content
  Future<List<Post>> searchPosts(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'posts',
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'updated_at DESC',
      );
      
      return List.generate(maps.length, (i) {
        try {
          return Post.fromMap(maps[i]);
        } catch (e) {
          throw DatabaseException('Failed to parse search results: $e');
        }
      });
    } catch (e) {
      throw DatabaseException('Failed to search posts: $e');
    }
  }

  // Get posts count
  Future<int> getPostsCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM posts');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get posts count: $e');
    }
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

// Custom exception class
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
}