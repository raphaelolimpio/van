// ignore_for_file: unused_local_variable

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  final String _dbName = 'vanescolar.db';
  final String _vanTable = 'vans';
  final String _studentTable = 'students';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_vanTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            driverName TEXT,
            vanModel TEXT,
            seatCount INTEGER
          )
        ''');
        db.execute('''
          CREATE TABLE $_studentTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            gender INTEGER,
            address TEXT,
            phone TEXT,
            dob TEXT,
            shift TEXT,
            school TEXT,
            grade TEXT,
            creditAmount REAL,
            depositedAmount REAL,
            totalPasses INTEGER,
            vanId INTEGER,
            FOREIGN KEY(vanId) REFERENCES $_vanTable(id)
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> addVan(String driverName, String vanModel, int seatCount) async {
    final db = await database;
    return await db.insert(_vanTable, {
      'driverName': driverName,
      'vanModel': vanModel,
      'seatCount': seatCount,
    });
  }

  Future<List<Map<String, dynamic>>> getVans() async {
    final db = await database;
    return await db.query(_vanTable);
  }

  Future<void> openDatabaseForVan(String dbName) async {
    final path = join(await getDatabasesPath(),
        dbName); // Adjust this method to handle different databases if needed
    // For simplicity, this example assumes a single database
    _database = await openDatabase(
      join(await getDatabasesPath(), dbName),
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_studentTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            gender INTEGER,
            address TEXT,
            phone TEXT,
            dob TEXT,
            shift TEXT,
            school TEXT,
            grade TEXT,
            creditAmount REAL,
            depositedAmount REAL,
            totalPasses INTEGER,
            vanId INTEGER,
            FOREIGN KEY(vanId) REFERENCES $_vanTable(id)
          )
        ''');
      },
    );
  }

  Future<int> addStudent(
    String name,
    bool isMale,
    String address,
    String phone,
    String dob,
    String shift,
    String school,
    String grade,
    double creditAmount,
    double depositedAmount,
    int totalPasses,
    int vanId,
  ) async {
    final db = await database;
    return await db.insert(_studentTable, {
      'name': name,
      'gender': isMale ? 1 : 0,
      'address': address,
      'phone': phone,
      'dob': dob,
      'shift': shift,
      'school': school,
      'grade': grade,
      'creditAmount': creditAmount,
      'depositedAmount': depositedAmount,
      'totalPasses': totalPasses,
      'vanId': vanId,
    });
  }

  Future<List<Map<String, dynamic>>> getStudents(int vanId) async {
    final db = await database;
    return await db.query(
      _studentTable,
      where: 'vanId = ?',
      whereArgs: [vanId],
    );
  }
}
