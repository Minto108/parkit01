import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PastUsersPage extends StatelessWidget {
  const PastUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference pastUsersCollection = FirebaseFirestore.instance.collection('past_users');

    return Scaffold(
      appBar: AppBar(title: const Text('Past Users')),
      body: StreamBuilder<QuerySnapshot>(
        stream: pastUsersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No past users found'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text("Tag No: ${user['tagNo'] ?? 'N/A'}"),
                subtitle: Text("Vehicle No: ${user['vehicleNumber'] ?? 'N/A'}"),
              );
            },
          );
        },
      ),
    );
  }
}
