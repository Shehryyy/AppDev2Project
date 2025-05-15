import 'package:appdevproject/PreviousItems.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'SQLite/sqlite.dart';
import 'JsonModels/users.dart';
import 'api_nutrition.dart';
import 'MainPage.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  '${widget.firstName} ${widget.lastName}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7BA8F9),
                  ),
                ),
                const SizedBox(height: 30),
                _buildEditableField(label: 'First Name', controller: firstNameController),
                const SizedBox(height: 20),
                _buildEditableField(label: 'Last Name', controller: lastNameController),
                const SizedBox(height: 20),
                _buildEditableField(label: 'Email', controller: emailController),
                const SizedBox(height: 20),
                _buildEditableField(
                  label: 'Password',
                  controller: passwordController,
                  obscureText: true,
                  helperText: 'Your password must be at least 8 characters',
                ),
                const SizedBox(height: 30),
                _blueButton('List of previously bought items', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PreviousItemsPage(userId: widget.userId,)));
                }),
                const SizedBox(height: 15),
                _blueButton('Log out', () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                }),
              ],
            ),
          ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPageProject(userId: widget.userId),
                ),
              );
              break;
            case 2:
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
                icon: const Icon(Icons.edit, color: Color(0xFF7BA8F9)),
                onPressed: () async {
                  final db = DatabaseHelper.instance;

                  Users updatedUser = Users(
                    userId: widget.userId,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: emailController.text,
                    userPassword: passwordController.text,
                  );

                  await db.updateUser(updatedUser);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Changes saved')),
                  );
                },
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
