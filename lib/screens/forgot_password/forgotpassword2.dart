import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage2 extends StatefulWidget {
  static String verificationId = "";

  @override
  State<ForgotPasswordPage2> createState() => _ForgotPasswordPage2State();
}

class _ForgotPasswordPage2State extends State<ForgotPasswordPage2> {
  final TextEditingController _codeController = TextEditingController();
  String? _verificationCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Phone Number"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the verification code sent to your phone:",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _verificationCode = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_verificationCode != null && _verificationCode!.isNotEmpty) {
                  _verifyCode();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter the verification code.")),
                  );
                }
              },
              child: Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyCode() async {
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: ForgotPasswordPage2.verificationId,
      smsCode: _verificationCode!,
    );

    try {
      // Sign in the user with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to the password reset page or show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification successful! You can now reset your password.")),
      );

      // Here, you can navigate to a password reset page
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));

    } on FirebaseAuthException catch (e) {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed. Please try again.")),
      );
    }
  }
}
