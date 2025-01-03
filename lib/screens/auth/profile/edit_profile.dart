import 'package:chatbot/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../model/teacherModel.dart';

class EditProfilePage extends StatefulWidget {
  final TeacherModel teacher;

  EditProfilePage({required this.teacher});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;

  @override
  void initState() {
    super.initState();
    _name = widget.teacher.name;
    _email = widget.teacher.email;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _auth.currentUser;

        if (user != null) {
          // Update Firestore document (without updating the email)
          await _firestore.collection("Teacher").doc(user.uid).update({
            'name': _name,
            // Include other fields you want to update
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully!")),
          );

          Navigator.pop(context); // Go back to the profile page
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: scrHeight*1,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[700]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Update Your Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Name Field
                  _buildTextField(
                    label: "Full Name",
                    initialValue: _name,
                    onChanged: (value) => _name = value,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16),

                  // Email Field
                  _buildTextField(
                    label: "Email",
                    initialValue: _email,
                    onChanged: (value) => _email = value,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),


                  SizedBox(height: 50),

                  // Update Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Colors.deepPurple[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Update Profile",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Container(
      width: scrWidth*0.5,
      child:TextFormField(
        initialValue: initialValue,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white), // Set text color to white
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white, // Label text color
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // Makes label float when text is entered
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          filled: true, // Makes the background color of the text field solid
          fillColor: Colors.purple[700], // Background color for the text field
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide.none, // No underline when it's not focused
            borderRadius: BorderRadius.circular(scrWidth*0.04)
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide.none, // No underline when focused
              borderRadius: BorderRadius.circular(scrWidth*0.04)
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide.none, // No underline on error
              borderRadius: BorderRadius.circular(scrWidth*0.04)
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide.none, // No underline on error when focused
              borderRadius: BorderRadius.circular(scrWidth*0.04)
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      )

    );
  }
}
