import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PowerPointGenerator extends StatefulWidget {
  @override
  _PowerPointGeneratorState createState() => _PowerPointGeneratorState();
}

class _PowerPointGeneratorState extends State<PowerPointGenerator> {
  String? _authToken;
  bool _isLoading = false;
  String _statusMessage = "Click the button to generate a PowerPoint presentation";

  Future<void> createToken() async {
    var url = Uri.parse("https://auth.powerpointgeneratorapi.com/v1.0/token/create");
    var request = http.MultipartRequest('POST', url)
      ..fields['username'] = "binsiyanazer21@gmail.com"
      ..fields['password'] = "bins1234"
      ..fields['key'] = "22604833-8125-492e-8c39-ba5563738f22";

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseJson = json.decode(responseBody);

        setState(() {
          _authToken = responseJson['result']['access_Token'];
          _statusMessage = "Token generated successfully!";
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to create token. Status code: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _statusMessage = 'Error creating token: $error';
      });
    }
  }

  Future<void> generateAndDownloadPPT() async {
    if (_authToken == null) {
      setState(() {
        _statusMessage = "Token not available. Please generate a token first.";
      });
      return;
    }



    // Step 2: Define jsonData based on the predefined template
    final jsonData =

    {
      'presentation': {
        'export_version': 'Pptx2010',
        'template_list': [
          {'template_id': 1, 'template': 'https://drive.google.com/uc?export=download&id=17s4YBiKexJILreqZsINmhdX-YUdTUcJv'},
          {'template_id': 2, 'template': 'https://drive.google.com/uc?export=download&id=1gwl0vqYO-Q5dP29__NDvV1xCxhWnt5pn'},
          {'template_id': 3, 'template': 'https://drive.google.com/uc?export=download&id=1J-gUPAjMKZgf23U3g_KmtBvnN7O5Xq-9'},
        ],
        'slides': [
          {
            'template_id': 1,
            'type': 'slide',
            'slide_index': 0,
            "shapes": [
              {
                "name": "Title 1",
                "text": " World War"
              },
              {
                "name": "Subtitle 2",
                "text": "SLIDE 1: TITLE SLIDE • Title: World War: Causes, Course, and Consequences • Presenter: [Your Name] • Position: CBSE School Teacher of History • Grade: 10B "
              }
            ]
          },
          {
            'template_id': 2,
            'type': 'slide',
            'slide_index': 0,
            "shapes": [
              {
                "name": "Title 2",
                "content": " SLIDE 2: INTRODUCTION • What is World War? • Definition: A global conflict involving multiple major powers that takes place in several theaters of operation. ",
                "settings": {
                  "text_indent": 10
                }
              }
            ]
          },
          {
            'template_id': 2,
            'type': 'slide',
            'slide_index': 0,
            "shapes": [
              {
                "name": "Title 2",
                "content": "SLIDE 3: CAUSES OF WORLD WAR • Imperialism and Nationalism • Economic Rivalries • Militarism • Alliances and Entanglements • Assassination of Archduke Franz Ferdinand",
                "settings": {
                  "text_indent": 10
                }
              }
            ]
          },
          {
            'template_id': 2,
            'type': 'slide',
            'slide_index': 0,
            "shapes": [
              {
                "name": "Title 2",
                "content": " SLIDE 4: COURSE OF WORLD WAR • Outbreak: August 1914 • Trench Warfare: Stalemate on the Western Front • Eastern Front: Russian victories and setbacks • Middle Eastern and African Fronts • Allied Breakthrough and Armistice: November 1918",
                "settings": {
                  "text_indent": 10
                }
              }
            ]
          },
          {
            'template_id': 2,
            'type': 'slide',
            'slide_index': 0,
            "shapes": [
              {
                "name": "Title 2",
                "content": "SLIDE 5: CONSEQUENCES OF WORLD WAR • Casualties and Devastation • Political Changes: Collapse of empires and new nation-states • Economic Impacts: War debts and inflation",
                "settings": {
                  "text_indent": 10
                }
              }
            ]
          },


        ]
      }
    };
    if (await Permission.storage.request().isGranted) {
      try {
        setState(() {
          _isLoading = true;
          _statusMessage = "Generating PowerPoint presentation...";
        });

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://gen.powerpointgeneratorapi.com/v1.0/generator/create'),
        );
        request.headers['Authorization'] = 'Bearer $_authToken';
        request.fields['jsonData'] = jsonEncode(jsonData);

        final response = await request.send();

        if (response.statusCode == 200) {
          final Uint8List responseBytes = await response.stream.toBytes();
          final directory = await getExternalStorageDirectory();
          final filePath = '${directory?.path}/generated_presentation.pptx';
          final file = File(filePath);

          await file.writeAsBytes(responseBytes);
          setState(() {
            _statusMessage = "File saved at: $filePath";
          });

          final result = await OpenFile.open(filePath);
          if (result.type == ResultType.noAppToOpen) {
            setState(() {
              _statusMessage = "No app found to open the PowerPoint file.";
            });
          }
        } else {
          final responseBody = await response.stream.bytesToString();
          setState(() {
            _statusMessage = "Failed to generate PowerPoint: ${response.statusCode}, Response: $responseBody";
          });
        }
      } catch (e) {
        setState(() {
          _statusMessage = "Error generating PowerPoint: $e";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _statusMessage = "Storage permission denied.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PowerPoint Generator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                children: [
                  ElevatedButton(
                    onPressed: createToken,
                    child: Text("Generate Token"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: generateAndDownloadPPT,
                    child: Text("Generate and open PowerPoint"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
