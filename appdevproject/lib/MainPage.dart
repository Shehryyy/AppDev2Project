import 'package:appdevproject/AddItemPage2.dart';
import 'package:appdevproject/HomePage.dart';
import 'package:appdevproject/List2Optional.dart';
import 'package:appdevproject/LoginPage.dart';
import 'package:appdevproject/api_nutrition.dart';
import 'package:appdevproject/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'JsonModels/items.dart';
import 'ProfilePage.dart';


class MainPageProject extends StatefulWidget {
  final int userId;
  const MainPageProject({super.key, required this.userId});

  @override
  State<MainPageProject> createState() => _MainPageProjectState();
}

class _MainPageProjectState extends State<MainPageProject> {
  List<Items> items =[];
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'items.db'),
    );

    final List<Map<String, dynamic>> maps = await db.query(
      'items' ,
      where: 'userId = ?',
      whereArgs: [widget.userId],
    );

    setState(() {
      items = maps.map((map) => Items.fromMap(map)).toList();
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Items'),
      ),
      drawer: ListView(
        children: [
          UserAccountsDrawerHeader(
              accountName: Text("Grocery List"), 
              accountEmail: Text(""),
          currentAccountPicture: Image.network("https://garlicdelight.com/wp-content/uploads/20210319-reverse-shopping-list-768x768.png", width: 400,),),
          Container(
            color: Colors.blue[50],
            child: ListTile(
              title: Text("Main List"),
              leading: Icon(Icons.list),
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainPageProject(userId: widget.userId)));
              },
            ),
          ),


          Container(
            color: Colors.blue[50],
            child: ListTile(
              title: Text("List 2"),
              leading: Icon(Icons.list),
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListOptionalProject(userId: widget.userId)));
              },
            ),
          ),

          Container(
            color: Colors.blue[50],
            child: ListTile(
              title: Text("Add Items"),
              leading: Icon(Icons.list),
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddItemPage(userId: widget.userId)));
              },
            ),
          ),

          Container(
            color: Colors.blue[50],
            child: ListTile(
              title: Text("Add Items Page 2"),
              leading: Icon(Icons.list),
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddItemPage2(userId: widget.userId)));
              },
            ),
          ),

          Container(
            color: Colors.blue[50],
            child: ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.lock),
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ),
        ],
      ),
      body: items.isEmpty
      ? const Center(child: Text("No items found."))
          : ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card (
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(item.itemName),
                subtitle: Text("Qty: ${item.quantity} | Type: ${item.type}"),
                trailing: Text(
                  "By ${item.neededBy.split("T")[0]}",
                  style: const TextStyle(color: Colors.grey),
              ),
              ),
            );
          }),
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color(0xFF7BA8F9),
      unselectedItemColor: const Color(0xFF7BA8F9),
      backgroundColor: const Color(0xFFE9ECF5),
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        switch (index) {
          case 0 :
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  NutritionPage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  MainPageProject(userId: widget.userId,)),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  UserProfilePage()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Nutritional Values'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile',),
      ],
    ),
    );
  }
}
