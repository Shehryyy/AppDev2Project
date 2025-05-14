import 'package:appdevproject/HomePage.dart';
import 'package:appdevproject/LoginPage.dart';
import 'package:appdevproject/api_nutrition.dart';
import 'package:appdevproject/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'JsonModels/items.dart';
import 'JsonModels/items2.dart';
import 'MainPage.dart';
import 'ProfilePage.dart';

class ListOptionalProject extends StatefulWidget {
  final int userId;
  const ListOptionalProject({super.key, required this.userId});

  @override
  State<ListOptionalProject> createState() => _ListOptionalProjectState();
}

class _ListOptionalProjectState extends State<ListOptionalProject> {
  List<Items2> items2 =[];

  @override
  void initState() {
    super.initState();
    _loadItems2();
  }

  Future<void> _loadItems2() async {
   final db = await _initDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      'items2' ,
      where: 'userId = ?',
      whereArgs: [widget.userId],
    );

    setState(() {
      items2 = maps.map((map) => Items2.fromMap(map)).toList();
    });

  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'items2.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS items2 (
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Optional List Items'),
      ),
      body: items2.isEmpty
          ? const Center(child: Text("No items found."))
          : ListView.builder(
          itemCount: items2.length,
          itemBuilder: (context, index) {
            final item2 = items2[index];
            return Card (
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(item2.itemName),
                subtitle: Text("Qty: ${item2.quantity} | Type: ${item2.type}"),
                trailing: Text(
                  "By ${item2.neededBy.split("T")[0]}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }),

    );
  }
}
