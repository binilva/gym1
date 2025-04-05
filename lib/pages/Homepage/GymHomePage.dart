import 'package:flutter/material.dart';

import 'LoginPage.dart';

class GymHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Management System',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
      ),
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              'images/jym1.jpg', // Replace with your actual asset path
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),

          // ✅ Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text('Are you a Trainer or a Client?',
                    style: TextStyle(fontSize: 25, color: Colors.white)),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage(
                                isTrainer: false,
                                isOwner: false,
                                isAdmin: false,
                                isClient: true,
                              )),
                    );
                  },
                  child: const Text('Client', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage(
                                isOwner: false,
                                isTrainer: true,
                                isClient: false,
                                isAdmin: false,
                              )),
                    );
                  },
                  child: const Text('Trainer', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage(
                                isOwner: true,
                                isTrainer: false,
                                isClient: false,
                                isAdmin: false,
                              )),
                    );
                  },
                  child: const Text('Owner', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage(
                                isOwner: false,
                                isTrainer: false,
                                isClient: false,
                                isAdmin: true,
                              )),
                    );
                  },
                  child: const Text('Admin', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
