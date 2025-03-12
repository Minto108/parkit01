import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:parkit02/pages/new_parking_space.dart';
import 'package:parkit02/pages/view_parking_slots.dart';
import 'active_users.dart';
import 'past_users.dart';
import 'new_users.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> imgList = [
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
  ];

  final int userCount = 150;

  final List<Map<String, String>> notifications = [
    {"title": "New User", "body": "A new user has registered."},
    {"title": "Parking Alert", "body": "Parking is full in Zone A."},
    {"title": "System Update", "body": "The app has been updated."},
  ];

  void showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const Divider(),
              notifications.isEmpty
                  ? const Center(child: Text('No Notifications', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          leading: const Icon(Icons.notifications, color: Colors.deepPurple),
                          title: Text(notification["title"]!),
                          subtitle: Text(notification["body"]!),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child:  Text(
            'ParkIt',style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = ui.Gradient.linear(
                                const Offset(100, 30),
                                const Offset(200, 20),
                                [Colors.black, Colors.grey],
                              ),
                          ),
        )
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => showNotificationsBottomSheet(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
                  height: 250,
                  child: 
                DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Welcome, User!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = ui.Gradient.linear(
                                const Offset(0, 20),
                                const Offset(200, 20),
                                [Colors.yellow, Colors.orangeAccent],
                              ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Enjoy your experience!',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.deepPurple),
              title: const Text('Home'),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.deepPurple),
              title: const Text('New Users'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NewUserPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.deepPurple),
              title: const Text('Active Users'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveUsersPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.deepPurple),
              title: const Text('Past Users'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PastUsersPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.square, color: Colors.deepPurple),
              title: const Text('New Parking Slot'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  NewParkingSpace()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.deepPurple), // New ListTile
              title: const Text('View Parking Slots'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewParkingSlots()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider(
              options: CarouselOptions(autoPlay: true, aspectRatio: 9 / 16, viewportFraction: 1.0),
              items: imgList.map((item) => Image.asset(item, fit: BoxFit.cover)).toList(),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total Users', style: TextStyle(fontSize: 24, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text('$userCount', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
