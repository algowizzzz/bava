import 'package:chatbot/main.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'chat_pdf.dart';

class UploadPdfPage extends StatefulWidget {
  @override
  _UploadPdfPageState createState() => _UploadPdfPageState();
}

class _UploadPdfPageState extends State<UploadPdfPage> {
  bool isUploading = false;
  String uploadMessage = '';
  String? sourceId;

  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }

  Future<void> uploadFileToChatPdf(File file) async {
    String url = 'https://api.chatpdf.com/v1/sources/add-file';
    String apiKey = 'sec_fE4xOxJMfiXT5OiTtVPOIFH0dzHbvjaa'; // Replace with your actual API key

    try {
      setState(() {
        isUploading = true;
        uploadMessage = '';
      });

      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: "file.pdf"),
      });

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          sourceId = response.data['sourceId'];
          uploadMessage = 'File uploaded successfully! Navigating to chat...';

          // Navigate to the ChatPdfMessagePage and pass the sourceId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPdfMessagePage(sourceId: sourceId!),
            ),
          );
        });
      } else {
        setState(() {
          uploadMessage = 'Error: Failed to upload file. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        uploadMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload PDF'),
        backgroundColor: Colors.deepPurple[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isUploading
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            strokeWidth: 6,
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: scrWidth*0.04,
                width: scrWidth*0.4,
                child: ElevatedButton(
                  onPressed: () async {
                    File? file = await pickFile();
                    if (file != null) {
                      await uploadFileToChatPdf(file);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No file selected!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[700], // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Pick and Upload PDF',style: TextStyle(color: Colors.white),),
                ),
              ),
              SizedBox(height: 20),
              if (uploadMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        uploadMessage.startsWith('Error') ? Icons.error : Icons.check_circle,
                        color: uploadMessage.startsWith('Error') ? Colors.red : Colors.green,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        uploadMessage,
                        style: TextStyle(
                          color: uploadMessage.startsWith('Error') ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
