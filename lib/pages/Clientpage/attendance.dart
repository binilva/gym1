import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen(
      {super.key, required String username}); // ✅ Removed username parameter

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  DateTime currentMonth = DateTime.now();
  Map<String, bool> attendance = {};
  bool isLoading = false;
  String? userEmail; // ✅ Store logged-in user's email

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  // ✅ Fetch logged-in user's email
  Future<void> fetchUserEmail() async {
    setState(() => isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        userEmail = user.email;
        fetchAttendance(); // ✅ Fetch attendance once email is retrieved
      } else {
        throw "No user logged in!";
      }
    } catch (error) {
      print("❌ Error fetching user email: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ Fetch attendance data for the logged-in user
  Future<void> fetchAttendance() async {
    if (userEmail == null) return;
    setState(() => isLoading = true);

    try {
      int lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
      String startDate =
          "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-01";
      String endDate =
          "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-$lastDay";

      final response = await supabase
          .from('attendance')
          .select('date')
          .eq('email', userEmail!) // ✅ Use the logged-in user's email
          .gte('date', startDate)
          .lte('date', endDate);

      Map<String, bool> fetchedAttendance = {};
      for (var record in response) {
        if (record['date'] != null) {
          fetchedAttendance[record['date']] = true;
        }
      }

      if (mounted) {
        setState(() {
          attendance = fetchedAttendance;
        });
      }
    } catch (error) {
      print("❌ Error fetching attendance: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance - ${DateFormat('MMMM yyyy').format(currentMonth)}",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                currentMonth =
                    DateTime(currentMonth.year, currentMonth.month - 1, 1);
                fetchAttendance();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentMonth =
                    DateTime(currentMonth.year, currentMonth.month + 1, 1);
                fetchAttendance();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    userEmail != null ? "User: $userEmail" : "Loading...",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      String dateKey =
                          "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-${(index + 1).toString().padLeft(2, '0')}";
                      bool isMarked = attendance[dateKey] ?? false;

                      return Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isMarked ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isMarked ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
