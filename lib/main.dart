import 'package:flutter/material.dart';
import 'package:gym/pages/Clientpage/ClientPage.dart';
import 'package:gym/pages/Clientpage/cart_provider.dart';
import 'package:gym/pages/Homepage/GymHomePage.dart';
import 'package:gym/pages/Trainerpage/TrainerPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zajdlwpkfzclakggrbpk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InphamRsd3BrZnpjbGFrZ2dyYnBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MjYxODUsImV4cCI6MjA1NzUwMjE4NX0.lQMt2o2aZNRtNJVJs4UlP-qA17CE3a6zBto24Ho19ZM', // Store securely instead of hardcoding
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()), // Cart Provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Widget> _homePage;

  @override
  void initState() {
    super.initState();
    _homePage = _redirectUserBasedOnRole();

    // Listen for authentication changes and refresh UI
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      setState(() {
        _homePage = _redirectUserBasedOnRole(); // Refresh role check when user logs in/out
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _homePage,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()), // Show loading
            );
          }
          if (snapshot.hasError) {
            return GymHomePage(); // Fallback in case of an error
          }
          return snapshot.data ?? GymHomePage();
        },
      ),
    );
  }

  // Fetch role from Supabase and redirect user accordingly
  Future<Widget> _redirectUserBasedOnRole() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session == null) {
      print("DEBUG: No session found! Redirecting to GymHomePage.");
      return GymHomePage(); // If no session, go to home page
    }

    final userId = session.user.id;
    print("DEBUG: Fetching role for user ID: $userId");

    try {
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('user_id', userId)
          .maybeSingle(); // Prevents crashes

      print("DEBUG: Supabase response: $response");

      // ❌ If role is null or empty, deny access
      if (response == null || !response.containsKey('role') || response['role'] == null) {
        print("ERROR: User has NO assigned role! Redirecting to GymHomePage.");
        return GymHomePage(); // Prevent access if no role
      }

      final role = response['role'];
      print("DEBUG: User Role = $role");

      // ✅ Strict Role Checking
      if (role == 'trainer') {
        print("DEBUG: Redirecting to TrainerPage.");
        return TrainerPage(username: session.user.email!);
      } else if (role == 'client') {
        print("DEBUG: Redirecting to ClientPage.");
        return ClientPage(username: session.user.email!);
      } else {
        print("ERROR: Invalid role: $role. Redirecting to GymHomePage.");
        return GymHomePage();
      }
    } catch (e) {
      print("ERROR: Fetching user role failed: $e");
      return GymHomePage(); // Fallback in case of an error
    }
  }
}

class CircleButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String label;
  final String imageurl;

  CircleButton({
    required this.icon,
    this.color,
    required this.label,
    required this.imageurl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.height,
          // Smaller size for the circle button
          height: MediaQuery.of(context).size.height * .85 / 5,

          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imageurl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(30),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Check if imageUrl is provided, if so show the image, else show the icon
              SizedBox(height: 5),
              Text(label, style: TextStyle(fontSize: 22, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}