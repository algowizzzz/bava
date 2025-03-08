import 'package:chatbot/screens/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin/Admin_dashboard.dart';
import '../../admin/admin_panel.dart';
import '../../admin/tab_admin.dart';
import '../../student/student_dashboard.dart';
import '../home_page/dashboard.dart';
import '../forgot_password/forgotpassword1.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  bool isAdminSelected = false; // Checkbox state for Admin/Teacher login

  void handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email and Password cannot be empty.';
        isLoading = false;
      });
      return;
    }

    try {
      // Login using our MongoDB API
      final response = await _apiService.login(
        email,
        password,
        isAdminSelected, // isTeacher parameter (true for admin/teacher, false for student)
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      
      // Extract user data from response
      final userData = response['user'];
      final String userId = userData['_id'];
      final String name = userData['name'] ?? 'User';
      final bool isTeacher = userData['isTeacher'] ?? false;
      final bool isAdmin = userData['isAdmin'] ?? false;
      
      // Save user data to shared preferences
      await prefs.setString('uid', userId);
      await prefs.setString('name', name);
      
      if (isTeacher) {
        // Handle teacher/admin login
        if (isAdmin) {
          await prefs.setString('type', 'admin');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPanel()),
          );
        } else {
          await prefs.setString('type', 'teacher');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        }
      } else {
        // Handle student login
        await prefs.setString('studentId', userId);
        await prefs.setString('type', 'student');
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => studentDashboard(studentId: userId),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : 'Login Failed. Please check your credentials.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: scrHeight,
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
              SizedBox(height: 100),
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
                width: scrWidth * 0.8,
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
                width: scrWidth * 0.8,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isAdminSelected,
                    side: BorderSide(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        isAdminSelected = value!;
                      });
                    },
                  ),
                  Text(
                    'Login as Admin/Teacher',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage(),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Signup(name: '', email: ''),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Sign up",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

