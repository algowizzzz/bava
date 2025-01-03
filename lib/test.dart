// import 'package:chatbot/screens/auth/signup.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Admin/Admin_dashboard.dart';
// import '../../Admin/admin_panel.dart';
// import '../../Admin/tab_admin.dart';
// import '../../student/student_dashboard.dart';
// import '../homePage/dashboard.dart';
// import '../forgot password/forgotpassword1.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;
//   String errorMessage = '';
//
//   void handleLogin() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });
//
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       setState(() {
//         errorMessage = 'Email and Password cannot be empty.';
//         isLoading = false;
//       });
//       return;
//     }
//
//     try {
//       // Firebase Authentication for login
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       if (userCredential.user != null) {
//         String uid = userCredential.user!.uid;
//
//         // Check Teacher Collection
//         DocumentSnapshot<Map<String, dynamic>> teacherDoc = await FirebaseFirestore.instance
//             .collection('Teacher')
//             .doc(uid)
//             .get();
//
//         // Check Student Collection
//         QuerySnapshot studentQuery = await FirebaseFirestore.instance
//             .collection('students')
//             .where('email', isEqualTo: email)
//             .get();
//
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//
//         await prefs.setString('uid', uid);
//         await prefs.setString('email', email);
//
//         if (teacherDoc.exists) {
//           bool isAdmin = teacherDoc['isAdmin'] ?? false;
//           await prefs.setBool('isAdmin', isAdmin); // Store isAdmin
//
//           String name = teacherDoc['name'] ?? 'Teacher';
//           await prefs.setString('name', name);
//
//           if (isAdmin) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => AdminPanel()),
//             );
//           } else {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => DashboardScreen()),
//             );
//           }
//         } else if (studentQuery.docs.isNotEmpty) {
//           String studentId = studentQuery.docs[0].id;
//           String studentName = studentQuery.docs[0]['name'] ?? 'Student';
//
//           await prefs.setString('studentId', studentId);  // Save student ID
//           await prefs.setString('studentName', studentName);  // Save student name
//
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => studentDashboard(studentId: studentId),
//             ),
//           );
//         } else {
//           setState(() {
//             errorMessage = 'No associated data found for this account.';
//           });
//           await _auth.signOut();
//         }
//       } else {
//         setState(() {
//           errorMessage = 'Login Failed. Please check your credentials.';
//         });
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         errorMessage = e.message ?? 'Login Failed. Please check your credentials.';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     double scrWidth = MediaQuery.of(context).size.width;
//     double scrHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       body: Container(
//         height: scrHeight,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.deepPurple[700]!, Colors.purple[400]!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 100),
//               Text(
//                 'Welcome Back',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Please login to continue',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white70,
//                 ),
//               ),
//               SizedBox(height: 32),
//               Container(
//                 width: scrWidth * 0.8,
//                 child: TextField(
//                   controller: emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     labelStyle: TextStyle(color: Colors.white),
//                     prefixIcon: Icon(Icons.email, color: Colors.white),
//                     filled: true,
//                     fillColor: Colors.deepPurple[400],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               SizedBox(height: 16),
//               Container(
//                 width: scrWidth * 0.8,
//                 child: TextField(
//                   controller: passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     labelStyle: TextStyle(color: Colors.white),
//                     prefixIcon: Icon(Icons.lock, color: Colors.white),
//                     filled: true,
//                     fillColor: Colors.deepPurple[400],
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   obscureText: true,
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ForgotPasswordPage(),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'Forgot Password?',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//               SizedBox(height: 20),
//               if (isLoading)
//                 CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               if (!isLoading)
//                 ElevatedButton(
//                   onPressed: handleLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: Text(
//                     'Login',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.deepPurple[700],
//                     ),
//                   ),
//                 ),
//               SizedBox(height: 20),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => Signup(name: '', email: ''),
//                     ),
//                   );
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't have an account? ",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     Text(
//                       "Sign up",
//                       style: TextStyle(color: Colors.white70),
//                     ),
//                   ],
//                 ),
//               ),
//               if (errorMessage.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 20),
//                   child: Text(
//                     errorMessage,
//                     style: TextStyle(color: Colors.red, fontSize: 16),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
