import 'package:chatbot/screens/auth/login_screen.dart';
import 'package:chatbot/screens/auth/profile/profile_page.dart';
import 'package:chatbot/screens/home_page/functions/applications_realLife.dart';
import 'package:chatbot/screens/home_page/functions/view_clasess.dart';
import 'package:chatbot/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'functions/chatpdf/upload_pdf.dart';
import 'functions/essay_evaluation.dart';
import 'functions/notification.dart';
import 'functions/review_questions.dart';
import 'functions/topic_explanation.dart';

class AppDrawerStudent extends StatelessWidget {
  final String className;
  final String studentId;
  final String name;
  final String email;
  final int age;
  const AppDrawerStudent(
      {super.key,
      required this.className,
      required this.studentId,
      required this.name,
      required this.email,
      required this.age});
  void _navigateTo(BuildContext context, Widget page) {
    if (!Navigator.canPop(context)) {
      Navigator.pop(context);
    }
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
              await SharedPreferences.getInstance()
                  .then((prefs) => prefs.clear());
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
    return Drawer(
      child: ListView(
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
                      "assets/student_profile.jpg",
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Student Name",
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
              leading: const Icon(Icons.event_note),
              title: const Text('Document chat'),
              onTap: () => _navigateTo(context, UploadPdfPage()),
            ),
          ),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.slideshow),
              title: const Text('Review Question'),
              onTap: () => _navigateTo(
                  context, ReviewQuestionPage(studentId: '', classNAme: '')),
            ),
          ),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Topic Explanation'),
              onTap: () =>
                  _navigateTo(context, TopicExplanationPage(className: '')),
            ),
          ),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Essay Evaluation'),
              onTap: () =>
                  _navigateTo(context, EssayEvaluationPage(className: '')),
            ),
          ),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.settings_applications),
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
              leading: const Icon(Icons.message),
              title: const Text('Notification'),
              onTap: () => _navigateTo(context, NotificationDisplay()),
            ),
          ),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.person),
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
              leading: const Icon(Icons.class_),
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
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                if (!Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
