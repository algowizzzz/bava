import 'package:chatbot/screens/auth/profile/profile_page.dart';
import 'package:chatbot/screens/homePage/functions/applications_realLife.dart';
import 'package:chatbot/screens/homePage/functions/context_builder.dart';
import 'package:chatbot/screens/homePage/functions/handout.dart';
import 'package:chatbot/screens/homePage/functions/lesson_planner.dart';
import 'package:chatbot/screens/homePage/functions/ppt_generator.dart';
import 'package:chatbot/screens/homePage/functions/view_clasess.dart';
import 'package:chatbot/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';
import '../gemini/myHomePage.dart';

class AppDrawerDesktop extends StatelessWidget {
  const AppDrawerDesktop({super.key});
  void _navigateTo(BuildContext context, Widget page) {

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await SharedPreferences.getInstance().then((prefs) => prefs.clear());
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    "assets/teacher.jpg",
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              const Text(
                "Teacher",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.event_note, color: Colors.blue),
            title: const Text('Lesson Planner'),
            onTap: () => _navigateTo(context, LessonPlannerPage()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.slideshow, color: Colors.blue),
            title: const Text('PPT Generator'),
            onTap: () => _navigateTo(context, PPTGeneratorPage()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.blue),
            title: const Text('Handout'),
            onTap: () => _navigateTo(context, HandoutAssignmentPage()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.build, color: Colors.blue),
            title: const Text('Context Builder'),
            onTap: () => _navigateTo(context, contextBuilderPage()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading:
            const Icon(Icons.settings_applications, color: Colors.blue),
            title: const Text('Application In Real Life'),
            onTap: () => _navigateTo(context, ApplicationRealLife()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.message, color: Colors.blue),
            title: const Text('ChatGPT'),
            onTap: () => _navigateTo(context, MyHomePage()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('View Profile'),
            onTap: () => _navigateTo(context, ProfilePage()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.class_, color: Colors.blue),
            title: const Text('View Classes'),
            onTap: () => _navigateTo(context, ClassesPage()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.blue),
            title: const Text('Logout'),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ),
      ],
    );
  }
}