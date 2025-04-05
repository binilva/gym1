import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Addmembers extends StatefulWidget {
  final String username; // <-- username is received here

  const Addmembers({Key? key, required this.username}) : super(key: key);

  @override
  _AddmembersState createState() => _AddmembersState();
}

class _AddmembersState extends State<Addmembers> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String _selectedRole = 'client';

  @override
  void initState() {
    super.initState();
    print(
        "👤 Received username in initState: ${widget.username}"); // ✅ Should print!
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Age is required';
    int? age = int.tryParse(value);
    if (age == null || age < 18) return 'You must be at least 18 years old';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b';
    if (!RegExp(pattern).hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);

      try {
        // ✅ Use widget.username to fetch gym_name
        final trainerEmail = widget.username.trim().toLowerCase();
        print("🔍 Fetching gym_name for trainer email: $trainerEmail");

        final trainerProfile = await _supabase
            .from('profiles')
            .select('gym_name')
            .eq('email', trainerEmail)
            .maybeSingle();

        print("✅ Fetched trainer profile: $trainerProfile");

        final gymName = trainerProfile?['gym_name'] ?? 'Unknown Gym';

        // ✅ Sign up new user
        final response = await _supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final userId = response.user?.id;
        final userEmail = response.user?.email;

        if (userId == null || userEmail == null) {
          throw Exception("User creation failed. Please try again.");
        }

        // Delay to ensure `auth.users` is synced
        await Future.delayed(const Duration(seconds: 2));

        // ✅ Insert into profiles table
        await _supabase.from('profiles').insert({
          'user_id': userId,
          'email': userEmail,
          'name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'role': _selectedRole,
          'gym_name': gymName,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Created! Check your email to verify.'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        print("❌ Error: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.indigo[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validateAge,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                  DropdownMenuItem(value: 'trainer', child: Text('trainer')),
                ],
                onChanged: (value) {
                  setState(() => _selectedRole = value!);
                },
                decoration: const InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signUp,
                      child: const Text('Create Account'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
