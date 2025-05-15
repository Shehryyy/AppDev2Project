import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'JsonModels/items2.dart';

class ListOptionalProject extends StatefulWidget {
  final int userId;
  const ListOptionalProject({super.key, required this.userId});

  @override
  State<ListOptionalProject> createState() => _ListOptionalProjectState();
}

class _ListOptionalProjectState extends State<ListOptionalProject> {
  List<Items2> items2 = [];

  @override
  void initState() {
    super.initState();
    _loadItems2();
  }

  Future<void> _loadItems2() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'items2',
      where: 'userId = ?',
      whereArgs: [widget.userId],
    );
    setState(() {
      items2 = maps.map((map) => Items2.fromMap(map)).toList();
    });
  }

  Future<Database> _initDatabase() async {
    final path = p.join(await getDatabasesPath(), 'items2.db');
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

  Future<void> deleteItem(int itemId) async {
    final db = await _initDatabase();
    await db.delete('items2', where: 'itemId = ?', whereArgs: [itemId]);
    _loadItems2();
  }

  void _showItemDetails(Items2 item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFCCE9FF),
        title: Text(item.itemName, style: const TextStyle(color: Colors.blue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Quantity: ${item.quantity}"),
            Text("Type: ${item.type}"),
            Text("Needed By: ${item.neededBy.split("T")[0]}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Back to list"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteItem(item.itemId!);
            },
            child: const Text("Delete Item", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE9FF),
      appBar: AppBar(
        title: const Text('Optional List Items', style: TextStyle(color: Colors.blue)),
        backgroundColor: const Color(0xFFB4D9F5),
        centerTitle: true,
      ),
      body: items2.isEmpty
          ? const Center(child: Text("No items found."))
          : ListView.builder(
        itemCount: items2.length,
        itemBuilder: (context, index) {
          final item = items2[index];
          return Card(
            margin: const EdgeInsets.all(10),
            color: const Color(0xFFE9F4FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.blueAccent),
            ),
            child: ListTile(
              onTap: () => _showItemDetails(item),
              title: Text(
                item.itemName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Quantity: ${item.quantity}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await deleteItem(item.itemId!);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
