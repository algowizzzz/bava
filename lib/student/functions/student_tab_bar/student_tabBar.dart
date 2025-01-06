import 'package:chatbot/student/functions/student_tab_bar/student_book_page.dart';
import 'package:chatbot/student/functions/student_tab_bar/student_chat_page.dart';
import 'package:chatbot/student/functions/student_tab_bar/student_class_history.dart';
import 'package:chatbot/student/student_quizz_list.dart';
import 'package:flutter/material.dart';

import 'assignment_page.dart';

class StudentTabBar extends StatefulWidget {
  final String className;
  final String subject;
  final String studentId;

  StudentTabBar(
      {required this.className,
      required this.subject,
      required this.studentId});

  @override
  _StudentTabBarState createState() => _StudentTabBarState();
}

class _StudentTabBarState extends State<StudentTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.deepPurple[200]!,
                    width: 2,
                  ),
                ),
              ),
              child: TabBar(
                indicatorColor: Colors.deepPurple[200],
                indicatorWeight: 4,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: Icon(Icons.class_, size: 24),
                    text: 'Topics',
                  ),
                  Tab(
                    icon: Icon(Icons.assignment, size: 24),
                    text: 'Assignments',
                  ),
                  Tab(
                    icon: Icon(Icons.book, size: 24),
                    text: 'Books',
                  ),
                  Tab(
                    icon: Icon(Icons.quiz, size: 24),
                    text: 'Quiz',
                  ),
                  Tab(
                    icon: Icon(Icons.notifications, size: 24),
                    text: 'Notification',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.grey[50],
          child: TabBarView(
            children: [
              StudentHistoryPage(
                className: widget.className,
                subject: widget.subject,
                studentId: widget.studentId,
              ),
              StudentAssignmentPage(
                studentId: widget.studentId,
              ),
              studentBookPage(),
              StudentQuizzList(
                classname: widget.className,
                subject: widget.subject,
                studentId: widget.studentId,
              ),
              studentsChatPage(
                className: widget.className,
                subjects: widget.subject,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
