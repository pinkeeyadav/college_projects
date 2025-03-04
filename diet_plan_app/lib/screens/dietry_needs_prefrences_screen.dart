import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DietaryNeedsPreferencesScreen extends StatelessWidget {
  Future<Map<String, dynamic>> _fetchDietaryData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).collection('nutrition_intake').doc('daily_intake').get();
    
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception("User data not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dietary Needs"),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDietaryData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No dietary data found'));
          } else {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  buildInfoRow(Icons.local_fire_department, "Calorie Goal", "${data['calories'].toStringAsFixed(0) ?? '0'} kcal"),
                  Divider(),
                  buildInfoRow(Icons.fastfood, "Carbs Goal", "${data['carbs'].toStringAsFixed(0) ?? '0'} g"),
                  Divider(),
                  buildInfoRow(Icons.fitness_center, "Protein Goal", "${data['protein'].toStringAsFixed(0) ?? '0'} g"),
                  Divider(),
                  buildInfoRow(Icons.local_dining, "Fats Goal", "${data['fat'].toStringAsFixed(0) ?? '0'} g"),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 63, 108, 116), size: 30),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
