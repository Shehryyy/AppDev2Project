import 'package:flutter/material.dart';

class SelectDatePage extends StatefulWidget {
  final DateTime? initialDate;
  const SelectDatePage({super.key, this.initialDate});

  @override
  State<SelectDatePage> createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB4D9F5),
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
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Needed By',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7BA8F9),
            ),
          ),
          const SizedBox(height: 30),
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            onDateChanged: (date) => setState(() => selectedDate = date),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedDate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB2DAFF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}