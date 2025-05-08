import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:appdevproject/LoginPage.dart';
import 'package:sqflite/sqflite.dart';

import 'JsonModels/users.dart';
import 'SQLite/sqlite.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Database? _database;
  List<Map<String, dynamic>> _users = [];
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _password = TextEditingController();
  final _confirmedPassword = TextEditingController();

  //Global key
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
      onCreate: (db,version) async {
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
    _loadUsers();
  }


  Future<void> _loadUsers() async {
    final users = await _database?.query('users');
    setState(() {
      _users = users ?? [];
    });
  }

  final db = DatabaseHelper.instance;

  Future<void> _insertUser() async {
    if (_password.text.isEmpty) {
      return;
    }
    await db.signup(Users(firstName: _firstName.text, lastName: _lastName.text ,email: _email.text, userPassword: _password.text)
    );

    _password.clear();
  }

  Future<bool> login (Users user) async {
    if (_database == null) {
      return false;
    }

    var result = await _database!.rawQuery(
        "SELECT email, password FROM users where email = '${user.email}' AND userPassword = '${user.userPassword}'");

    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }

  }

  Future<int> signup (Users user) async{
    if (_database == null) {
      throw Exception("Database not initialized");
    }
    return await _database!.insert("users", user.toMap());


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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
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
                SizedBox(height: 30),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstName,
                        decoration: _inputDecoration('Enter your first name'),
                        validator: (value) => value!.isEmpty ? 'Please enter first name' : null,
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: _lastName,
                        decoration: _inputDecoration('Enter your last name'),
                        validator: (value) => value!.isEmpty ? 'Please enter last name' : null,
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: _email,
                        decoration: _inputDecoration('Enter your email'),
                        validator: (value) => value!.isEmpty ? 'Please enter email' : null,
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: _password,
                        decoration: _inputDecoration('Enter your password'),
                        validator: (value) => value!.isEmpty ? 'Please enter password' : null,
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: _confirmedPassword,
                        decoration: _inputDecoration('Enter your confirmed password'),
                        validator: (value) => value!.isEmpty ? 'Please enter confirmed password' : null,
                      )
                    ],
                  ),
                ),

                SizedBox(height: 4),
                Text(
                  'Your password must be at least 8 characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final password = _password.text.trim();
                      final confirmPassword = _confirmedPassword.text.trim();

                      if (password != confirmPassword) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Password Mismatch'),
                            content: const Text('Passwords do not match. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // TODO: Implement real sign up logic
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Success'),
                            content:  const Text('Sign up successful!',),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
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
                    child: ElevatedButton(
                      onPressed: (){
                        if (formKey.currentState!.validate()){
                          final db = DatabaseHelper.instance;
                          db.signup(Users(
                            firstName: _firstName.text,
                              lastName: _lastName.text,
                              email: _email.text,
                              userPassword: _password.text))
                              .whenComplete((){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => LoginScreen()));
                          });
                        }
                      },
                      child: Text('Sign up',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          )),
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
