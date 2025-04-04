import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberList extends StatefulWidget {
  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> profiles = [];

  @override
  void initState() {
    super.initState();
    fetchProfiles();
  }

  /// Fetch clients and trainers from the profiles table
  Future<void> fetchProfiles() async {
    try {
      final response = await supabase.from('profiles').select().or(
          'role.eq.client,role.eq.trainer'); // ✅ Fetch both client & trainer

      setState(() {
        profiles = response;
      });
    } catch (error) {
      print("Error fetching profiles: $error");
    }
  }

  /// Delete a profile from Supabase
  Future<void> deleteProfile(String userId) async {
    try {
      await supabase.from('profiles').delete().eq('user_id', userId);
      setState(() {
        profiles.removeWhere((profile) => profile['user_id'] == userId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile deleted successfully!')),
      );
    } catch (error) {
      print("Error deleting profile: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clients & Trainers')),
      body: profiles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(profile['name'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(profile['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(profile['role'],
                            style: TextStyle(color: Colors.blue)),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteProfile(
                              profile['user_id']), // 🔥 Delete profile
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
