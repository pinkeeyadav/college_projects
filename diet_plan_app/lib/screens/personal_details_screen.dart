
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
 
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  // User data variables
  String userName = '';
  int age = 0;
  String gender = '';
  double height = 0.0; // in cm
  double weight = 0.0; // in kg
  double bmi = 0.0;
  String activityLevel = '';
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
            age = userDoc['age'] is String
                ? int.tryParse(userDoc['age']) ?? 0
                : (userDoc['age'] ?? 0).toInt();
            gender = userDoc['gender'] ?? '';
            height = userDoc['height'] is String
                ? double.tryParse(userDoc['height']) ?? 0.0
                : (userDoc['height'] ?? 0).toDouble();
            weight = userDoc['weight'] is String
                ? double.tryParse(userDoc['weight']) ?? 0.0
                : (userDoc['weight'] ?? 0).toDouble();
            bmi = userDoc['bmi'] is String
                ? double.tryParse(userDoc['bmi']) ?? 0.0
                : (userDoc['bmi'] ?? 0).toDouble();
            activityLevel = userDoc['activityLevel'] ?? '';
            goal = userDoc['goal'] ?? '';
          });
        }
      }
    } catch (error) {
      print('Error fetching user data: $error');
      // Optionally, show an error message to the user
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Widget for each detail row
  Widget _buildDetailRow(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns the text at the top
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 30,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                overflow: TextOverflow.visible, // Allows text to expand
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Personal Information
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Age
                    _buildDetailRow(Icons.cake, 'Age', age > 0 ? age.toString() : 'N/A'),
                    const Divider(thickness: 1),
                    // Gender
                    _buildDetailRow(Icons.person, 'Gender', gender.isNotEmpty ? gender : 'N/A'),
                    const Divider(thickness: 1),
                    // Height
                    _buildDetailRow(Icons.height, 'Height', height > 0 ? '${height.toStringAsFixed(1)} cm' : 'N/A'),
                    const Divider(thickness: 1),
                    // Weight
                    _buildDetailRow(Icons.fitness_center, 'Weight', weight > 0 ? '${weight.toStringAsFixed(1)} kg' : 'N/A'),
                    const Divider(thickness: 1),
                    // BMI
                    _buildDetailRow(Icons.assessment, 'BMI', bmi > 0 ? bmi.toStringAsFixed(1) : 'N/A'),
                    const Divider(thickness: 1),
                    // Activity Level
                    _buildDetailRow(Icons.directions_run, 'Activity Level', activityLevel.isNotEmpty ? activityLevel : 'N/A'),
                    const Divider(thickness: 1),
                    // Goal
                    _buildDetailRow(Icons.flag, 'Goal', goal.isNotEmpty ? goal : 'N/A'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}