import 'package:flutter/material.dart';
import 'student/students_login.dart';
import 'screens/auth/login_screen.dart';

class LoginTabScreen extends StatefulWidget {
  @override
  _LoginTabScreenState createState() => _LoginTabScreenState();
}

class _LoginTabScreenState extends State<LoginTabScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple[700],
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Column(
              children: [
                TabBar(
                  indicatorColor: Colors.deepPurple[200],
                  indicatorWeight: 4,
                  labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.person, size: 26),
                      text: 'Teacher Login',
                    ),
                    Tab(
                      icon: Icon(Icons.school, size: 26),
                      text: 'Student Login',
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[700]!, Colors.purple[300]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: [
              LoginScreen(),
              SimpleStudentLoginScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
