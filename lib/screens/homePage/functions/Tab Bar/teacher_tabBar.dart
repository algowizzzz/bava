import 'package:chatbot/screens/homePage/functions/Tab%20Bar/chat_page.dart';
import 'package:chatbot/screens/homePage/functions/Tab%20Bar/question_add.dart';
import 'package:chatbot/student/functions/student%20TabBar/question_show.dart';
import 'package:chatbot/screens/homePage/functions/Tab%20Bar/studentDetails.dart';
import 'package:chatbot/screens/homePage/functions/view_clasess.dart';
import 'package:flutter/material.dart';

import 'assignment_teacher.dart';
import 'class_history.dart';
import 'books_page.dart';

class teacherTabBar extends StatefulWidget {
  final String className;
  final String subject;

  teacherTabBar({required this.className, required this.subject});

  @override
  _teacherTabBarState createState() => _teacherTabBarState();
}

class _teacherTabBarState extends State<teacherTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length:6, // Number of tabs
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
                  indicatorWeight: 6,
                  labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.class_, size: 26),
                      text: 'Topics',
                    ),
                    Tab(
                      icon: Icon(Icons.book, size: 26),
                      text: 'Books',
                    ),
                    Tab(
                      icon: Icon(Icons.quiz, size: 26),
                      text: 'Quiz',
                    ),
                    Tab(
                      icon: Icon(Icons.assignment, size: 26),
                      text: 'Assignments',
                    ),
                    Tab(
                      icon: Icon(Icons.school, size: 26),
                      text: 'Students',
                    ),
                    Tab(
                      icon: Icon(Icons.chat, size: 26),
                      text: 'Chat',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            children: [
              ClassHistoryPage(classname: widget.className, subject: widget.subject),
              booksPage(),
              QuestionAdd(),
              AssignmentUploadPage(classname: widget.className, subject: widget.subject),
              StudentDetailsPage(classname: widget.className, subject: widget.subject,),
              ChatPage(className: widget.className, subjects: widget.subject,)

            ],
          ),
        ),
      ),
    );
  }
}
