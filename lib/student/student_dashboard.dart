import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatbot/screens/auth/login_screen.dart';
import 'package:chatbot/student/app_drawer_student.dart';
import 'package:chatbot/student/app_drawer_student_desktop.dart';
import 'package:chatbot/student/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../screens/home_page/functions/handout.dart';
import '../screens/home_page/functions/Tab_Bar/studentDetails.dart';
import '../tab_bar.dart';
import 'functions/chatpdf/upload_pdf.dart';
import 'functions/essay_evaluation.dart';
import 'functions/notification.dart';
import 'functions/review_questions.dart';
import 'functions/student_tab_bar/student_tabBar.dart';
import 'functions/topic_explanation.dart';

class studentDashboard extends StatefulWidget {
  final String studentId;
  const studentDashboard({super.key, required this.studentId});

  @override
  State<studentDashboard> createState() => _studentDashboardState();
}

class _studentDashboardState extends State<studentDashboard> {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  late String classname;
  late String name;
  late int age;
  late String email;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    classname = '';
    name = '';
    age = 0;
    email = '';
    _getCurrentUserId();
    _loadStudentData();
  }

  void _showLogoutDialog(BuildContext context) async {
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
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clears all preferences

                // Close the dialog
                Navigator.pop(context);

                // Navigate to the login screen or the desired page
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

  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserUid = user.uid;
      });
    } else {
      print('User is not authenticated');
    }
  }

  @override
  List<Map<String, String>> _studentData = [];

  Future<void> _loadStudentData() async {
    setState(() {
      isLoading = true;
    });
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _studentData = _processStudentData(snapshot.docs);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;
        int crossAxisCount = (constraints.maxWidth / 200).floor();

        return Scaffold(
          extendBodyBehindAppBar: false,
          drawer: MediaQuery.of(context).size.width < 600
              ? isLoading
                  ? CircularProgressIndicator()
                  : AppDrawerStudent(
                      className: classname,
                      studentId: widget.studentId,
                      name: name,
                      email: email,
                      age: age,
                    )
              : null,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            elevation: 2,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(studentId: widget.studentId)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
            title: Text(
              'Student Dashboard',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF1F3F6), Colors.white],
              ),
            ),
            child: Row(
              children: [
                if (constraints.maxWidth >= 600)
                  SizedBox(
                      width: MediaQuery.of(context).size.width < 1200
                          ? constraints.maxWidth * 0.27
                          : constraints.maxWidth * 0.18,
                      child: AppDrawerStudentDesktop(
                        className: classname,
                        studentId: widget.studentId,
                        name: name,
                        email: email,
                        age: age,
                      )),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: maxWidth * 0.01,
                        // vertical: maxHeight * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          CarouselSlider(
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.width >= 600
                                  ? MediaQuery.of(context).size.height * 0.45
                                  : MediaQuery.of(context).size.height * 0.2,
                              aspectRatio: 16 / 9,
                              viewportFraction: 1.0,
                              initialPage: 0,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 3),
                              autoPlayAnimationDuration:
                                  Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                              scrollDirection: Axis.horizontal,
                            ),
                            items: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage('assets/banner.jpg'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage('assets/banner.jpg'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: maxHeight * 0.02),
                            child: const Text(
                              'Welcome Back Student name',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(maxWidth * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader("Classes"),
                                  SizedBox(height: maxHeight * 0.02),
                                  Container(
                                      child: _studentData.isEmpty
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blueGrey),
                                              ),
                                            )
                                          : GridView.builder(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    constraints.maxWidth < 600
                                                        ? 2
                                                        : crossAxisCount,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 15,
                                                childAspectRatio: constraints
                                                        .maxWidth /
                                                    ((constraints.maxWidth < 600
                                                            ? 2
                                                            : crossAxisCount) *
                                                        100),
                                              ),
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: _studentData.length,
                                              itemBuilder: (context, index) =>
                                                  _buildClassSubjectCard(
                                                      context,
                                                      _studentData[index]),
                                            )),
                                  SizedBox(height: maxHeight * 0.03),
                                  _buildSectionHeader("Features"),
                                  SizedBox(height: maxHeight * 0.03),
                                  GridView.count(
                                    crossAxisCount:
                                        MediaQuery.of(context).size.width < 600
                                            ? 2
                                            : MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    1000
                                                ? 3
                                                : MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        1400
                                                    ? 4
                                                    : MediaQuery.of(context)
                                                                .size
                                                                .width <
                                                            1800
                                                        ? 5
                                                        : MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                2200
                                                            ? 6
                                                            : 7,
                                    crossAxisSpacing:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                    mainAxisSpacing:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                    childAspectRatio: 1.2,
                                    shrinkWrap: true,
                                    children: _buildFeatureCards(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _processStudentData(
      List<QueryDocumentSnapshot> students) {
    List<Map<String, String>> pairs = [];
    for (var student in students) {
      var data = student.data() as Map<String, dynamic>;
      String className = data['class'] ?? 'N/A';
      List<dynamic> subjects = data['subjects'] ?? [];
      for (var subject in subjects) {
        pairs.add({'class': className, 'subject': subject.toString()});
      }
      classname = data['class'];
      name = data['name'];
      age = data['age'];
      email = data['email'];
    }
    return pairs;
  }

  Widget _buildClassSubjectCard(
      BuildContext context, Map<String, String> pair) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentTabBar(
              className: pair['class']!,
              subject: pair['subject']!,
              studentId: widget.studentId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade900,
              Colors.purple.shade600,
              Colors.purpleAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Class: ${pair['class']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                "Subject: ${pair['subject']}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 1000) return 3;
    if (width < 1400) return 4;
    if (width < 1800) return 5;
    if (width < 2200) return 6;
    return 7;
  }

  List<Widget> _buildFeatureCards(BuildContext context) {
    return [
      _dashboardCard(
        icon: Icons.picture_as_pdf,
        title: 'Chat PDF',
        gradientColors: [Colors.blueAccent, Colors.purpleAccent],
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => UploadPdfPage())),
      ),
      _dashboardCard(
        icon: Icons.assignment,
        title: 'Review Question',
        gradientColors: [Colors.orange, Colors.deepOrange],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReviewQuestionPage(
                    studentId: widget.studentId, classNAme: classname))),
      ),
      _dashboardCard(
        icon: Icons.notifications_active,
        title: 'Notifications',
        gradientColors: [Colors.lightGreen, Colors.green],
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => NotificationDisplay())),
      ),
      _dashboardCard(
        icon: Icons.note,
        title: 'Topic Explanation',
        gradientColors: [Colors.indigoAccent, Colors.blue],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TopicExplanationPage(className: classname))),
      ),
      _dashboardCard(
        icon: Icons.book,
        title: 'Essay Evaluation',
        gradientColors: [Colors.purpleAccent, Colors.deepPurple],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EssayEvaluationPage(className: classname))),
      ),
    ];
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required Function() onTap,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
      final iconSize = screenWidth < 600
          ? 24.0
          : screenWidth < 1000
              ? 28.0
              : screenWidth < 1400
                  ? 32.0
                  : 36.0;
      final fontSize = screenWidth < 600
          ? 11.0
          : screenWidth < 1000
              ? 12.0
              : screenWidth < 1400
                  ? 13.0
                  : 14.0;
      final padding = screenWidth < 600
          ? 8.0
          : screenWidth < 1000
              ? 12.0
              : screenWidth < 1400
                  ? 16.0
                  : 20.0;

      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: iconSize),
              SizedBox(height: padding / 2),
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
}
