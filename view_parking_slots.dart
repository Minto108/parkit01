import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewParkingSlots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parking Slots")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("parking_slots").orderBy("timestamp", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No parking slots available"));
          }

          var parkingSlots = snapshot.data!.docs;

          return ListView.builder(
            itemCount: parkingSlots.length,
            itemBuilder: (context, index) {
              var slot = parkingSlots[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text("Slot ${index + 1}"),
                  subtitle: Text(
                    "Upper Left: (${slot['x1']}, ${slot['y1']})\n"
                    "Upper Right: (${slot['x2']}, ${slot['y2']})\n"
                    "Lower Left: (${slot['x3']}, ${slot['y3']})\n"
                    "Lower Right: (${slot['x4']}, ${slot['y4']})",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection("parking_slots").doc(slot.id).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Parking slot deleted")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
