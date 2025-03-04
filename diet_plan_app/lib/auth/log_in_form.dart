import 'package:diet_plan_app/auth/forgot_password_screen.dart';
import 'package:diet_plan_app/auth/registration_form.dart';
import 'package:diet_plan_app/firebase_services/auth_service.dart';
import 'package:diet_plan_app/screens/user_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() {
    return _LogInPageState();
  }
}

void _showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Login Failed'),
        content: const Text('Incorrect User ID or Password.'),
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

class _LogInPageState extends State<LogInPage> {
  final FirebaseServices _auth = FirebaseServices();

// ignore: unused_field
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showRegistrationForm(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const RegistrationForm()));
  }

  void _showForgotPasswordScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => ForgotPasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // This is the default behavior
      appBar: AppBar(
        title: const Text('Log in'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.food_bank_outlined,
                      size: 100,
                      color: Colors.green,
                    ),
                    Text(
                      'Diet',
                      style: TextStyle(
                          fontSize: 80,
                          color: Colors.green,
                          shadows: [
                            BoxShadow(
                              blurRadius: 5,
                              color: Color.fromARGB(255, 203, 234, 205),
                            )
                          ]),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                TextButton(
                  onPressed: () {
                    _showRegistrationForm(context);
                  },
                  child: const Text(' Have not an account?'),
                ),
                const SizedBox(height: 30.0),
                TextButton(
                  onPressed: () {
                    _showForgotPasswordScreen(context);
                  },
                  child: const Text('Forgot Password?'),
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String email = _emailController.text;
                      String password = _passwordController.text;

                      User? user = await _auth.signInMethod(email, password);

                      if (user != null) {
                        print('user is successfully sign in');
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const UserInput(),
                        ));
                      } else {
                        _showErrorDialog(context);
                      }

                      if (_formKey.currentState!.validate()) {
                        // Handle successful validation and login logic
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.green[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
