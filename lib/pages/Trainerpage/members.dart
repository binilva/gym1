import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> profiles = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    try {
      final List<dynamic> response = await supabase
          .from('profiles')
          .select()
          .eq('role', 'client')
          .order('name', ascending: true);

      setState(() {
        profiles = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load profiles: $e';
        isLoading = false;
      });
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      await supabase.from('profiles').delete().eq('user_id', userId);
      setState(() {
        profiles.removeWhere((profile) => profile['user_id'] == userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member removed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove member: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supabase Clients'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : profiles.isEmpty
          ? Center(child: Text('No clients found.'))
          : RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          await fetchProfiles();
        },
        child: ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return ListTile(
              title: Text(profile['name'] ?? 'No name'),
              subtitle: Text(profile['email'] ?? 'No email'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  removeMember(profile['user_id']);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
