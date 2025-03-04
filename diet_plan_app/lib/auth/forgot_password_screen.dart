
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _message = '';

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

     try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _message = 'Password reset link sent to ${_emailController.text}.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = 'Error: ${e.message ?? 'An unknown error occurred.'}';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
         backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: Container(
        margin: EdgeInsets.all(30),
        color: const Color.fromARGB(255, 217, 240, 244),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20,),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Enter your email'),
              ),
              SizedBox(height: 40),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: Text('Send Password Reset Email',
                  style: TextStyle(fontSize: 20),),
                ),
              SizedBox(height: 20),
              Text(_message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
