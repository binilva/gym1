import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintsList extends StatefulWidget {
  @override
  _ComplaintsListState createState() => _ComplaintsListState();
}

class _ComplaintsListState extends State<ComplaintsList> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> complaints = []; // Store complaints

  @override
  void initState() {
    super.initState();
    _fetchComplaints(); // Fetch complaints when the page loads
  }

  Future<void> _fetchComplaints() async {
    try {
      final response =
          await supabase.from('complaints').select('*'); // Fetch all complaints

      if (response.isNotEmpty) {
        setState(() {
          complaints = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (error) {
      print("Error fetching complaints: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complaints List')),
      body: complaints.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(complaint['name'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${complaint['from_email']}'),
                        SizedBox(height: 5),
                        Text('Complaint: ${complaint['Complain']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
