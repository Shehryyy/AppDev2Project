import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ProfilePage.dart';
import 'MainPage.dart';

class NutritionPage extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const NutritionPage({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _items = [];
  String? _error;
  bool _isLoading = false;
  int _currentIndex = 0;

  final String apiKey = 'LjtuC6pvbToF8e1veRMnEzglUJ2S3sF87CPdI7CW';

  Future<void> fetchNutrition(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _error = 'Please enter a food name.';
        _items = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _items = [];
    });

    final url = Uri.parse('https://api.calorieninjas.com/v1/nutrition?query=${Uri.encodeComponent(query)}');

    try {
      final response = await http.get(
        url,
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _items = data['items'];
        });
      } else {
        setState(() {
          _error = 'Failed to load data (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildItemCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name'].toString().toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text('Serving: ${item['serving_size_g']}g', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const Divider(),
          Text('Calories: ${item['calories']} kcal'),
          Text('Protein: ${item['protein_g']} g'),
          Text('Fat: ${item['fat_total_g']} g'),
          Text('Carbs: ${item['carbohydrates_total_g']} g'),
          Text('Sugar: ${item['sugar_g']} g'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE9FF),
      appBar: AppBar(
        title: const Text(
          'Nutrition Finder',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: const Color(0xFFB4D9F5),
        centerTitle: true,
        automaticallyImplyLeading: false, // removes back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'e.g. egg and toast',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchNutrition(_controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2DAFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_items.isNotEmpty)
                Expanded(
                  child: GridView.builder(
                    itemCount: _items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.92,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return buildItemCard(_items[index]);
                    },
                  ),
                )
              else
                const Text('Enter a food to begin.'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF7BA8F9),
        unselectedItemColor: const Color(0xFF7BA8F9),
        backgroundColor: const Color(0xFFE9ECF5),
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              break; // Already on nutrition page
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPageProject(userId: widget.userId),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    userId: widget.userId,
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    email: widget.email,
                    password: widget.password,
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
}
