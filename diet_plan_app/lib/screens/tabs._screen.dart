import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_plan_app/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diet_plan_app/Widgets/main_drawer.dart';
import 'package:diet_plan_app/Widgets/meals_card.dart';
import 'package:diet_plan_app/daily_nutrition_display.dart';
import 'package:diet_plan_app/screens/diet_chart_screen.dart';
import 'package:diet_plan_app/screens/progress.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  // Firebase Firestore and Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch user nutrition data from Firestore
  Future<Map<String, dynamic>> _fetchUserNutritionData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).collection('nutrition_intake').doc('daily_intake').get();
        if (docSnapshot.exists) {
          return docSnapshot.data()!;
        }
      }
    } catch (e) {
      print('Error fetching nutrition data: $e');
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      drawer: const MainDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserNutritionData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error fetching data'));
          }

          final userData = snapshot.data!;
          double cal = userData['calories'] ?? 0;
          double pr = userData['protein'] ?? 0;
          double carb = userData['carbs'] ?? 0;
          double fats = userData['fat'] ?? 0;

          // Assign different widgets based on the selected tab
          Widget activeScreen = SingleChildScrollView(
            child: Column(
              children: [
                DailyNutritionDisplay(
                    caloriesGoal: cal, protein: pr, carbs: carb, fat: fats),
                const SizedBox(height: 15),
                MealsCard(calorie: cal, protein: pr, carbs: carb, fats: fats),
              ],
            ),
          );

          if (_selectedPageIndex == 1) {
            activeScreen = DietChartScreen();
          }

          if (_selectedPageIndex == 2) {
            activeScreen = Progress(
              calories: cal,
              protein: pr,
              carbs: carb,
              fat: fats,
            );
          }

          if (_selectedPageIndex == 3) {
            activeScreen = const ProfileScreen();
          }

          return activeScreen;
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.green[800], // Active icon color
            unselectedItemColor:
                const Color.fromARGB(255, 49, 44, 44), // Inactive icon color
            currentIndex: _selectedPageIndex,
            onTap: _selectPage,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.food_bank_sharp,
                  ),
                  label: 'Diet Chart'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.call_missed_outgoing_outlined),
                  label: 'Progress'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
