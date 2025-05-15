import 'package:appdevproject/JsonModels/items2.dart';

import 'JsonModels/items.dart';
import 'MainPage.dart';
import 'ProfilePage.dart';
import 'api_nutrition.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'select_date_page.dart';
import 'SQLite/sqlite.dart';


class PreviousItemsPage extends StatefulWidget {
  final int userId;
  const PreviousItemsPage({super.key, required this.userId});

  @override
  State<PreviousItemsPage> createState() => _PreviousItemsPageState();
}

class _PreviousItemsPageState extends State<PreviousItemsPage> {
  List<Items> items = [];
  List<Items2> items2 = [];

  Database? _database;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadItems2();
  }

Future<Database> _initDatabase(String dbName) async {
    return openDatabase(p.join(await getDatabasesPath(), dbName));
}

  Future<void> _loadItems() async {
    final db = await _initDatabase('items.db');

    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'userId = ? AND isActive = 0',
      whereArgs: [widget.userId],
    );

    setState(() {
      items = maps.map((map) => Items.fromMap(map)).toList();
    });
  }

  Future<void> _loadItems2() async {
   final db = await _initDatabase('items2.db');

    final List<Map<String, dynamic>> maps = await db.query(
      'items2',
      where: 'userId = ? AND isActive = 0',
      whereArgs: [widget.userId],
    );

    setState(() {
      items2 = maps.map((map) => Items2.fromMap(map)).toList();
    });
  }

  Future<void> deleteItem(int itemId) async {
    final db = await _initDatabase('items.db');
    await db.delete(
      'items',
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
    await _loadItems();
  }

  Future<void> deleteItem2(int itemId) async {
    final db = await _initDatabase('items2.db');
    await db.delete(
      'items2',
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
    await _loadItems2();
  }

  void _showItemDetails(Items item) {
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

  void _showItem2Details(Items2 item2) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFCCE9FF),
        title: Text(item2.itemName, style: const TextStyle(color: Colors.blue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Quantity: ${item2.quantity}"),
            Text("Type: ${item2.type}"),
            Text("Needed By: ${item2.neededBy.split("T")[0]}"),
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
              await deleteItem2(item2.itemId!);
            },
            child: const Text("Delete Item", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCombinedItemList() {
    List<Widget> widgets = [];

    for (var item in items) {
      widgets.add(_buildItemTile(item));
    }

    for (var item2 in items2) {
      widgets.add(_buildItem2Tile(item2));
    }

    return widgets;
  }


  Widget _buildItemTile(Items item) {
    return Card(
      margin: const EdgeInsets.all(10),
      color: const Color(0xFFE94FFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blueAccent),
      ),
      child: ListTile(
        onTap: () => _showItemDetails(item),
        title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Quantity: ${item.quantity}"),
        trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red,),
        onPressed: ()  => _confirmDelete(() => deleteItem(item.itemId!)),
        ),
      ),
    );
  }

  Widget _buildItem2Tile(Items2 item2) {
    return Card(
      margin: const EdgeInsets.all(10),
      color: const Color(0xFFD8EFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blue),
      ),
      child: ListTile(
        onTap: () => _showItem2Details(item2),
        title: Text(item2.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Quantity: ${item2.quantity}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: ()  => _confirmDelete(() => deleteItem2(item2.itemId!)),
        ),
      ),
    );
  }

  void _confirmDelete(Function onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
        title: Text('Previous Bought Items List', style: TextStyle(color: Colors.blue)),
        backgroundColor: const Color(0xFFB4D9F5),
        centerTitle: true,
      ),
      body: (items.isEmpty && items2.isEmpty)
      ? const Center(child: Text("No items found."))
          : ListView(children: _buildCombinedItemList()),
    );

  }


}
