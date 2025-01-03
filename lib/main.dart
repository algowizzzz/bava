import 'package:chatbot/screens/auth/login_screen.dart';
import 'package:chatbot/screens/homePage/dashboard.dart';
import 'package:chatbot/student/student_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Admin/admin_panel.dart';
import 'services/Themes.dart';
import 'services/themeNotifier.dart';

late double scrWidth;
late double scrHeight;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.containsKey('uid');
  bool isAdmin = prefs.getString('type') == 'admin';
  bool isStudent = prefs.getString('type') == 'student';
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyA6XQ2xG0een1NB50VLfIx8vRWwGNBC2fM",
          appId: 'com.example.chatbot',
          messagingSenderId: "225366500550",
          projectId: "chatbot-bbf51",
          storageBucket:'chatbot-bbf51.firebasestorage.app'
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await dotenv.load(fileName: ".env");

  runApp(
    ProviderScope(
      child: MyApp(isLoggedIn: isLoggedIn, isAdmin: isAdmin, isStudent: isStudent),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool isLoggedIn;
  final bool isAdmin;
  final bool isStudent;

  const MyApp({
    Key? key,
    required this.isLoggedIn,
    required this.isAdmin,
    required this.isStudent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    scrWidth = MediaQuery.of(context).size.width;
    scrHeight = MediaQuery.of(context).size.height;

    final themeMode = ref.watch(themeProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        title: 'Chatbot App',
        theme: lightMode,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home:
        isLoggedIn
            ? isAdmin
            ? AdminPanel()
            : isStudent
            ? FutureBuilder<String>(
          future: _getStudentId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData) {
              return studentDashboard(studentId: snapshot.data!);
            } else {
              return LoginScreen();
            }
          },
        )
            : DashboardScreen()
            :
        LoginScreen(),
      ),
    );
  }


  Future<String> _getStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('studentId') ?? ''; // Return empty string if not found
  }
}
