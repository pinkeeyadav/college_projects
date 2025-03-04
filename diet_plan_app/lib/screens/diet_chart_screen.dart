








import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'diet_chart.dart'; // Assuming this is where WeeklyDietChart is defined

class DietChartScreen extends StatefulWidget {
  const DietChartScreen({super.key});
  @override
  _DietChartScreenState createState() => _DietChartScreenState();
}

class _DietChartScreenState extends State<DietChartScreen> {
  List<Map<String, String>> weeklyDiet = [];
  bool isLoading = true; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    _fetchDietPlan();
  }

  @override
  void dispose() {
    // Perform any necessary cleanup here
    super.dispose();
  }

  Future<void> _fetchDietPlan() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        // Reference to Firestore
        final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

        // List of meal types
        final mealTypes = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

        // List of days of the week
        final daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

        // Clear the weeklyDiet list to prepare for new data
        weeklyDiet.clear();
        print('weeklyDiet cleared');

        for (final mealType in mealTypes) {
          for (final day in daysOfWeek) {
            final dayDoc = await userDoc.collection('dietPlan')
                .doc(mealType)
                .collection('days')
                .doc(day)
                .get();
             //   print('Fetching $mealType for $day');
            //print('Document data: ${dayDoc.data()}');

            if (dayDoc.exists) {
              final recipeTitle = dayDoc.data()?['recipeTitle'];
              final recipeId = dayDoc.data()?['recipeID'];
      
      // Check if recipeId is an int and convert it to String if necessary
      final recipeIdString = recipeId is int ? recipeId.toString() : recipeId;

      if (recipeTitle != null) {
        weeklyDiet.add({
          'recipeID': recipeIdString, 
                  'day': day,
                  'category': mealType,
                  'title': recipeTitle,
                });
              } else {
                weeklyDiet.add({
                  'day': day,
                  'category': mealType,
                  'title': 'No meal added',
                });
              }
            } else {
              weeklyDiet.add({
                'day': day,
                'category': mealType,
                'title': 'No meal added',
              });
            }
          }
        }

        print('Diet plan fetched successfully');
        if (mounted) { // Check if the widget is still mounted before calling setState
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching diet plan: $e');
      }
    } else {
      print('User ID is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          :  SingleChildScrollView(
              
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Weekly Diet Chart',
                      style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 8, 8, 8)),
                    ),
                    const SizedBox(height: 8),
                    WeeklyDietChart(weeklyDiet: weeklyDiet),
                  ],
                ),
              ),
        
    );
  }
}
