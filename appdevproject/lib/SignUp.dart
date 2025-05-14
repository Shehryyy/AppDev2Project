import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'LoginPage.dart';
import 'package:sqflite/sqflite.dart';
import 'JsonModels/users.dart';
import 'SQLite/sqlite.dart';
import 'package:path_provider/path_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Database? _database;
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _password = TextEditingController();
  final _confirmedPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'users.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users (
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        lastName TEXT,
        email TEXT,
        password TEXT
        )
        ''');
      },
    );
  }

  final db = DatabaseHelper.instance;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7BA8F9),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstName,
                        decoration: _inputDecoration('Enter your first name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          } else if (RegExp(r'\d').hasMatch(value)) {
                            return 'Name cannot contain numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lastName,
                        decoration: _inputDecoration('Enter your last name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          } else if (RegExp(r'\d').hasMatch(value)) {
                            return 'Name cannot contain numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _email,
                        decoration: _inputDecoration('Enter your email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          } else if (!value.contains('@') ||
                              (!value.endsWith('.com') &&
                                  !value.endsWith('.ca'))) {
                            return 'Enter a valid email (.com or .ca)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: _inputDecoration('Enter your password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmedPassword,
                        obscureText: true,
                        decoration:
                        _inputDecoration('Enter your confirmed password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != _password.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your password must be at least 8 characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        db
                            .signup(Users(
                          firstName: _firstName.text,
                          lastName: _lastName.text,
                          email: _email.text,
                          userPassword: _password.text,
                        ))
                            .whenComplete(() => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen())));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB2DAFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.blue),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
