import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Adminpage/AdminPage.dart';
import '../Clientpage/ClientPage.dart';
import '../Owner/OwnerPage.dart';
import '../Trainerpage/TrainerPage.dart';
import 'ForgotPasswordPage.dart';
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  final bool isTrainer;
  final bool isOwner;
  final bool isClient;
  final bool isAdmin;

  const LoginPage({
    super.key,
    required this.isTrainer,
    required this.isOwner,
    required this.isClient,
    required this.isAdmin,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        final userId = response.user!.id;

        final roleResponse = await _supabase
            .from('profiles')
            .select('role')
            .eq('user_id', userId)
            .maybeSingle();

        if (roleResponse == null || !roleResponse.containsKey('role')) {
          print("ERROR: No role assigned to user!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your account has no assigned role.')),
          );
          await _supabase.auth.signOut();
          setState(() => isLoading = false);
          return;
        }

        final role = roleResponse['role'].toLowerCase();
        print("DEBUG: Logged-in user role: $role");

        if (role == 'trainer' && widget.isTrainer) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TrainerPage(username: response.user!.email!),
            ),
          );
        } else if (role == 'client' && widget.isClient) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ClientPage(username: response.user!.email!),
            ),
          );
        } else if (role == 'owner' && widget.isOwner) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OwnerPage(username: response.user!.email!),
            ),
          );
        } else if (role == 'admin' && widget.isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Adminpage(
                  username: response.user!
                      .email!), // You can change to AdminPage if you have one
            ),
          );
        } else {
          print("ERROR: Unauthorized login attempt.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unauthorized login attempt!')),
          );
          await _supabase.auth.signOut();
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Try again.')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.isOwner) {
      title = "Owner Login";
    } else if (widget.isTrainer) {
      title = "Trainer Login";
    } else if (widget.isClient) {
      title = "Client Login";
    } else if (widget.isAdmin) {
      title = "Admin Login";
    } else {
      title = "Login";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                );
              },
              child: const Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}
