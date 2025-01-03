import 'package:chatbot/Admin/students.dart';
import 'package:chatbot/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/auth/login_screen.dart';
import '../screens/homePage/functions/Tab Bar/studentDetails.dart';
import '../tab_bar.dart';
import 'Admin_dashboard.dart';


class tabAdmin extends StatefulWidget {
  @override
  _tabAdminState createState() => _tabAdminState();
}
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Close the dialog
              Navigator.pop(context);

              // Navigate to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  );
}


class _tabAdminState extends State<tabAdmin> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple[700],
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
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
                      text: 'Teacher Details',
                    ),
                    Tab(
                      icon: Icon(Icons.school, size: 26),
                      text: 'Student Details',
                    ),
                  ],
                ),

              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white,size: scrWidth*0.02,),
                onPressed: () {
                  _showLogoutDialog(context); // Pass the context
                }

            ),
          ],
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
              AdminDashboard(),
              Students(),
            ],
          ),
        ),
      ),
    );
  }
}
