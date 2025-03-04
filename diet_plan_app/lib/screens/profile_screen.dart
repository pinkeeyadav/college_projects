import 'package:diet_plan_app/screens/dietry_needs_prefrences_screen.dart';
import 'package:diet_plan_app/screens/personal_details_screen.dart';
import 'package:diet_plan_app/screens/set_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  int age = 0;
  double currentWeight = 0.0;
  String goal = '';

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? '';

            // Safely handle age conversion from Firestore
            age = userDoc['age'] is String 
                ? int.tryParse(userDoc['age']) ?? 0 
                : (userDoc['age'] ?? 0).toInt();

            // Safely handle currentWeight conversion from Firestore
            currentWeight = userDoc['weight'] is String
                ? double.tryParse(userDoc['weight']) ?? 0.0
                : (userDoc['weight'] ?? 0).toDouble();

            goal = userDoc['goal'] ?? '';
          });
        }
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to navigate to PersonalDetailsScreen
  void _navigateToPersonalDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const PersonalDetailsScreen(),
      ),
    );
  }


 void _navigateToDietryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) =>  DietaryNeedsPreferencesScreen(),
      ),
    );
  }

  void _navigateSetReminderScreen(){
         Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) =>  SetReminderScreen(),
      ),
    );
   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // First Container: Display User Info
             Container(
                     height: 200,
                     width: 400, 
                    padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                     color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                       color: Colors.grey.withOpacity(0.5),
                     spreadRadius: 3,
                       blurRadius: 10,
                  offset: const Offset(0, 3),
                     ),
                      ],
  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Age: $age',
                      style: const TextStyle(
                        fontSize: 18,
                        
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Current Weight: $currentWeight kg',
                      style: const TextStyle(
                        fontSize: 18,
                        
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Goal: $goal',
                      style: const TextStyle(
                        fontSize: 18,
                        
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

               Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to Personal Details screen
                      _navigateToPersonalDetails();
                },
              ),
            ),
            const SizedBox(height: 20),

            // Dietary Needs & Preferences Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.set_meal_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Dietary Needs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to Dietary Needs & Preferences screen
                  _navigateToDietryScreen();
                },
              ),
            ),
            const SizedBox(height: 20),

            // Set Reminder Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Set Reminder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to Set Reminder screen
                  _navigateSetReminderScreen();
                },
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
