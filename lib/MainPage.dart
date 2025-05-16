import 'AddItemPage2.dart';
import 'HomePage.dart';
import 'List2Optional.dart';
import 'LoginPage.dart';
import 'api_nutrition.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'JsonModels/items.dart';
import 'ProfilePage.dart';
import 'SQLite/sqlite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainPageProject extends StatefulWidget {
  final int userId;
  const MainPageProject({super.key, required this.userId});

  @override
  State<MainPageProject> createState() => _MainPageProjectState();
}

class _MainPageProjectState extends State<MainPageProject> {
  List<Items> items = [];
  int _currentIndex = 1;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadItems();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotification(Items item) async {
    final now = DateTime.now();
    final neededDate = DateTime.parse(item.neededBy);
    final dateDiff = neededDate.difference(now).inDays;

    print("🟡 Checking item '${item.itemName}': isActive=${item.isActive}, userId=${item.userId}, dateDiff=$dateDiff");

    if (item.isActive == 1 && item.userId == widget.userId && dateDiff == 0) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.high,
        priority: Priority.high,
      );
      const NotificationDetails generalNotificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        item.itemId!,
        'Reminder: ${item.itemName}',
        'You need this item tomorrow!',
        generalNotificationDetails,
      );

      print("✅ Notification sent for '${item.itemName}'");
    } else {
      print("⛔ Skipping notification for '${item.itemName}'");
    }
  }

  Future<void> _loadItems() async {
    final db = await openDatabase(p.join(await getDatabasesPath(), 'items.db'));
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'userId = ? AND isActive = 1',
      whereArgs: [widget.userId],
    );

    List<Items> loadedItems = maps.map((map) => Items.fromMap(map)).toList();
    setState(() {
      items = loadedItems;
    });

    for (final item in loadedItems) {
      await scheduleNotification(item);
    }
  }

  Future<void> markItemAsBought(int itemId) async {
    final db = await openDatabase(p.join(await getDatabasesPath(), 'items.db'));
    await db.update('items', {'isActive': 0}, where: 'itemId = ?', whereArgs: [itemId]);
    await _loadItems();
  }

  Future<void> deleteItem(int itemId) async {
    final db = await openDatabase(p.join(await getDatabasesPath(), 'items.db'));
    await db.delete('items', where: 'itemId = ?', whereArgs: [itemId]);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted')));
    await _loadItems();
  }

  void showEditDialog(Items item) {
    TextEditingController nameController = TextEditingController(text: item.itemName);
    TextEditingController quantityController = TextEditingController(text: item.quantity.toString());
    String selectedType = item.type;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: ['Fruits/Vegetables', 'Proteins', 'Dairy', 'Snacks'].contains(selectedType)
                    ? selectedType
                    : null,
                items: ['Fruits/Vegetables', 'Proteins', 'Dairy', 'Snacks']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => selectedType = value!,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final db = await openDatabase(p.join(await getDatabasesPath(), 'items.db'));
                await db.update(
                  'items',
                  {
                    'itemName': nameController.text,
                    'quantity': quantityController.text,
                    'type': selectedType,
                  },
                  where: 'itemId = ?',
                  whereArgs: [item.itemId],
                );
                Navigator.pop(context);
                await _loadItems();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back to list")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await markItemAsBought(item.itemId!);
            },
            child: const Text("Already Bought", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget drawerItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      color: Colors.blue[50],
      child: ListTile(title: Text(title), leading: Icon(icon), onTap: onTap),
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
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
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
              title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Quantity: ${item.quantity}"),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => showEditDialog(item)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteItem(item.itemId!)),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => NutritionPage(
                userId: user.userId!,
                firstName: user.firstName ?? '',
                lastName: user.lastName ?? '',
                email: user.email ?? '',
                password: user.userPassword ?? '',
              )));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainPageProject(userId: widget.userId)));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(
                userId: user.userId!,
                firstName: user.firstName ?? '',
                lastName: user.lastName ?? '',
                email: user.email ?? '',
                password: user.userPassword ?? '',
              )));
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
}
