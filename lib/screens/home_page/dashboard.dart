import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatbot/main.dart';
import 'package:chatbot/screens/home_page/app_drawer_desktop.dart';
import 'package:chatbot/services/api_service.dart';
import 'package:chatbot/student/functions/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/historyModel.dart';
import 'appDrawer.dart';
import 'functions/Tab_Bar/teacher_tabBar.dart';
import 'functions/applications_realLife.dart';
import 'functions/context_builder.dart';
import 'functions/lesson_planner.dart';
import '../gemini/myHomePage.dart';
import 'package:chatbot/screens/home_page/functions/handout.dart';
import 'package:chatbot/screens/home_page/functions/ppt_generator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = false;
  final ApiService _apiService = ApiService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController parentNumberController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  String currentUserId = '';
  String userName = '';
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        currentUserId = prefs.getString('uid') ?? '';
        userName = prefs.getString('name') ?? '';
      });
      
      // Load user profile from API
      if (currentUserId.isNotEmpty) {
        final userProfile = await _apiService.getUserProfile();
        setState(() {
          nameController.text = userProfile['name'] ?? '';
          schoolController.text = userProfile['school'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  test() {
    // Get the screen width and height using MediaQuery
    final scrWidth = MediaQuery.of(context).size.width;
    final scrHeight = MediaQuery.of(context).size.height;
    // Print the media query values
    print('Screen Width: $scrWidth');
    print('Screen Height: $scrHeight');
    print('Device Pixel Ratio: ${MediaQuery.of(context).devicePixelRatio}');
    print('Text Scale Factor: ${MediaQuery.of(context).textScaleFactor}');
    print('Orientation: ${MediaQuery.of(context).orientation}');
  }

  @override
  Widget build(BuildContext context) {
    test();
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: scrWidth * 0.4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              "assets/teczalogoblue.png",
              fit: BoxFit.fill,
              width: scrWidth * 0.04,
              height: scrWidth * 0.026,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 2,
        title: const Text(
          'Teacher Assistance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDisplay(),
                  ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.lightGreen, Colors.lightGreen.shade700],
            ),
          ),
        ),
      ),
      drawer: MediaQuery.of(context).size.width < 600 ? AppDrawer() : null,
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        int crossAxisCount = (constraints.maxWidth / 200).floor();
        return Row(
          children: [
            if (constraints.maxWidth >= 600)
              SizedBox(
                  width: MediaQuery.of(context).size.width < 1200
                      ? constraints.maxWidth * 0.25
                      : constraints.maxWidth * 0.15,
                  child: const AppDrawerDesktop()),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      SizedBox(
                        height: scrWidth * 0.02,
                      ),
                      Container(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Classes",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: scrWidth * 0.01,
                      ),
                      Container(
                          decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      )),
                      const SizedBox(height: 10),
                      FutureBuilder<List<dynamic>>(
                          future: _apiService.getUserHistory(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              debugPrint(
                                  'Error loading history: ${snapshot.error}');
                              return const Center(
                                  child: Text("Error loading history"));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final historyList = snapshot.data ?? [];
                            final Set<String> uniqueClasses = {};
                            final List<HistoryModel> uniqueHistory = [];

                            for (var historyItem in historyList) {
                              final historyData = historyItem as Map<String, dynamic>;

                              final className =
                                  historyData['className'] ?? 'No Class Name';
                              final subject =
                                  historyData['subject'] ?? 'No Subject';
                              final uniqueKey = '$className|$subject';

                              if (!uniqueClasses.contains(uniqueKey)) {
                                uniqueClasses.add(uniqueKey);
                                uniqueHistory.add(HistoryModel(
                                  history_id: historyData['history_id'] ?? '',
                                  date: DateTime.now(),
                                  topic: historyData['topic'] ?? 'No Topic',
                                  className: className,
                                  subject: subject,
                                  userUid: currentUserId,
                                ));
                              }
                            }

                            uniqueHistory.sort((a, b) {
                              final aParts =
                                  RegExp(r'(\d+)(\D+)').firstMatch(a.className);
                              final bParts =
                                  RegExp(r'(\d+)(\D+)').firstMatch(b.className);

                              int gradeA =
                                  int.tryParse(aParts?.group(1) ?? '') ?? 0;
                              int gradeB =
                                  int.tryParse(bParts?.group(1) ?? '') ?? 0;
                              String sectionA = aParts?.group(2) ?? '';
                              String sectionB = bParts?.group(2) ?? '';

                              int gradeComparison = gradeA.compareTo(gradeB);

                              if (gradeComparison == 0) {
                                int sectionComparison =
                                    sectionA.compareTo(sectionB);

                                if (sectionComparison == 0) {
                                  return a.subject.compareTo(b.subject);
                                }
                                return sectionComparison;
                              }

                              return gradeComparison;
                            });

                            if (uniqueHistory.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No history available.",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              );
                            }
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey[50]!],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 3,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: constraints.maxWidth < 600
                                      ? 2
                                      : crossAxisCount,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: constraints.maxWidth /
                                      ((constraints.maxWidth < 600
                                              ? 2
                                              : crossAxisCount) *
                                          100),
                                ),
                                itemCount: uniqueHistory.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final history = uniqueHistory[index];

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => teacherTabBar(
                                                  className: history.className,
                                                  subject: history.subject,
                                                )),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Class: ${history.className}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    'Subject: ${history.subject}',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                      SizedBox(
                        height: scrWidth * 0.02,
                      ),
                      Container(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Features",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: scrWidth * 0.02,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey[50]!],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 3,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          crossAxisCount: MediaQuery.of(context).size.width <
                                  600
                              ? 2
                              : MediaQuery.of(context).size.width < 1000
                                  ? 3
                                  : MediaQuery.of(context).size.width < 1400
                                      ? 4
                                      : MediaQuery.of(context).size.width < 1800
                                          ? 5
                                          : MediaQuery.of(context).size.width <
                                                  2200
                                              ? 6
                                              : 7,
                          crossAxisSpacing:
                              MediaQuery.of(context).size.width * 0.03,
                          mainAxisSpacing:
                              MediaQuery.of(context).size.width * 0.03,
                          childAspectRatio: 1.2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            buildDashboardContainer(
                              context,
                              icon: CupertinoIcons.calendar,
                              label: 'Lesson Planner',
                              gradientColors: [
                                Colors.pink[300]!,
                                Colors.pink[400]!,
                                Colors.pink[500]!,
                                Colors.pink[600]!,
                              ],
                              destination: LessonPlannerPage(),
                            ),
                            buildDashboardContainer(
                              context,
                              icon: CupertinoIcons.rectangle_paperclip,
                              label: 'PPT Generator',
                              gradientColors: [
                                Colors.blue[300]!,
                                Colors.blue[400]!,
                                Colors.blue[500]!,
                                Colors.blue[600]!,
                              ],
                              destination: PPTGeneratorPage(),
                            ),
                            buildDashboardContainer(
                              context,
                              icon: CupertinoIcons.doc_text,
                              label: 'Handout',
                              gradientColors: [
                                Colors.green[300]!,
                                Colors.green[400]!,
                                Colors.green[500]!,
                                Colors.green[600]!,
                              ],
                              destination: HandoutAssignmentPage(),
                            ),
                            buildDashboardContainer(
                              context,
                              icon: CupertinoIcons.rectangle_expand_vertical,
                              label: 'Context Builder',
                              gradientColors: [
                                Colors.orange[300]!,
                                Colors.orange[400]!,
                                Colors.orange[500]!,
                                Colors.orange[600]!,
                              ],
                              destination: contextBuilderPage(),
                            ),
                            buildDashboardContainer(
                              context,
                              icon: CupertinoIcons.gear,
                              label: 'Applications IRL',
                              gradientColors: [
                                Colors.purple[300]!,
                                Colors.purple[400]!,
                                Colors.purple[500]!,
                                Colors.purple[600]!,
                              ],
                              destination: ApplicationRealLife(),
                            ),
                            buildDashboardContainer(
                              context,
                              icon: CupertinoIcons.chat_bubble,
                              label: 'Chat GPT',
                              gradientColors: [
                                Colors.teal[300]!,
                                Colors.teal[400]!,
                                Colors.teal[500]!,
                                Colors.teal[600]!,
                              ],
                              destination: const MyHomePage(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildDashboardContainer(
    BuildContext context, {
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required Widget destination,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 600
        ? 28.0
        : screenWidth < 1000
            ? 32.0
            : screenWidth < 1400
                ? 38.0
                : 42.0;
    final fontSize = screenWidth < 600
        ? 13.0
        : screenWidth < 1000
            ? 14.0
            : screenWidth < 1400
                ? 15.0
                : 16.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(4, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        transform: Matrix4.identity()..scale(1.02),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
