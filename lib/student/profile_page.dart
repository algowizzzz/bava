import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  final String studentId;

  const ProfilePage({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  PlatformFile? _selectedFile;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          profileImageUrl = data['profileImageUrl'];
        });
        print('Fetched profile data: $data');
      } else {
        print('No profile found for student ID: ${widget.studentId}');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });

      print('File selected: ${_selectedFile?.name}');
      print('File size: ${_selectedFile?.size} bytes');
    } else {
      print('No file selected.');
    }
  }

  Future<String?> _uploadImageBytesToFirebase(String fileName, Uint8List fileBytes) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.studentId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = storageRef.putData(fileBytes, metadata);

      final taskSnapshot = await uploadTask.whenComplete(() => null);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _selectedFile = PlatformFile(
          name: pickedFile.name,
          bytes: bytes,
          path: pickedFile.path,
          size: bytes.length,
        );
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      String? imageUrl;
      if (_selectedFile != null && _selectedFile!.bytes != null) {
        imageUrl = await _uploadImageBytesToFirebase(
          _selectedFile!.name,
          _selectedFile!.bytes!,
        );
      }

      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .update({
        'name': nameController.text,
        'email': emailController.text,
        'profileImageUrl': imageUrl ?? profileImageUrl ?? '',
      });

      setState(() {
        profileImageUrl = imageUrl ?? profileImageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedFile != null && _selectedFile!.bytes != null
                        ? MemoryImage(_selectedFile!.bytes!)
                        : profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : AssetImage("assets/student_profile.jpg") as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera),
                                title: Text("Camera"),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImageFromCamera();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.image),
                                title: Text("Gallery"),
                                onTap: () {
                                  Navigator.pop(context);
                                  _selectFile();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
