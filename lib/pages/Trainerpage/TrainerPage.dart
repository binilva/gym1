import 'package:flutter/material.dart';
import 'package:gym/pages/Trainerpage/members.dart';
import 'package:gym/pages/Trainerpage/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ChatBotPage.dart';
import '../../main.dart';
import '../Homepage/GymHomePage.dart';
import '../Trainerpage/attendance.dart';
import 'Addmembers.dart';
import 'ExercisePage.dart';
import 'PayPage.dart';

class TrainerPage extends StatelessWidget {
  final String username;

  TrainerPage({required this.username});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GymHomePage()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Page'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                _confirmLogout(context), // Show confirmation dialog
          ),
          IconButton(
            icon: const Icon(Icons.person_2_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilesScreen(
                      username: username), // ✅ Pass the username correctly
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Container with background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'images/back1.jpg',
                ), // Replace with your image path
                fit: BoxFit.cover, // Ensure the image covers the entire screen
              ),
            ),
          ),
          // Your scrollable content inside SingleChildScrollView
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Text(
                    'Welcome, $username!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ), // Adjust text color to ensure visibility on the background
                  ),
                  SizedBox(height: 50),
                  // Column to display circular buttons one below the other
                  Column(
                    children: [
                      // Circular Pay Button
                      GestureDetector(
                        onTap: () {
                          // Navigate to the Payment Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MemberPage()),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.payment,
                          color: Colors.green,
                          label: 'Members',
                          imageurl: "images/members.jpg",
                        ),
                      ),
                      SizedBox(height: 15), // Space between buttons
                      // Circular Exercise Button
                      GestureDetector(
                        onTap: () {
                          // Navigate to Exercise Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Addmembers(username: username),
                            ),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.shopping_cart,
                          color: Colors.blue,
                          label: 'Add Members',
                          imageurl: "images/addmem.png",
                        ),
                      ),
                      SizedBox(height: 15), // Space between buttons
                      // Additional Shop Button 2
                      GestureDetector(
                        onTap: () {
                          // Navigate to Shop Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentListView()),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.shopping_cart,
                          color: Colors.red,
                          label: 'Payment details',
                          imageurl: "images/payment.jpeg",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Shop Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AttendanceScreen()),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.shopping_cart,
                          color: Colors.yellow,
                          label: 'Attendance',
                          imageurl: "images/attend.jpg",
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          // Navigate to Exercise Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExercisePage(),
                            ),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.fitness_center,
                          color: Colors.orange,
                          label: 'Exercise',
                          imageurl: "images/exercies.jpg",
                        ),
                      ),
                      SizedBox(height: 15),
                      // Circular Shop Button
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            width: 100,
            height: 70,
            // Smaller size for the circle button
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBotPage()),
                );
              },
              child: Text(
                'AI',
                style: TextStyle(fontSize: 22, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
