import 'package:diet_plan_app/screens/bmi_display.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserInput extends StatefulWidget {
  const UserInput({super.key});

  @override
  State<UserInput> createState() {
    return _UserInputState();
  }
}

class _UserInputState extends State<UserInput> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _gender = 'Male';

  @override
  void dispose() {
    _weightController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Function to calculate age based on Date of Birth
  void _calculateAge(String dobString) {
    try {
      DateTime dob = DateFormat('yyyy/MM/dd').parse(dobString);
      DateTime today = DateTime.now();

      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--; // If the birthday hasn't happened yet this year
      }

      setState(() {
        _ageController.text = age.toString();
      });
    } catch (e) {
      print("Invalid date format");
    }
  }

  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      // Collect user data
      String weight = _weightController.text;
      String height = _heightController.text;
      String dob = _dobController.text;
      String age = _ageController.text;
      
      
      // Get the current user's ID from FirebaseAuth
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final User? currentUser = _auth.currentUser;
      final String? userID = currentUser?.uid;

      // Save data using the userID as the document ID
      if (userID != null) {
        await FirebaseFirestore.instance.collection('users').doc(userID).set({
          'weight': weight,
          'height': height,
          'dob': dob,
          'age': age,
          'gender': _gender,
          'timestamp': FieldValue.serverTimestamp(), // To track when the data was stored
        },SetOptions(merge: true));
        

        // Proceed to BMI result screen
        _showBmiResult(context);
      }
    }
  }

  void _showBmiResult(BuildContext context) {
    String heightValue = _heightController.text;
    String weightValue = _weightController.text;
    double height1 = double.parse(heightValue);
    double weight1 = double.parse(weightValue);
    double height = (height1 * 0.01);

    double bmi = (weight1 / (height * height));

    String message = _getBMIMessage(bmi);
    double bmrValue = _calculationOfBMR();


       // Save the calculated BMI to Firestore
  _saveBMIToFirestore(bmi);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BmiDisplay(
          messaage: message,
          bmr: bmrValue,
          bmi: bmi,
        ),
      ),
    );
  }


  void _saveBMIToFirestore(double bmi) async {
  try {
    // Get the current user's ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Update Firestore document with the calculated BMI
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'bmi': bmi, // Add or update the BMI field
    });

   // print('BMI successfully updated in Firestore');
  } catch (e) {
    print('Error saving BMI to Firestore: $e');
  }
}

  String _getBMIMessage(double bmi) {
    if (bmi < 18.5) {
      return 'Your BMI is ${bmi.toStringAsFixed(2)}.\n You are underweight.\n You should gain weight.';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Your BMI is ${bmi.toStringAsFixed(2)}.\n You are at a normal weight. \n You should maintain your weight.';
    } else if (bmi >= 25 && bmi < 29.9) {
      return 'Your BMI is ${bmi.toStringAsFixed(2)}. \n You are overweight. \n You should lose weight';
    } else {
      return 'Your BMI is ${bmi.toStringAsFixed(2)}. \n You are in the obese category. \n You should lose weight.';
    }
  }

  double _calculationOfBMR() {
    String ageValue = _ageController.text;
    String heightValue = _heightController.text;
    String weightValue = _weightController.text;
    double age1 = double.parse(ageValue);
    double height1 = double.parse(heightValue);
    double weight1 = double.parse(weightValue);
    double bmr = 0;

    if (_gender == 'Male') {
      bmr = (10 * weight1) + (6.25 * height1) - (5 * age1) + 5;
    } else {
      bmr = (10 * weight1) + (6.25 * height1) - (5 * age1) - 161;
    }

    return bmr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // This is the default behavior
      appBar: AppBar(
        title: const Text("Personal Information"),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color:  const Color.fromARGB(255, 236, 241, 240),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    '       Please enter your personal information.',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // DOB Input
                  TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth (YYYY/MM/DD)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 10) {
                        _calculateAge(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Age Field (read-only)
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height in Cm',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      } else if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight in kg',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      } else if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _gender = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveUserInfo,
                    style: ElevatedButton.styleFrom(
                  backgroundColor:  Theme.of(context).colorScheme.secondaryFixedDim,
                ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
