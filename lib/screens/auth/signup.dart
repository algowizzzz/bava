import 'package:chatbot/main.dart';
import 'package:chatbot/screens/home_page/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:chatbot/services/api_service.dart';
import 'login_screen.dart';

class Signup extends StatefulWidget {
  final String name;
  final String email;


  const Signup({
    Key? key,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController subjectController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool isLoading = false;
  bool isLoadingg = false;
  bool obscurePassword = true;

  Future<void> signUp() async {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        // Register using MongoDB API
        await _apiService.register(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          isTeacher: true,  // This is a teacher signup
          school: schoolController.text.trim(),
          subject: subjectController.text.trim(),
          schoolId: 'school_123',  // Default school ID
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().contains('Exception:') 
              ? e.toString().split('Exception: ')[1]
              : "Signup failed")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: Text("Signup", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[700]!, Colors.purple[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Full Name Input
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.deepPurple[400],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Email Input
                    TextFormField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.deepPurple[400],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Password Input
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.deepPurple[400],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // School Input
                    TextFormField(
                      controller: schoolController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "School",
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.deepPurple[400],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Subject Input
                    TextFormField(
                      controller: subjectController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Subject",
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.deepPurple[400],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Signup Button
                    isLoadingg
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Colors.deepPurple[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Container(
                        height: scrWidth*0.02,
                        width: scrWidth*0.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(scrWidth*0.09)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(child: Icon(Icons.person_add, color: Colors.white)),
                            SizedBox(width: 10),
                            Text(
                              "Signup",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
