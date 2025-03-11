import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleCoordinatesPage extends StatefulWidget {
  final String userName; // User's Name from Active Users Page

  const VehicleCoordinatesPage({super.key, required this.userName});

  @override
  _VehicleCoordinatesPageState createState() => _VehicleCoordinatesPageState();
}

class _VehicleCoordinatesPageState extends State<VehicleCoordinatesPage> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  bool _isLoading = false;

  void _saveCoordinates() async {
    String latitude = _latitudeController.text;
    String longitude = _longitudeController.text;

    if (latitude.isEmpty || longitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both latitude and longitude!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Find user document by name
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: widget.userName) // Find by name
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Get the first document ID
        String userId = userSnapshot.docs.first.id;

        // Update the user's coordinates
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'latitude': latitude,
          'longitude': longitude,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Coordinates updated successfully!")),
        );
        Navigator.pop(context); // Go back to the active users page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: User not found!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Vehicle Coordinates")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "User: ${widget.userName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveCoordinates,
                    child: const Text("Save Coordinates"),
                  ),
          ],
        ),
      ),
    );
  }
}
