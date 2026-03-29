# Offline Posts Manager

A Flutter application for managing posts offline using SQLite database. This app allows staff members to create, read, update, and delete posts without requiring internet connectivity.

## Features

- **Offline Storage**: All posts are stored locally using SQLite database
- **CRUD Operations**: Create, Read, Update, and Delete posts
- **Post Details**: View detailed information about each post including timestamps
- **Search Functionality**: Search posts by title or content
- **Error Handling**: Comprehensive error handling for database operations
- **Cross-Platform**: Works on Android, iOS, Web, Windows, Linux, and macOS

## Dependencies Used

### Core Dependencies
- **sqflite: ^2.3.0** - SQLite database plugin for Flutter
  - Provides local database storage capabilities
  - Handles database operations asynchronously
  - Supports complex queries and transactions

- **sqflite_common_ffi: ^2.3.0** - FFI (Foreign Function Interface) support for sqflite
  - Enables SQLite support on desktop platforms (Windows, Linux, macOS)
  - Provides web support through IndexedDB fallback

- **path_provider: ^2.1.0** - Platform-specific path provider
  - Gets the correct directory paths for storing database files
  - Ensures proper file system access across platforms

- **path_provider_platform_interface: ^2.1.0** - Platform interface for path_provider
  - Provides consistent API across different platforms

- **intl: ^0.19.0** - Internationalization library
  - Formats dates and times for display
  - Provides localized date formatting

### Why SQLite is Necessary for Local Data Storage

SQLite is essential for this application because:

1. **Offline Capability**: Allows the app to function completely offline, storing data locally on the device
2. **Persistence**: Data survives app restarts and device reboots
3. **Performance**: Fast read/write operations for local data access
4. **Cross-Platform**: Single database solution that works across all Flutter-supported platforms
5. **ACID Compliance**: Ensures data integrity through atomic transactions
6. **No Server Required**: Eliminates dependency on network connectivity or external services
7. **Structured Storage**: Provides relational database capabilities for complex data relationships

## Database Schema

```sql
CREATE TABLE posts(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

## SQLite in Flutter

### Database vs Table
- **Database**: A single file containing the entire database (posts.db)
- **Table**: A collection of related data within the database (posts table)

### CRUD Operations
- **Create**: `INSERT INTO posts (title, content, created_at, updated_at) VALUES (?, ?, ?, ?)`
- **Read**: `SELECT * FROM posts WHERE id = ?` or `SELECT * FROM posts ORDER BY updated_at DESC`
- **Update**: `UPDATE posts SET title = ?, content = ?, updated_at = ? WHERE id = ?`
- **Delete**: `DELETE FROM posts WHERE id = ?`

### Asynchronous Database Interaction
Flutter interacts with SQLite asynchronously to prevent UI blocking:

```dart
// All database operations return Futures
Future<List<Post>> getAllPosts() async {
  final db = await database;  // Wait for database to be ready
  final maps = await db.query('posts');  // Asynchronous query
  return maps.map((map) => Post.fromMap(map)).toList();
}
```

## Error Handling

The application implements comprehensive error handling for database operations:

### Database Initialization Errors
- **Not Initialized**: Caught during database factory setup
- **Path Issues**: Handled when getting application documents directory
- **Permission Issues**: Caught when accessing file system

### CRUD Operation Errors
- **Insert Errors**: Validation for empty title/content, database constraints
- **Update Errors**: Post ID validation, data integrity checks
- **Delete Errors**: ID validation, foreign key constraints
- **Query Errors**: Malformed SQL, corrupted data handling

### Data Corruption Handling
- **Invalid Data**: JSON parsing errors during data deserialization
- **Corrupted Records**: Graceful handling of malformed database entries
- **Migration Issues**: Database schema version conflicts

### User-Friendly Error Messages
```dart
try {
  await _dbHelper.insertPost(post);
} catch (e) {
  // Show user-friendly error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to save post: ${e.toString()}'))
  );
}
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation
1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android APK
flutter build apk --release

# iOS (on macOS)
flutter build ios --release

# Web
flutter build web --release
```

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── database/
│   └── database_helper.dart     # Database operations and error handling
├── models/
│   └── post.dart                # Post data model
├── screens/
│   ├── home_screen.dart         # Main screen with posts list
│   ├── add_edit_post_screen.dart # Add/Edit post screen
│   └── post_detail_screen.dart  # Post details view
└── widgets/
    └── post_card.dart           # Post list item widget
```

## Screenshots

[Screenshots would be included here showing the app in action]

## Submission Requirements

This project fulfills the requirements for Individual Flutter Lab 5:
- ✅ Offline post management with SQLite
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Local data storage without internet dependency
- ✅ Error handling for database operations
- ✅ Cross-platform compatibility
- ✅ Proper state management and UI updates

## License

This project is for educational purposes as part of a Flutter development course.
