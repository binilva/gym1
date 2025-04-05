import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Addmembers extends StatefulWidget {
  @override
  _Addmembers createState() => _Addmembers();
}

class _Addmembers extends State<Addmembers> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _gymNameController = TextEditingController();

  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Validators
  String? _validateName(String? value) =>
      value == null || value.isEmpty ? 'Name is required' : null;

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Age is required';
    final age = int.tryParse(value);
    if (age == null || age < 18) return 'Must be at least 18 years old';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b';
    if (!RegExp(pattern).hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters required';
    return null;
  }

  String? _validateGymName(String? value) =>
      value == null || value.isEmpty ? 'Gym name is required' : null;

  // Sign up and insert into profiles
  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      final response = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        await _supabase.from('profiles').insert({
          'user_id': response.user!.id,
          'email': response.user!.email,
          'name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'role': 'owner',
          'gym_name': _gymNameController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Owner account created. Check your email for verification.')),
        );
        Navigator.pop(context);
      } else {
        throw Exception("User creation failed.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Owner Account'),
        backgroundColor: Colors.indigo[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validateAge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gymNameController,
                decoration: const InputDecoration(
                  labelText: 'Gym Name',
                  border: OutlineInputBorder(),
                ),
                validator: _validateGymName,
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signUp,
                      child: const Text('Create Owner Account'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
