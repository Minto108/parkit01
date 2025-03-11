import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'user_details.dart';
import 'filter.dart';

class PastUsersPage extends StatefulWidget {
  const PastUsersPage({super.key});

  @override
  _PastUsersPageState createState() => _PastUsersPageState();
}

class _PastUsersPageState extends State<PastUsersPage> {
  FilterOption selectedFilter = FilterOption.all;

  @override
  Widget build(BuildContext context) {
    DateTime? filterDate = getFilterDate(selectedFilter);
    Query pastUsersQuery = FirebaseFirestore.instance.collection('past_users');

    if (filterDate != null) {
      pastUsersQuery = pastUsersQuery.where(
        'endTime',
        isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd HH:mm:ss').format(filterDate),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Users'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FilterPage(
                  selectedFilter: selectedFilter,
                  onFilterSelected: (FilterOption option) {
                    setState(() {
                      selectedFilter = option;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: pastUsersQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No past users found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index].data() as Map<String, dynamic>;

                // Parse endTime
                String endTimeFormatted = "N/A";
                if (user['endTime'] != null) {
                  try {
                    DateTime endTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(user['endTime']);
                    endTimeFormatted = DateFormat('yyyy-MM-dd hh:mm a').format(endTime);
                  } catch (e) {
                    print("Error parsing endTime: $e");
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
                        Text(
                          "Vehicle No: ${user['vehicleNumber'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Duration: ${user['duration'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Deactivated at: $endTimeFormatted",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailsPage(user: user),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.info, size: 18),
                            label: const Text("User Details"),
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
