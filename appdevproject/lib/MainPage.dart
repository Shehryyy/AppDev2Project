import 'AddItemPage2.dart';
import 'HomePage.dart';
import 'List2Optional.dart';
import 'LoginPage.dart';
import 'api_nutrition.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'JsonModels/items.dart';
import 'ProfilePage.dart';
import 'SQLite/sqlite.dart';
import 'JsonModels/users.dart';

class MainPageProject extends StatefulWidget {
  final int userId;
  const MainPageProject({super.key, required this.userId});

  @override
  State<MainPageProject> createState() => _MainPageProjectState();
}

class _MainPageProjectState extends State<MainPageProject> {
  List<Items> items = [];
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final db = await openDatabase(
      p.join(await getDatabasesPath(), 'items.db'),
    );

    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'userId = ?',
      whereArgs: [widget.userId],
    );

    setState(() {
      items = maps.map((map) => Items.fromMap(map)).toList();
    });
  }

  Future<void> deleteItem(int itemId) async {
    final db = await openDatabase(p.join(await getDatabasesPath(), 'items.db'));
    await db.delete(
      'items',
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
    await _loadItems();
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
            child: const Text("Already Bought", style: TextStyle(color: Colors.red)),
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
        title: const Text('My Items', style: TextStyle(color: Colors.blue)),
        backgroundColor: const Color(0xFFB4D9F5),
        centerTitle: true,
      ),
      drawer: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Grocery List"),
            accountEmail: Text(""),
            currentAccountPicture: Image(
              image: NetworkImage("https://garlicdelight.com/wp-content/uploads/20210319-reverse-shopping-list-768x768.png"),
              width: 400,
            ),
            decoration: BoxDecoration(color: Color(0xFFB4D9F5)),
          ),
          drawerItem("Main List", Icons.list, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainPageProject(userId: widget.userId)));
          }),
          drawerItem("List 2", Icons.list, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ListOptionalProject(userId: widget.userId)));
          }),
          drawerItem("Add Items", Icons.add, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemPage(userId: widget.userId)));
          }),
          drawerItem("Add Items Page 2", Icons.add_box, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemPage2(userId: widget.userId)));
          }),
          drawerItem("Logout", Icons.logout, () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          }),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text("No items found."))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
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
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Future editing logic
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await deleteItem(item.itemId!);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF7BA8F9),
        unselectedItemColor: const Color(0xFF7BA8F9),
        backgroundColor: const Color(0xFFE9ECF5),
        onTap: (index) async {
          setState(() => _currentIndex = index);
          final db = DatabaseHelper.instance;
          final user = await db.getUserById(widget.userId);
          if (user == null) return;

          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NutritionPage(
                    userId: user.userId!,
                    firstName: user.firstName ?? '',
                    lastName: user.lastName ?? '',
                    email: user.email ?? '',
                    password: user.userPassword ?? '',
                  ),
                ),
              );
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainPageProject(userId: widget.userId)));
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    userId: user.userId!,
                    firstName: user.firstName ?? '',
                    lastName: user.lastName ?? '',
                    email: user.email ?? '',
                    password: user.userPassword ?? '',
                  ),
                ),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Nutritional Values'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget drawerItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      color: Colors.blue[50],
      child: ListTile(
        title: Text(title),
        leading: Icon(icon),
        onTap: onTap,
      ),
    );
  }
}
