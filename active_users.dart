import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Import Timer
import 'user_details.dart';
import 'new_users.dart';
import 'vehicle_coordinates.dart'; // Import the new page

class ActiveUsersPage extends StatefulWidget {
  const ActiveUsersPage({super.key});

  @override
  _ActiveUsersPageState createState() => _ActiveUsersPageState();
}

class _ActiveUsersPageState extends State<ActiveUsersPage> {
  late Timer _timer; // Timer to refresh UI every minute

  @override
  void initState() {
    super.initState();
    // Refresh UI every 60 seconds to update duration
    _timer = Timer.periodic(const Duration(seconds: 60), (Timer t) {
      setState(() {}); // Triggers UI refresh
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Query usersQuery =
        FirebaseFirestore.instance.collection('users').where('Active', isEqualTo: 'Yes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Users'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: usersQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error loading active users',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No active users found',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NewUserPage()),
                        );
                      },
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text('Go to New Users'),
                    ),
                  ],
                ),
              );
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userDoc = users[index];
                final user = userDoc.data() as Map<String, dynamic>;

                // Calculate duration dynamically
                String duration = "N/A";
                if (user['startTime'] != null) {
                  try {
                    DateTime startTime =
                        DateFormat('yyyy-MM-dd HH:mm:ss').parse(user['startTime']);
                    Duration diff = DateTime.now().difference(startTime);
                    int hours = diff.inHours;
                    int minutes = diff.inMinutes % 60;
                    duration = "$hours hrs $minutes min";
                  } catch (e) {
                    print("Error parsing start time: $e");
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tag No: ${user['tagNo'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("Vehicle No: ${user['vehicleNumber'] ?? 'N/A'}"),
                        const SizedBox(height: 4),
                        Text(
                          "Duration: $duration",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // User Details Button
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserDetailsPage(user: user),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info, size: 18),
                              label: const Text("User Details"),
                            ),

                            // Enter Coordinates Button (Updated to Pass User Name)
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VehicleCoordinatesPage(
                                      userName: user['name'] ?? 'Unknown',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.location_on, size: 18),
                              label: const Text("Enter Coordinates"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Center(
                          // Deactivate User Button
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                // Move user to 'past_users' with duration and end time
                                await FirebaseFirestore.instance
                                    .collection('past_users')
                                    .doc(users[index].id)
                                    .set({
                                  ...user,
                                  'duration': duration,
                                  'endTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                                });

                                // Remove from 'users' collection
                                await users[index].reference.delete();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("User moved to past users and removed from active users!")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            },
                            icon: const Icon(Icons.cancel, size: 18),
                            label: const Text("Deactivate"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
