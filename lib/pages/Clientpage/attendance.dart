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
  Map<String, Map<String, bool>> attendance = {};
  bool isLoading = false;
  List<String> selectedNames = [];
  List<String> availableNames = [];

  @override
  void initState() {
    super.initState();
    fetchAvailableNames();
  }

  Future<void> fetchAvailableNames() async {
    try {
      final response = await supabase.from('attendance').select('name');

      final List<String> uniqueNames = response
          .map<String>((record) => record['name'] as String)
          .toSet()
          .toList();

      setState(() {
        availableNames = uniqueNames;
      });
    } catch (error) {
      print("❌ Error fetching names: $error");
    }
  }

  Future<void> fetchAttendance() async {
    if (selectedNames.isEmpty) {
      print("❌ No names selected.");
      return;
    }

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
          .inFilter('name', selectedNames)
          .gte('date', startDate)
          .lte('date', endDate);

      Map<String, Map<String, bool>> fetchedAttendance = {};
      for (var record in response) {
        String recordDate = record['date'];
        String name = record['name'];
        bool isPresent = record['present'] == true;

        fetchedAttendance.putIfAbsent(recordDate, () => {});
        fetchedAttendance[recordDate]![name] = isPresent;
      }

      if (mounted) {
        setState(() {
          attendance = fetchedAttendance;
          isLoading = false;
        });
      }
    } catch (error) {
      print("❌ Error fetching attendance: $error");
      if (mounted) setState(() => isLoading = false);
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
            child: StatefulBuilder(
              builder: (context, setStateDropdown) {
                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Select Name",
                    border: OutlineInputBorder(),
                  ),
                  items: availableNames.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (name) {
                    if (name != null && !selectedNames.contains(name)) {
                      setStateDropdown(() {
                        selectedNames.add(name);
                      });
                      setState(() {
                        fetchAttendance();
                      });
                    }
                  },
                );
              },
            ),
          ),
          Wrap(
            children: selectedNames.map((name) {
              return Chip(
                label: Text(name),
                onDeleted: () {
                  setState(() {
                    selectedNames.remove(name);
                    fetchAttendance();
                  });
                },
              );
            }).toList(),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      String dateKey =
                          "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}-${(index + 1).toString().padLeft(2, '0')}";
                      List<String> presentNames =
                          attendance[dateKey]?.keys.toList() ?? [];

                      return Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: presentNames.isNotEmpty
                              ? Colors.blue
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (presentNames.isNotEmpty)
                              ...presentNames.map(
                                (name) => Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
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
