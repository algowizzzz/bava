import 'dart:async'; // Import Timer
import 'package:chatbot/screens/homePage/dashboard.dart';
import 'package:chatbot/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class TeacherAssistanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Assistance App',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<Map<String, String>> features = [
    {
      'image': 'assets/classroom.jpg', // Update with your asset path
      'description': 'Engaging Classroom Environment',
    },
    {
      'image': 'assets/student_activity.jpg', // Update with your asset path
      'description': 'Fostering Collaboration',
    },
    {
      'image': 'assets/teacher_technology.jpg', // Update with your asset path
      'description': 'Utilizing Technology for Teaching',
    },
  ];

  int _currentIndex = 0; // To keep track of the current page
  late Timer _timer; // Timer for automatic sliding
  late PageController _pageController; // PageController for PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Set up a timer to change the page automatically every 2 seconds
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (_currentIndex < features.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Reset to first image after the last
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image Carousel
          PageView.builder(
            itemCount: features.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      features[index]['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // Description Text
                  Positioned(
                    bottom: 80,
                    left: 16,
                    right: 16,
                    child: Text(
                      features[index]['description']!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black54,
                            offset: Offset(0.0, 2.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
            onPageChanged: (index) {
              // Update the current index when the page changes
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          // Smooth Page Indicator

          // Stacked Logo and Title
          Positioned(
            top: 40, // Adjust the top position as needed
            left: 0,
            right: 0,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/logo.jpg'), // Update with your logo asset path
                  radius: 50,
                ),
                SizedBox(height: 10),
                Text(
                  'Teacher Assistance App',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  'Empowering Educators for Success',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),

          // Navigation Button
          Positioned(
            bottom: 20, // Adjust the bottom position as needed
            left: 200,
            right: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to HomeScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              icon: Icon(Icons.login, size: 20), // Icon added
              label: Text(
                'Continue to Login',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Font styling
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.teal, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(vertical: 15), // Vertical padding
                elevation: 5, // Button elevation
              ),
            ),
          ),

        ],
      ),
    );
  }
}
