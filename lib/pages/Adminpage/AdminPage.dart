import 'package:flutter/material.dart';
import 'package:gym/ChatBotPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../Homepage/GymHomePage.dart';
import 'addgym.dart';
import 'profile.dart';
import 'updateprofile.dart';

class Adminpage extends StatelessWidget {
  final String username;

  Adminpage({required this.username});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
        title: const Text('Admin Page'),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/back1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Welcome, $username!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Addmembers()),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.payment,
                          color: Colors.green,
                          label: 'ADD GYM',
                          imageurl: "images/members.jpg",
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UpdateProfilesScreen(
                                      username: '',
                                    )),
                          );
                        },
                        child: CircleButton(
                          icon: Icons.payment,
                          color: Colors.green,
                          label: 'UPDATE PROFILE',
                          imageurl: "images/members.jpg",
                        ),
                      ),
                      const SizedBox(height: 15),
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
