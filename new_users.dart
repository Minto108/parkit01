import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  bool _isLoading = false;

  void _saveUser() {
    String name = _nameController.text;
    String vehicleNumber = _vehicleController.text;
    String phone = _phoneController.text;
    String tagNo = _tagController.text;
    String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (name.isEmpty || vehicleNumber.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'vehicleNumber': vehicleNumber,
      'phone': phone,
      'tagNo' : tagNo,
      'startTime': dateTime,
      'Active': 'Yes', // Automatically set Active to "Yes"
    }).then((_) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added successfully!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _vehicleController,
              decoration: const InputDecoration(labelText: 'Vehicle Number'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _tagController,
              decoration: const InputDecoration(labelText: 'Tag Number'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveUser,
                    child: const Text('Submit'),
                  ),
          ],
        ),
      ),
    );
  }
}
