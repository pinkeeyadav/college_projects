import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyTrackingBarChart extends StatefulWidget {
  final double goalCalories;

  const WeeklyTrackingBarChart({
    super.key,
    required this.goalCalories,
  });

  @override
  _WeeklyTrackingBarChartState createState() => _WeeklyTrackingBarChartState();
}

class _WeeklyTrackingBarChartState extends State<WeeklyTrackingBarChart> {
  DateTime? _selectedWeekStart;
  Map<String, double> _consumedCalories = {};
  bool _isLoading = true;
  StreamSubscription? _calorieStreamSubscription;
  String? userID;

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = _getStartOfWeek(DateTime.now());
    _initializeUserAndListener();
  }

  // Fetch userID and set up a real-time listener
  Future<void> _initializeUserAndListener() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userID = currentUser.uid;
      _setupRealtimeListener();
    } else {
      setState(() {
        _isLoading = false;
      });
      print("User not authenticated");
    }
  }

  // Get start date of the current week
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  // Get end date of the current week
  DateTime _getEndOfWeek(DateTime startOfWeek) {
    return startOfWeek.add(Duration(days: 6));
  }

  // Set up a real-time listener for changes in daily consumed calories
  void _setupRealtimeListener() {
    if (userID == null) return; // Ensure userID is available

    final DateTime endOfWeek = _selectedWeekStart!.add(Duration(days: 6));

    _calorieStreamSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('daily_nutrients')
        .where(FieldPath.documentId,
            isGreaterThanOrEqualTo:
                DateFormat('yyyyMMdd').format(_selectedWeekStart!),
            isLessThanOrEqualTo: DateFormat('yyyyMMdd').format(endOfWeek))
        .snapshots()
        .listen((snapshot) {
      Map<String, double> updatedCalories = {};
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          try {
            // Safely parse the document ID as a date using substring
            String docId = doc.id;
            DateTime docDate = DateTime(
              int.parse(docId.substring(0, 4)), // Year
              int.parse(docId.substring(4, 6)), // Month
              int.parse(docId.substring(6, 8)), // Day
            );
            String dayOfWeek = DateFormat('EEE').format(docDate);

            final data = doc.data();
            if (data != Null && data.containsKey('consumedCalories')) {
              updatedCalories[dayOfWeek] =
                  (data['consumedCalories'] as num).toDouble();
              //  print('Consumed calories for $dayOfWeek: ${updatedCalories[dayOfWeek]}');
            }
          } catch (e) {
            // Log the error for debugging purposes
            print('Error parsing date for document ID ${doc.id}: $e');
          }
        }
      }

      setState(() {
        _consumedCalories = updatedCalories;
        _isLoading = false;
      });
    }, onError: (error) {
      print('Error listening to Firestore: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Navigate to previous or next week
  void _changeWeek(bool isNext) {
    setState(() {
      _selectedWeekStart = isNext
          ? _selectedWeekStart!.add(Duration(days: 7))
          : _selectedWeekStart!.subtract(Duration(days: 7));
      _isLoading = true;
      _setupRealtimeListener(); // Fetch new data for the updated week
    });
  }

  // Cleanup the real-time listener when the widget is disposed
  @override
  void dispose() {
    _calorieStreamSubscription?.cancel();
    super.dispose();
  }

  // Build the bar chart for weekly calorie tracking
  List<BarChartGroupData> _buildBarGroups() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return List.generate(7, (index) {
      // Get the consumed calories for the current day from _consumedCalories map
      final consumed =
          _consumedCalories[days[index]] ?? 0; // Defaults to 0 if not found
      // print('Consumed calories for ${days[index]}: $consumed');  // Debugging print

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: widget.goalCalories, // Set the full height to the goal
            color: Colors.grey[300], // Background color (grey)
            width: 22,
            rodStackItems: [
              // Stack the consumed part in green and the remaining part in grey
              BarChartRodStackItem(
                  0, consumed, Colors.green), // Consumed calories in green
              BarChartRodStackItem(consumed, widget.goalCalories,
                  Colors.grey), // Remaining in grey
            ],
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    final weekRangeText =
        '${DateFormat('dd MMM').format(_selectedWeekStart!)} - '
        '${DateFormat('dd MMM').format(_getEndOfWeek(_selectedWeekStart!))}';

    return Container(
      margin: const EdgeInsets.all(10),
      color: const Color.fromARGB(255, 236, 241, 240),
      child: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            'Weekly Calorie Tracking',
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
          Text(
            'Average calorie goal: ${widget.goalCalories.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Weekly navigation bar with arrows
          Container(
            color: const Color.fromARGB(255, 141, 227, 150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _changeWeek(false), // Previous week
                ),
                Text(weekRangeText, style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _changeWeek(true), // Next week
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bar chart for the week
          _isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      maxY: widget.goalCalories,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: widget.goalCalories / 5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()} kcal',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(
                              showTitles:
                                  false), // Disable right vertical titles
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: false), // Disable top titles
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'Sun',
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat'
                              ];
                              return Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      barGroups: _buildBarGroups(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
