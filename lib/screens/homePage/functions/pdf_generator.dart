import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class PdfGeneratorScreen extends StatefulWidget {
  final String content;

  PdfGeneratorScreen({
    required this.content,
  });

  @override
  _PdfGeneratorScreenState createState() => _PdfGeneratorScreenState();
}

class _PdfGeneratorScreenState extends State<PdfGeneratorScreen> {
  late String htmlContent;

  @override
  void initState() {
    super.initState();
    htmlContent = _convertTextToHtml(_replaceDotWithAsterisk(widget.content));   }


  // Replace dot at the start of the line with an asterisk
  String _replaceDotWithAsterisk(String text) {
    List<String> lines = text.split('\n');
    List<String> processedLines = [];

    for (String line in lines) {
      // Check if the line starts with a '.' and replace it with '*'
      String cleanedLine = line.trim();
      if (cleanedLine.startsWith('.')) {
        cleanedLine = '*' + cleanedLine.substring(1).trim();  // Replace '.' with '*'
      }
      processedLines.add(cleanedLine);
    }

    return processedLines.join('\n');  // Join the processed lines back together
  }
  String _removeBulletPointsUsingReplaceAll(String text) {
    // Replace bullet points (start of line) with an empty string
    return text.replaceAll(RegExp(r'^[.*]\s*', multiLine: true), '');
  }
  String _convertTextToHtml(String text) {
    text = _removeBulletPointsUsingReplaceAll(text);
    return """
      <!DOCTYPE html>
      <html>
      <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
              body { font-family: Arial, sans-serif; }
              h1 { color: #4CAF50; }
              p { color: #555; }
          </style>
      </head>
      <body>
          <h1>PDF Generated</h1>
          <p>$text</p>
      </body>
      </html>
    """;
  }

  Future<void> _generatePdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            List<pw.Widget> pageWidgets = [];
            pageWidgets.add(_buildSection('Content', widget.content));

            return pageWidgets;
          },
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final file = File("${output.path}/content.pdf");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved to ${file.path}")),
      );

      OpenFile.open(file.path);
    } catch (e) {
      print("Error generating PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate PDF: $e")),
      );
    }
  }

  pw.Widget _buildSection(String title, String content) {
    if (content.trim().isEmpty) {
      return pw.SizedBox();
    }
    List<String> paragraphs = content.split('\n').where((p) => p.trim().isNotEmpty).toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        for (String paragraph in paragraphs)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                paragraph,
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
            ],
          ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate PDF'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                color: Colors.white,
                child: Html(
                  data: htmlContent,
                  style: {
                    "body": Style(color: Colors.black),
                    "h1": Style(color: Colors.green),
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generatePdf,
                child: Text('Generate and View PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
