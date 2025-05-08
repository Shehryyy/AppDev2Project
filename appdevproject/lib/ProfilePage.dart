import 'package:flutter/material.dart';

import 'HomePage.dart';


class CartSnapApp extends StatelessWidget {
  final int userId;
  const CartSnapApp({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CartSnap',
      debugShowCheckedModeBanner: false,
      home: const UserProfilePage(),
    );
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController(text: "User First Name");
    final TextEditingController lastNameController = TextEditingController(text: "User Last Name");
    final TextEditingController emailController = TextEditingController(text: "User Email");
    final TextEditingController passwordController = TextEditingController(text: "User Password");

    int _currentIndex = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFCCE9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB4D9F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'CartSnap',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'User Full Name',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7BA8F9),
                  ),
                ),
                const SizedBox(height: 30),
                _buildEditableField(
                  label: 'First Name',
                  controller: firstNameController,
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  label: 'Last Name',
                  controller: lastNameController,
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  label: 'Email',
                  controller: emailController,
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  label: 'Password',
                  controller: passwordController,
                  obscureText: true,
                  helperText: 'Your password must be at least 8 characters',
                ),
                const SizedBox(height: 30),
                _blueButton('List of previously bought items', () {}),
                const SizedBox(height: 15),
                _blueButton('Log out', () {}),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:  BottomNavigationBar(
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
              MaterialPageRoute(builder: (context) =>  Placeholder()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  AddItemPage(userId: 1,)), //TO CHANGE LATER
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

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: label,
                helperText: helperText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  // You will connect this later to update logic
                },
                icon: const Icon(Icons.edit, color: Color(0xFF7BA8F9)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _blueButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB2DAFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.blue),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
