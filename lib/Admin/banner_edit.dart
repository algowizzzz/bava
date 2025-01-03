import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class BannerEditScreen extends StatefulWidget {
  final String? bannerId;
  final String? existingImageUrl;

  const BannerEditScreen({Key? key, this.bannerId, this.existingImageUrl}) : super(key: key);

  @override
  _BannerEditScreenState createState() => _BannerEditScreenState();
}

class _BannerEditScreenState extends State<BannerEditScreen> {
  File? _imageFile;
  bool _isLoading = false;
  // final ImagePicker _picker = ImagePicker();

  // Future<void> _pickImage() async {
  //   final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  // Future<void> _saveBanner() async {
  //   if (_imageFile == null && widget.existingImageUrl == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select an image')),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     String imageUrl = widget.existingImageUrl ?? '';

  //     if (_imageFile != null) {
  //       final storageRef = FirebaseStorage.instance
  //           .ref()
  //           .child('banners')
  //           .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

  //       await storageRef.putFile(_imageFile!);
  //       imageUrl = await storageRef.getDownloadURL();
  //     }

  //     final bannersRef = FirebaseFirestore.instance.collection('banners');

  //     if (widget.bannerId != null) {
  //       await bannersRef.doc(widget.bannerId).update({
  //         'imageUrl': imageUrl,
  //         'updatedAt': FieldValue.serverTimestamp(),
  //       });
  //     } else {
  //       await bannersRef.add({
  //         'imageUrl': imageUrl,
  //         'createdAt': FieldValue.serverTimestamp(),
  //         'updatedAt': FieldValue.serverTimestamp(),
  //       });
  //     }

  //     Navigator.pop(context);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bannerId != null ? 'Edit Banner' : 'Add Banner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: 200,
                fit: BoxFit.cover,
              )
            else if (widget.existingImageUrl != null)
              Image.network(
                widget.existingImageUrl!,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              Image.asset(
                'assets/banner.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (){},
              // onPressed: _isLoading ? null : _pickImage,
              child: Text(_imageFile != null || widget.existingImageUrl != null
                  ? 'Change Image'
                  : 'Select Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (){},
              // onPressed: _isLoading ? null : _saveBanner,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.bannerId != null ? 'Update Banner' : 'Save Banner'),
            ),
          ],
        ),
      ),
    );
  }
}
