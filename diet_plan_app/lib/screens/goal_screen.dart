
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diet_plan_app/screens/activity_level.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({
    super.key,
    required this.bmr,
    required this.bmi,
  });

  final double bmr;
  final double bmi;

  // Function to store the goal in Firestore
  Future<void> _storeGoalInFirestore(String goal) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'goal': goal,
        });
      } else {
        // Handle unauthenticated state
        print('No user is currently signed in.');
      }
    } catch (error) {
      print('Error saving goal to Firestore: $error');
    }
  }

  void _showActivityLevelScreen(BuildContext context, String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ActivityLevelScreen(bmr: bmr, message: message),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String titleMessage, String contentMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleMessage),
          content: Text(contentMessage),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void nutritionWeightMaintain(BuildContext context) async {
    if (bmi < 18.5) {
      String titleMessage = 'Wrong Goal';
      String contentMessage =
          'You are underweight.\n You should gain weight.\n Please choose the goal Weight Gain.';
      _showErrorDialog(context, titleMessage, contentMessage);
    } else if (bmi >= 25 && bmi < 29.9) {
      String titleMessage = 'Wrong Goal';
      String contentMessage =
          'You are overweight. \n You should lose weight.\n Please choose the goal Weight Loss.';
      _showErrorDialog(context, titleMessage, contentMessage);
    } else if (bmi >= 18.5 && bmi < 24.9) {
      String message = 'weight maintain';
      await _storeGoalInFirestore('Weight Maintain');
      _showActivityLevelScreen(context, message);
    } else {
      String titleMessage = 'Wrong Goal';
      String contentMessage =
          ' You are in the obese category. \n You should lose weight.\n Please choose the goal Weight Loss.';
      _showErrorDialog(context, titleMessage, contentMessage);
    }
  }

  void nutritionWeightLoss(BuildContext context) async {
    if (bmi < 18.5) {
      String titleMessage = 'Wrong Goal';
      String contentMessage =
          'You are underweight.\n You should gain weight.\n Please choose the goal Weight Gain.';
      _showErrorDialog(context, titleMessage, contentMessage);
    } else if (bmi >= 18.5 && bmi < 24.9) {
      String titleMessage = 'Wrong Goal';
      String contentMessage =
          'You are at a normal weight.\n You should maintain your weight.\n Please choose the goal Weight Maintain.';
      _showErrorDialog(context, titleMessage, contentMessage);
    } else {
      String message = 'weight Gain';
      await _storeGoalInFirestore('Weight Loss');
      _showActivityLevelScreen(context, message);
    }
  }

  


  void nutritionWeightGain(BuildContext context) async {
    if(bmi >= 25 && bmi < 29.9){
      String titleMessage='Wrong Goal';
      String contentMessage= 'You are overweight.\n You should lose weight.\n Please choose the goal Weight Loss.';
      _showErrorDialog(context, titleMessage, contentMessage);
    }
    else if(bmi < 18.5)
    {
      
     String messaage='weight gain';
      await _storeGoalInFirestore('Weight Loss');
           _showActivityLevelScreen(context, messaage);

    }
    else if (bmi >= 18.5 && bmi < 24.9){
          String titleMessage='Wrong Goal';
      String contentMessage= 'You are at a normal weight.\n You should maintain your weight.\n Please choose the goal Weight Maintain.';
      _showErrorDialog(context, titleMessage, contentMessage);
    }
    else {
      String titleMessage='Wrong Goal';
      String contentMessage= ' You are in the obese category.\n You should lose weight.\n Please choose the goal Weight Loss.';
      _showErrorDialog(context, titleMessage, contentMessage);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Container(
        margin: const EdgeInsets.all(35),
        color: const Color.fromARGB(255, 236, 241, 240),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30,),
              Text(
                'What is your main goal?',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 30,),
        
              ElevatedButton(
                onPressed: () {
                  nutritionWeightLoss(context);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromWidth(250),
                  backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
                ),
                child: const Text(
                  'Weight Loss',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 79, 59, 59),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
        
              ElevatedButton(
                onPressed: () {
                  nutritionWeightMaintain(context);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromWidth(250),
                  backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
                ),
                child: const Text(
                  'Weight Maintain',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 79, 59, 59),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
        
              ElevatedButton(
                onPressed: () {
                  nutritionWeightGain(context);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromWidth(250),
                  backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
                ),
                child: const Text(
                  'Weight Gain',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 79, 59, 59),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}