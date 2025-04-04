import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  DateTime currentMonth = DateTime.now();
  String? selectedName;
  String? selectedEmail;
  List<Map<String, String>> availableProfiles = [];
  Map<String, Set<String>> attendance = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAvailableProfiles();
    fetchAttendance();
  }

  Future<void> fetchAvailableProfiles() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('profiles')
          .select('name, email')
          .eq('role', 'client');
      final profiles = response
          .map<Map<String, String>>(
            (record) => {
              'name': record['name'] as String,
              'email': record['email'] as String,
            },
          )
          .toList();
      setState(() {
        availableProfiles = profiles;
        isLoading = false;
      });
    } catch (error) {
      print("❌ Error fetching profiles: $error");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAttendance() async {
    setState(() => isLoading = true);
    try {
      int lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
      String startDate =
          "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-01";
      String endDate =
          "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-$lastDay";
      final response = await supabase
          .from('attendance')
          .select()
          .gte('date', startDate)
          .lte('date', endDate);
      Map<String, Set<String>> fetchedAttendance = {};
      for (var record in response) {
        String recordDate = record['date'];
        String name = record['name'];
        fetchedAttendance.putIfAbsent(recordDate, () => {});
        fetchedAttendance[recordDate]!.add(name);
      }
      if (mounted) {
        setState(() {
          attendance = fetchedAttendance;
          isLoading = false;
        });
      }
    } catch (error) {
      print("❌ Error fetching attendance: $error");
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleAttendance(String date) async {
    final today = DateTime.now();
    final tappedDate = DateTime.parse(date);

    // Disallow editing future dates
    if (tappedDate.isAfter(DateTime(today.year, today.month, today.day))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("You can only update today or past attendance.")),
      );
      return;
    }

    if (selectedName == null || selectedEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a user first.")),
      );
      return;
    }

    bool isMarked = attendance[date]?.contains(selectedName) ?? false;

    if (isMarked) {
      try {
        await supabase.from('attendance').delete().match({
          'date': date,
          'email': selectedEmail!,
        });
        setState(() {
          attendance[date]?.remove(selectedName);
          if (attendance[date]?.isEmpty ?? false) {
            attendance.remove(date);
          }
        });
        print("❌ Attendance removed for $selectedName on $date");
      } catch (error) {
        print("❌ Error removing attendance: $error");
      }
    } else {
      try {
        await supabase.from('attendance').insert({
          'date': date,
          'name': selectedName,
          'email': selectedEmail,
          'present': true,
        });
        setState(() {
          attendance.putIfAbsent(date, () => {});
          attendance[date]!.add(selectedName!);
        });
        print("✅ Attendance marked for $selectedName on $date");
      } catch (error) {
        print("❌ Error marking attendance: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final today = DateTime.now();

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
                currentMonth = DateTime(
                  currentMonth.year,
                  currentMonth.month - 1,
                  1,
                );
                fetchAttendance();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                currentMonth = DateTime(
                  currentMonth.year,
                  currentMonth.month + 1,
                  1,
                );
                fetchAttendance();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Select Name",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedName,
                    items: availableProfiles.map((profile) {
                      return DropdownMenuItem<String>(
                        value: profile['name'],
                        child: Text(profile['name']!),
                      );
                    }).toList(),
                    onChanged: (name) {
                      setState(() {
                        selectedName = name;
                        selectedEmail = availableProfiles.firstWhere(
                          (profile) => profile['name'] == name,
                        )['email'];
                      });
                    },
                  ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                String dateKey =
                    "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-${(index + 1).toString().padLeft(2, '0')}";
                bool isMarked =
                    attendance[dateKey]?.contains(selectedName) ?? false;

                final cellDate =
                    DateTime(currentMonth.year, currentMonth.month, index + 1);
                final isToday = today.year == currentMonth.year &&
                    today.month == currentMonth.month &&
                    today.day == index + 1;
                final isFuture = cellDate
                    .isAfter(DateTime(today.year, today.month, today.day));

                return GestureDetector(
                  onTap: isFuture ? null : () => toggleAttendance(dateKey),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isMarked
                          ? Colors.blue
                          : isFuture
                              ? Colors.grey.shade100
                              : isToday
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isToday ? Colors.black : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isMarked
                            ? Colors.white
                            : isFuture
                                ? Colors.grey
                                : Colors.black,
                      ),
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
