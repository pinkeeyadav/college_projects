import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyTracking extends StatefulWidget {
  const DailyTracking({super.key});

  @override
  State<DailyTracking> createState() => _DailyTrackingState();
}

class _DailyTrackingState extends State<DailyTracking> {
  DateTime _selectedDate = DateTime.now();
  double goalCalories = 0;
  double breakfastCalories = 0;
  double lunchCalories = 0;
  double snackCalories = 0;
  double dinnerCalories = 0;
  double consumedCalories = 0;
  bool isBreakfastChecked = false;
  bool isLunchChecked = false;
  bool isSnackChecked = false;
  bool isDinnerChecked = false;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userID = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchNutrientDataForSelectedDate();
  }

  // Convert date to 'YYYYMMDD' format for document ID
  String _formatDateForFirestore(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }

  // Fetch nutrient data for the selected date from Firestore
  Future<void> _fetchNutrientDataForSelectedDate() async {
    String dateId = _formatDateForFirestore(_selectedDate);

    // Fetch goal and meal-specific calories from the 'daily_intake' document
    DocumentSnapshot dailyIntakeSnapshot = await _firestore
        .collection('users')
        .doc(userID)
        .collection('nutrition_intake')
        .doc('daily_intake')
        .get();

    if (dailyIntakeSnapshot.exists) {
      setState(() {
        goalCalories = dailyIntakeSnapshot['calories'] ?? 0;
        breakfastCalories = dailyIntakeSnapshot['breakfastCalorie'] ?? 0;
        lunchCalories = dailyIntakeSnapshot['lunchCalorie'] ?? 0;
        snackCalories = dailyIntakeSnapshot['snacksCalorie'] ?? 0;
        dinnerCalories = dailyIntakeSnapshot['dinnerCalorie'] ?? 0;
      });
    }

    // Fetch consumed calories and checkbox states from the separate 'consumed_data' document
    DocumentSnapshot consumedDataSnapshot = await _firestore
        .collection('users')
        .doc(userID)
        .collection('daily_nutrients')
        .doc(dateId)
        .get();

    if (consumedDataSnapshot.exists) {
      setState(() {
        consumedCalories = consumedDataSnapshot['consumedCalories'] ?? 0;
        isBreakfastChecked = consumedDataSnapshot['isBreakfastChecked'] ?? false;
        isLunchChecked = consumedDataSnapshot['isLunchChecked'] ?? false;
        isSnackChecked = consumedDataSnapshot['isSnackChecked'] ?? false;
        isDinnerChecked = consumedDataSnapshot['isDinnerChecked'] ?? false;
      });
    } else {
      // If no data exists for consumed calories, set it to 0 and all checkboxes to false
      setState(() {
        consumedCalories = 0;
        isBreakfastChecked = false;
        isLunchChecked = false;
        isSnackChecked = false;
        isDinnerChecked = false;
      });
    }
  }

  // Save consumed calories and checkbox states for the selected date to Firestore
  Future<void> _saveConsumedCalories() async {
    String dateId = _formatDateForFirestore(_selectedDate);
    await _firestore
        .collection('users')
        .doc(userID)
        .collection('daily_nutrients')
        .doc(dateId)
        .set({
      'consumedCalories': consumedCalories,
      'isBreakfastChecked': isBreakfastChecked,
      'isLunchChecked': isLunchChecked,
      'isSnackChecked': isSnackChecked,
      'isDinnerChecked': isDinnerChecked,
    }, SetOptions(merge: true));
  }

  // Check if the selected date is the current day
  bool _isCurrentDay() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  // Go to the previous day
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _fetchNutrientDataForSelectedDate();
    });
  }

  // Go to the next day
  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _fetchNutrientDataForSelectedDate();
    });
  }

  // Build the pie chart
  Widget _buildPieChart() {
    double percentage = goalCalories > 0
        ? (consumedCalories / goalCalories) * 100
        : 0;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: consumedCalories,
                  color: Colors.green,
                  title: '${percentage.toStringAsFixed(1)}%',
                ),
                PieChartSectionData(
                  value: goalCalories - consumedCalories,
                  color: Colors.grey,
                  title: '',
                ),
              ],
              centerSpaceRadius: 50,
            ),
          ),
        ),
        Text(
          'Goal Completed: ${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Update the consumed calories based on checkboxes
  void _updateConsumedCalories() {
    double total = 0;
    if (isBreakfastChecked) total += breakfastCalories;
    if (isLunchChecked) total += lunchCalories;
    if (isSnackChecked) total += snackCalories;
    if (isDinnerChecked) total += dinnerCalories;

    setState(() {
      consumedCalories = total;
      _saveConsumedCalories(); // Save the updated consumed calories to Firestore
    });
  }

  // Build the checkbox list
  Widget _buildMealTypeCheckbox(
      String mealType, double mealCalories, bool isChecked, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: _isCurrentDay()
              ? (value) {
                  onChanged(value);
                  _updateConsumedCalories();
                }
              : null, // Disable for non-current days
        ),
        Text('$mealType'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d').format(_selectedDate);

    return  Container(
        margin: const EdgeInsets.all(18),
        color: const Color.fromARGB(255, 236, 241, 240),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text(
              'Daily Tracking',
              style: TextStyle(fontSize: 25, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Container(
              color: const Color.fromARGB(255, 141, 227, 150),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _goToPreviousDay,
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _goToNextDay,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPieChart(),
            const SizedBox(height: 20),
            if (_isCurrentDay())
              Column(
                children: [
                  _buildMealTypeCheckbox('Breakfast', breakfastCalories, isBreakfastChecked, (value) {
                    setState(() => isBreakfastChecked = value ?? false);
                  }),
                  _buildMealTypeCheckbox('Lunch', lunchCalories, isLunchChecked, (value) {
                    setState(() => isLunchChecked = value ?? false);
                  }),
                  _buildMealTypeCheckbox('Snacks', snackCalories, isSnackChecked, (value) {
                    setState(() => isSnackChecked = value ?? false);
                  }),
                  _buildMealTypeCheckbox('Dinner', dinnerCalories, isDinnerChecked, (value) {
                    setState(() => isDinnerChecked = value ?? false);
                  }),
                ],
              ),
          ],
        ),
      
    );
  }
}
