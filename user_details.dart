import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Extract startTime and endTime
    String startTimeStr = user['startTime'] ?? 'N/A';
    String endTimeStr = user['endTime'] ?? 'N/A';

    DateTime? startTime;
    DateTime? endTime;
    String duration = "N/A";

    try {
      // Convert startTime and endTime to DateTime objects
      if (startTimeStr != 'N/A') {
        startTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(startTimeStr);
      }
      if (endTimeStr != 'N/A' && user['endTime'] is String) {
        endTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(endTimeStr);
      } else if (endTimeStr != 'N/A' && user['endTime'] is Timestamp) {
        endTime = (user['endTime'] as Timestamp).toDate();
      }

      // Calculate duration
      if (startTime != null && endTime != null) {
        Duration diff = endTime.difference(startTime);
        int hours = diff.inHours;
        int minutes = diff.inMinutes % 60;
        duration = "$hours hrs $minutes min";
      }
    } catch (e) {
      print("Error parsing time: $e");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "User Information",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ),
                  const Divider(thickness: 1.5, height: 20),
                  _buildDetailRow("Tag No:", user['tagNo']),
                  _buildDetailRow("Vehicle No:", user['vehicleNumber']),
                  _buildDetailRow("Name:", user['name']),
                  _buildDetailRow("Phone:", user['phone']),
                  _buildDetailRow("Start Time:", startTimeStr),
                  _buildDetailRow("End Time:", endTimeStr),
                  _buildDetailRow("Duration:", duration),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
