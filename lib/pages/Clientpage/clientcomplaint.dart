import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintForm extends StatefulWidget {
  final String username;

  ComplaintForm({required this.username});

  @override
  _ComplaintFormState createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch name when the screen loads
  }

  Future<void> _fetchUserName() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('name')
          .eq('email', widget.username)
          .maybeSingle(); // Fetch a single row

      if (response != null && response['name'] != null) {
        setState(() {
          _nameController.text = response['name']; // Auto-fill name
        });
      } else {
        print('User not found or name is null.');
      }
    } catch (error) {
      print('Error fetching name: $error');
    }
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      print("Email (from_email): ${widget.username}");

      try {
        await supabase.from('complaints').insert({
          'name': _nameController.text, // Auto-filled from profiles
          'from_email': widget.username,
          'Complain': _complaintController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted successfully!')),
        );
        _complaintController.clear();
      } catch (error) {
        print("Insert error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint could not be submitted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit Complaint')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _complaintController,
                decoration: InputDecoration(labelText: 'Complaint'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your complaint' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitComplaint,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
