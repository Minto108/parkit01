import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewParkingSpace extends StatefulWidget {
  @override
  _NewParkingSpaceState createState() => _NewParkingSpaceState();
}

class _NewParkingSpaceState extends State<NewParkingSpace> {
  final TextEditingController x1Controller = TextEditingController();
  final TextEditingController y1Controller = TextEditingController();
  final TextEditingController x4Controller = TextEditingController();
  final TextEditingController y4Controller = TextEditingController();

  Future<void> calculateAndSave() async {
  double x1 = double.tryParse(x1Controller.text) ?? 0.0;
  double y1 = double.tryParse(y1Controller.text) ?? 0.0;
  double x4 = double.tryParse(x4Controller.text) ?? 0.0;
  double y4 = double.tryParse(y4Controller.text) ?? 0.0;

  // ✅ Use correct Flask URL for Emulator
  String flaskUrl = "http://10.0.2.2:5000/calculate_rectangle";

  print("Sending request to Flask: x1=$x1, y1=$y1, x4=$x4, y4=$y4");
  print("Flask API URL: $flaskUrl");

  try {
    var response = await http.post(
      Uri.parse(flaskUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"x1": x1, "y1": y1, "x4": x4, "y4": y4}),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      double x2 = data["x2"];
      double y2 = data["y2"];
      double x3 = data["x3"];
      double y3 = data["y3"];

      print("Received from Flask: x2=$x2, y2=$y2, x3=$x3, y3=$y3");

      // ✅ Save to Firebase
      await FirebaseFirestore.instance.collection("parking_slots").add({
        "x1": x1, "y1": y1,
        "x2": x2, "y2": y2,
        "x3": x3, "y3": y3,
        "x4": x4, "y4": y4,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Parking slot added successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Flask API call failed! Check logs.")),
      );
    }
  } catch (e) {
    print("Error calling Flask API: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to connect to server.")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Parking Space")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: x1Controller, decoration: InputDecoration(labelText: "Upper Left X")),
            TextField(controller: y1Controller, decoration: InputDecoration(labelText: "Upper Left Y")),
            TextField(controller: x4Controller, decoration: InputDecoration(labelText: "Lower Right X")),
            TextField(controller: y4Controller, decoration: InputDecoration(labelText: "Lower Right Y")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateAndSave,
              child: Text("Calculate & Save"),
            ),
          ],
        ),
      ),
    );
  }
}
