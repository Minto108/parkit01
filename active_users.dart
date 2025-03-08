import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveUsersPage extends StatelessWidget {
  const ActiveUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(title: const Text('Active Users')),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.where('Active', isEqualTo: 'Yes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No active users found'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text("Tag No: ${user['tagNo'] ?? 'N/A'}"),
                subtitle: Text("Vehicle No: ${user['vehicleNumber'] ?? 'N/A'}"),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('past_users').doc(users[index].id).set(user);
                    await users[index].reference.update({'Active': 'No'});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Deactivate"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
