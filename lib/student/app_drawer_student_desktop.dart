import 'package:chatbot/screens/auth/login_screen.dart';
import 'package:chatbot/screens/auth/profile/profile_page.dart';
import 'package:chatbot/screens/homePage/functions/applications_realLife.dart';
import 'package:chatbot/screens/homePage/functions/context_builder.dart';
import 'package:chatbot/screens/homePage/functions/handout.dart';
import 'package:chatbot/screens/homePage/functions/lesson_planner.dart';
import 'package:chatbot/screens/homePage/functions/ppt_generator.dart';
import 'package:chatbot/screens/homePage/functions/view_clasess.dart';
import 'package:chatbot/student/functions/notification.dart';
import 'package:chatbot/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'functions/chatpdf/upload_pdf.dart';
import 'functions/essay_evaluation.dart';
import 'functions/review_questions.dart';
import 'functions/topic_explanation.dart';

/// A stateless widget that represents the app drawer for the student desktop interface.
/// The drawer provides navigation options and functionality such as logging out.
class AppDrawerStudentDesktop extends StatelessWidget {
  final String className;
  final String studentId;
  final String name;
  final String email;
  final int age;
  const AppDrawerStudentDesktop({super.key, required this.className, required this.studentId, required this.name, required this.email, required this.age});
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
            leading: const Icon(Icons.event_note, color: Colors.blue),
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
            leading: const Icon(Icons.slideshow, color: Colors.blue),
            title: const Text('Review Question'),
            onTap: () => _navigateTo(context, ReviewQuestionPage(
                studentId: '', classNAme: '')),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.blue),
            title: const Text('Topic Explanation'),
            onTap: () => _navigateTo(context,  TopicExplanationPage(className: '')),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.build, color: Colors.blue),
            title: const Text('Essay Evaluation'),
            onTap: () => _navigateTo(context, EssayEvaluationPage(className: '')),
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
            title: const Text('Notification'),
            onTap: () => _navigateTo(context, notification()),
          ),
        ),
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: const Icon(Icons.message, color: Colors.blue),
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
