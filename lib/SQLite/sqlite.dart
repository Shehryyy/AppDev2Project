import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../JsonModels/users.dart';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            userId INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT,
            lastName TEXT,
            email TEXT,
            userPassword TEXT
          )
        ''');
      },
    );
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<int?> login(Users user) async {
    final db = await database;

    var res = await db.rawQuery(
      "SELECT userId FROM users WHERE email = ? AND userPassword = ?",
      [user.email, user.userPassword],
    );

    if (res.isNotEmpty) {
      print("Login successful for user: \${user.email}");
      return res.first["userId"] as int;
    } else {
      print("Login failed for email: \${user.email}");
      return null;
    }
  }

  Future<int> signup(Users user) async {
    final db = await database;
    return await db.insert("users", user.toMap());
  }

  Future<Users?> getUserById(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      print("getUserById(\$userId) fetched: \${result.first}");
      return Users.fromMap(result.first);
    } else {
      print("getUserById(\$userId) found no user.");
      return null;
    }
  }

  Future<int> updateUser(Users user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'userId = ?',
      whereArgs: [user.userId],
    );
  }

  Future<Database> _initDatabaseItem() async {
    String path = join(await getDatabasesPath(), 'items.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items (
            itemId INTEGER PRIMARY KEY AUTOINCREMENT,
            itemName TEXT,
            quantity TEXT,
            type TEXT,
            neededBy TEXT,
            userId INTEGER
          )
        ''');
      },
    );

    await db.execute('''
      ALTER TABLE items ADD COLUMN isActive INTEGER DEFAULT 1
    ''').catchError((e) {
      if (e.toString().contains("duplicate column name")) {
        print("Column 'isActive' already exists in items");
      } else {
        print("Failed to add isActive column: \$e");
        throw e;
      }
    });

    return db;
  }

  Future<Database> initDatabaseItem2() async {
    String path = join(await getDatabasesPath(), 'items2.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items2 (
            itemId INTEGER PRIMARY KEY AUTOINCREMENT,
            itemName TEXT,
            quantity TEXT,
            type TEXT,
            neededBy TEXT,
            userId INTEGER
          )
        ''');
      },
    );

    await db.execute('''
      ALTER TABLE items2 ADD COLUMN isActive INTEGER DEFAULT 1
    ''').catchError((e) {
      if (e.toString().contains("duplicate column name")) {
        print("Column 'isActive' already exists in items2");
      } else {
        print("Failed to add isActive column: \$e");
        throw e;
      }
    });
    return db;
  }
}