import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Clientpage/ClientPage.dart';
import '../Owner/OwnerPage.dart';
import '../Trainerpage/TrainerPage.dart';
import 'ForgotPasswordPage.dart';
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  final bool isTrainer;
  final bool isOwner;

  const LoginPage({super.key, required this.isTrainer, required this.isOwner});

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

        // ✅ Fetch role from the Supabase database
        final roleResponse = await _supabase
            .from('profiles')
            .select('role')
            .eq('user_id', userId)
            .maybeSingle(); // Use maybeSingle() to avoid crashes

        if (roleResponse == null || !roleResponse.containsKey('role')) {
          print("ERROR: No role assigned to user!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your account has no assigned role.')),
          );
          await _supabase.auth.signOut(); // Log out user to prevent access
          setState(() => isLoading = false);
          return;
        }

        final role = roleResponse['role'].toLowerCase(); // Normalize role
        print("DEBUG: Logged-in user role: $role");

        // ✅ Navigate based on user role
        if (role == 'trainer' && widget.isTrainer) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TrainerPage(username: response.user!.email!),
            ),
          );
        } else if (role == 'client' && !widget.isTrainer && !widget.isOwner) {
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
        } else {
          print("ERROR: Unauthorized login attempt.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unauthorized login attempt!')),
          );
          await _supabase.auth.signOut(); // Log out user to prevent access
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
    } else {
      title = "Client Login";
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
