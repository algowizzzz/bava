import 'package:chatbot/student/student_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../screens/forgot_password/forgotpassword1.dart';

class SimpleStudentLoginScreen extends StatefulWidget {
  @override
  _SimpleStudentLoginScreenState createState() => _SimpleStudentLoginScreenState();
}

class _SimpleStudentLoginScreenState extends State<SimpleStudentLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      print('Starting authentication...');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print('Email: ${emailController.text.trim()}');
      print('Password: ${passwordController.text.trim()}');

      String email = emailController.text.trim();

      print('Authentication successful. Checking Firestore...');


      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .get();

      if (studentQuery.docs.isNotEmpty) {
        String studentId = studentQuery.docs[0].id;
        print('Student found. Document ID: $studentId');

        print('Navigating to Student Dashboard...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => studentDashboard(studentId: studentId,)),
        );
      } else {
        print('Student not found in Firestore.');
        await _auth.signOut();
        setState(() {
          errorMessage = 'Access denied. You are not a registered student.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Login failed. Please try again.';
      });
      print('FirebaseAuthException: ${e.message}');
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again later.';
      });
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      print('Login process completed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: scrHeight * 1,
        width: scrWidth * 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[700]!, Colors.purple[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Please login to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 32),
              Container(
                width: scrWidth * 0.5,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.email, color: Colors.white),
                    filled: true,
                    fillColor: Colors.deepPurple[400],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: scrWidth * 0.5,
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    filled: true,
                    fillColor: Colors.deepPurple[400],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (isLoading)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              if (!isLoading)
                ElevatedButton(
                  onPressed: handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                ),
              SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
