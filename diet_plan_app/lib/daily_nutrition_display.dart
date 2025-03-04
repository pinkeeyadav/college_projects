import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DailyNutritionDisplay extends StatelessWidget {
  final double caloriesGoal;
  final double protein;
  final double carbs;
  final double fat;

  const DailyNutritionDisplay({
    super.key,
    required this.caloriesGoal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return docSnapshot['name'] ?? 'User'; // Default name if not found
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<String>(
        future: getUserName(),
        builder: (context, snapshot) {
          final userName = snapshot.data ?? 'User';

          return 
             Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User greeting
                  Text(
                    'Hello, $userName !',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                 const Text('Your daily nutrition intake is as',
                  style: TextStyle(fontSize: 18),),

                  const SizedBox(height: 20),
                  // Container for nutrients and image
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nutrients information on the left side
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                             
                               ListTile(
                        leading: const Icon(Icons.circle, color: Colors.red),
                        title: const Text('Calories'),
                        subtitle: Text('${caloriesGoal.toStringAsFixed(0)} kcal'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.circle, color: Colors.blue),
                        title: const Text('Carbs'),
                        subtitle: Text('${carbs.toStringAsFixed(0)} g'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.circle, color: Colors.orange),
                        title: const Text('Protein'),
                        subtitle: Text('${protein.toStringAsFixed(0)} g'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.circle, color: Colors.green),
                        title: const Text('Fat'),
                        subtitle: Text('${fat.toStringAsFixed(0)} g'),
                      ),
                            ],
                          ),
                        ),
                        // Image on the right side
                        Expanded(
                          flex: 1,
                          child: Image.asset(
                            'assets/images/apple.jpg', // Replace with your image asset
                            fit: BoxFit.contain,
                            height: 200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            
          );
        },
      
    );
  }
}
