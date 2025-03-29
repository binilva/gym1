import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class member extends StatefulWidget {
  @override
  _memberState createState() => _memberState();
}

class _memberState extends State<member> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> profiles = [];

  @override
  void initState() {
    super.initState();
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    final response =
        await supabase.from('profiles').select().eq('role', 'client');
    setState(() {
      profiles = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supabase Clients'),
      ),
      body: profiles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return ListTile(
                  title: Text(profile['name']),
                  subtitle: Text(profile['email']),
                  trailing: Text(profile['role']),
                );
              },
            ),
    );
  }
}
