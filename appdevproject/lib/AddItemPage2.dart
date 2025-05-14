import 'JsonModels/items.dart';
import 'List2Optional.dart';
import 'MainPage.dart';
import 'ProfilePage.dart';
import 'api_nutrition.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'JsonModels/items2.dart';
import 'select_date_page.dart';
import 'SQLite/sqlite.dart';
import 'JsonModels/users.dart';

class AddItemPage2 extends StatefulWidget {
  final int userId;
  const AddItemPage2({super.key, required this.userId});

  @override
  State<AddItemPage2> createState() => _AddItemPageState2();
}

class _AddItemPageState2 extends State<AddItemPage2> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String? selectedType;
  DateTime? neededByDate;
  Database? _database;
  int _currentIndex = 1;

  final formKey = GlobalKey<FormState>();
  final List<String> types = ['Dairies', 'Proteins', 'Snacks', 'Fruits/Vegetables'];

  @override
  void initState() {
    super.initState();
    _initDatabaseItem();
  }

  Future<Database> _initDatabaseItem() async {
    if (_database != null) return _database!;
    String path = p.join(await getDatabasesPath(), 'items2.db');
    _database = await openDatabase(
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
    return _database!;
  }

  Future<void> insertItem2(Items2 item) async {
    final db = await _initDatabaseItem();
    await db.insert('items2', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void _selectDate() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDatePage(initialDate: neededByDate),
      ),
    );
    if (selected != null && selected is DateTime) {
      setState(() {
        neededByDate = selected;
      });
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notice'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB4D9F5),
        centerTitle: true,
        title: const Text('CartSnap', style: TextStyle(color: Colors.blue)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Adding item for 2nd Page',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7BA8F9),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Item Name:', style: TextStyle(fontSize: 16, color: Colors.blue)),
            const SizedBox(height: 8),
            TextField(controller: itemNameController, decoration: _inputDecoration()),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.black26),
            const SizedBox(height: 10),
            const Text('Quantity:', style: TextStyle(fontSize: 16, color: Colors.blue)),
            const SizedBox(height: 8),
            TextField(
              controller: quantityController,
              decoration: _inputDecoration(),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.black26),
            const SizedBox(height: 10),
            const Text('Type:', style: TextStyle(fontSize: 16, color: Colors.blue)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: types.map((type) {
                final isSelected = selectedType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedType = type),
                  selectedColor: Colors.lightBlue,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.black26),
            const SizedBox(height: 10),
            const Text('Needed By:', style: TextStyle(fontSize: 16, color: Colors.blue)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: neededByDate == null
                        ? ''
                        : '${neededByDate!.month.toString().padLeft(2, '0')}/${neededByDate!.day.toString().padLeft(2, '0')}/${neededByDate!.year}',
                  ),
                  decoration: InputDecoration(
                    hintText: 'MM/DD/YYYY',
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.black26),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  String itemName = itemNameController.text.trim();
                  String quantity = quantityController.text.trim();

                  if (itemName.isEmpty) {
                    _showAlert('Please enter an item name.');
                  } else if (quantity.isEmpty) {
                    _showAlert('Please enter a quantity.');
                  } else if (selectedType == null) {
                    _showAlert('Please select a type.');
                  } else if (neededByDate == null) {
                    _showAlert('Please select a needed-by date.');
                  } else {
                    final item = Items2(
                      itemName: itemName,
                      quantity: quantity,
                      type: selectedType!,
                      neededBy: neededByDate!.toIso8601String(),
                      userId: widget.userId,
                    );

                    insertItem2(item).then((_) {
                      _showAlert('Item added successfully to page 2!');
                      itemNameController.clear();
                      quantityController.clear();
                      setState(() {
                        selectedType = null;
                        neededByDate = null;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListOptionalProject(userId: widget.userId),
                          ),
                        );
                      });
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB2DAFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.blue),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Add item', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF7BA8F9),
        unselectedItemColor: const Color(0xFF7BA8F9),
        backgroundColor: const Color(0xFFE9ECF5),
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NutritionPage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPageProject(userId: widget.userId)),
              );
              break;
            case 2:
              final db = DatabaseHelper.instance;
              final user = await db.getUserById(widget.userId);
              if (user != null) {
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
              }
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
