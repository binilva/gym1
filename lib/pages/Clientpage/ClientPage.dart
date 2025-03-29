import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../Homepage/GymHomePage.dart';
import 'ExercisePage1.dart';
import 'PayPage1.dart';
import 'ShopPage1.dart';
import 'attendance.dart';

class ClientPage extends StatelessWidget {
  final String username;

  ClientPage({required this.username});

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
        title: Text('Client Page'),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                _confirmLogout(context), // Show confirmation dialog
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
                            MaterialPageRoute(builder: (context) => PayPage1()),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.payment,
                          color: Colors.green,
                          label: 'Pay',
                          imageurl: "images/payment.jpeg",
                        ),
                      ),
                      SizedBox(height: 15),
                      // Circular Exercise Button
                      GestureDetector(
                        onTap: () {
                          // Navigate to Exercise Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExercisesScreen(),
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
                      GestureDetector(
                        onTap: () {
                          // Navigate to Shop Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShopPage1()),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.shopping_cart,
                          color: Colors.blue,
                          label: 'Shop',
                          imageurl: "images/shop.png",
                        ),
                      ),
                      SizedBox(height: 15),
                      // Additional Shop Button 2
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
                          icon: Icons.person_2_outlined,
                          color: Colors.red,
                          label: 'Your attendance',
                          imageurl: "images/attendance.webp",
                        ),
                      ),
                      SizedBox(height: 15),

                      GestureDetector(
                        onTap: () {
                          // Navigate to Shop Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShopPage1()),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.shopping_cart,
                          color: Colors.blue,
                          label: 'Posture',
                          imageurl: "images/posture.jpg",
                        ),
                      ),
                      SizedBox(height: 15),

                      // Additional Shop Button 3
                    ],
                  ),
                ],
              ),
            ),
          ),
          // The AI Button that stays fixed at the bottom-right corner
          Positioned(
            bottom: 20,
            right: 20,
            width: 100,
            height: 70,
            // Smaller size for the circle button
            child: ElevatedButton(
              onPressed: () {
                // Define your AI button action here
                print("AI Button Pressed!");
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
