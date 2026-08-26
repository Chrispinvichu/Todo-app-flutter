import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

/// Handles all local persistence for tasks using SQLite (sqflite),
/// so data survives app restarts on both Android and iOS.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            category INTEGER NOT NULL,
            reminderTime INTEGER,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            createdAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'category = ?',
      whereArgs: [category.index],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }
}
