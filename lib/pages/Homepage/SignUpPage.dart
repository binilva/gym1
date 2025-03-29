import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool isLoading = false;
  String _selectedRole = 'client'; // Default role selection

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        final insertResponse = await _supabase.from('profiles').insert({
          'user_id': response.user!.id,
          'email': response.user!.email,
          'role': _selectedRole, // Store selected role (trainer or client)
        }).select().single();

        // ✅ Ensure role is actually stored
        if (insertResponse['role'] == null) {
          throw Exception("Failed to assign role. Try again.");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check your email to verify your account.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
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

            // Dropdown to select role (Trainer or Client)
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: [
                DropdownMenuItem(value: 'client', child: Text('Client')),
                DropdownMenuItem(value: 'trainer', child: Text('Trainer')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Role',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _signUp,
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}