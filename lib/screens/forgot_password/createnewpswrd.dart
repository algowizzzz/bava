import 'package:chatbot/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/profile/profile_page.dart';



class CreateNewPassword extends StatefulWidget {
  const CreateNewPassword({super.key});

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  final passwordValidation = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  final formKey = GlobalKey<FormState>();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  bool remember = false;
  bool hide1 = true;
  bool hide2 = true;

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8), // Adjust padding
          child: InkWell(
            onTap: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(scrWidth * 0.08), // Adjust radius as needed
              ),
              padding: EdgeInsets.all(8), // Adjust the padding inside the container for the icon
              child: Icon(
                Icons.arrow_back,
                color: Colors.purple, // Adjust icon size based on screen width
              ),
            ),
          ),
        ),
        title: Text(
          "Create New Password",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0, // Optional: removes shadow for a cleaner look
      ),


      body: Container(
        height: scrHeight*1,
        width: scrWidth*1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[700]!, Colors.purple[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: scrHeight*0.85,
                width: scrWidth*0.4,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(scrWidth * 0.03)),
                  elevation: 4,
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: EdgeInsets.all(scrWidth * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Your New Password",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: scrWidth*0.018,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              _buildPasswordField(
                                "Enter New Password",
                                password1Controller,
                                hide1,
                                    (value) {
                                  if (!passwordValidation.hasMatch(value!)) {
                                    return "Password must be 8+ characters, including uppercase, \nlowercase, numbers & special characters.";
                                  }
                                },
                                    () {
                                  setState(() {
                                    hide1 = !hide1;
                                  });
                                },
                                scrWidth,
                              ),
                              SizedBox(height: scrWidth*0.02,),
                              _buildPasswordField(
                                "Confirm New Password",
                                password2Controller,
                                hide2,
                                    (value) {
                                  if (password2Controller.text != password1Controller.text) {
                                    return "Passwords don't match";
                                  }
                                },
                                    () {
                                  setState(() {
                                    hide2 = !hide2;
                                  });
                                },
                                scrWidth,
                              ),

                              Row(
                                children: [
                                  Checkbox(
                                    value: remember,
                                    onChanged: (value) {
                                      setState(() {
                                        remember = value!;
                                      });
                                    },
                                    activeColor: Colors.deepPurple,
                                  ),
                                  Text(
                                    "Remember me",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(scrWidth * 0.05),
                              ),

                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  // Update the password in Firebase Authentication
                                  User? user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    await user.updatePassword(password1Controller.text);

                                    // Update the Firestore document with new password if necessary
                                    await FirebaseFirestore.instance
                                        .collection('Teacher') // Replace 'users' with your collection name
                                        .doc(user.uid) // Use the authenticated user's UID
                                        .update({'password': password1Controller.text}); // Example field

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Password successfully updated!")),
                                    );

                                    // Navigate to the Profile Page
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfilePage()), // Replace with your actual ProfilePage
                                    );
                                  }
                                } catch (e) {
                                  // Handle errors (e.g., reauthentication required)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error updating password: ${e.toString()}")),
                                  );
                                }
                              } else {
                                // Show an error message if validation fails
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Please fix the errors and try again.")),
                                );
                              }
                            },

                            child: Text(
                              "Continue",
                              style:TextStyle(
                                color: Colors.white
                              ),
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
      ),
    );
  }

  Widget _buildPasswordField(
      String label,
      TextEditingController controller,
      bool obscureText,
      String? Function(String?) validator,
      VoidCallback onTapSuffix,
      double scrWidth,
      ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.deepPurple,
        ),
        filled: true,
        fillColor: Colors.deepPurple.withOpacity(0.1),
        suffixIcon: InkWell(
          onTap: onTapSuffix,
          child: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.deepPurple,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scrWidth * 0.03),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
      ),
    );
  }
}
