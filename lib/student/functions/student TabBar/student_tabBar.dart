import 'package:chatbot/screens/homePage/functions/Tab%20Bar/chat_page.dart';
import 'package:chatbot/screens/homePage/functions/Tab%20Bar/studentDetails.dart';
import 'package:chatbot/screens/homePage/functions/view_clasess.dart';
import 'package:chatbot/student/functions/student%20TabBar/question_show.dart';
import 'package:chatbot/student/functions/student%20TabBar/student_book_page.dart';
import 'package:chatbot/student/functions/student%20TabBar/student_chat_page.dart';
import 'package:chatbot/student/functions/student%20TabBar/student_class_history.dart';
import 'package:chatbot/student/student_quizz_list.dart';
import 'package:flutter/material.dart';

import 'assignment_page.dart';


class studentTabBar extends StatefulWidget {
  final String className;
  final String subject;
  final String studentId;

  studentTabBar({required this.className, required this.subject, required this.studentId});

  @override
  _studentTabBarState createState() => _studentTabBarState();
}

class _studentTabBarState extends State<studentTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
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
                  indicatorWeight: 5,
                  labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.class_, size: 26),
                      text: 'Topics',
                    ),
                    Tab(
                      icon: Icon(Icons.assignment, size: 26),
                      text: 'Assignments',
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
                      icon: Icon(Icons.chat, size: 26),
                      text: 'Notification',
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
              StudentHistoryPage(className: widget.className, subject: widget.subject, studentId:widget.studentId,),
              StudentAssignmentPage(studentId: widget.studentId,),
              studentBookPage(),
              //QuestionShow(),
              StudentQuizzList(classname: widget.className, subject: widget.subject, studentId: widget.studentId),
              studentsChatPage(className: widget.className, subjects: widget.subject)

            ],
          ),
        ),
      ),
    );
  }
}
