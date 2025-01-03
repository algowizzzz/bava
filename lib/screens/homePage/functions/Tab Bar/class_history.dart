import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../model/historyModel.dart';
import '../../../gemini/gemini_screen.dart';

class ClassHistoryPage extends StatefulWidget {
  final String classname;
  final String subject;

  const ClassHistoryPage({
    Key? key,
    required this.subject,
    required this.classname,
  }) : super(key: key);

  @override
  _ClassHistoryPageState createState() => _ClassHistoryPageState();
}

class _ClassHistoryPageState extends State<ClassHistoryPage> {
  late final CollectionReference classHistoryCollection;
  bool isContentGenerated = false;

  @override
  void initState() {
    super.initState();
    classHistoryCollection = FirebaseFirestore.instance.collection('history');
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('history')
            .where('className', isEqualTo: widget.classname)
            .where('subject', isEqualTo: widget.subject)
            .snapshots(),
        builder: (context, historySnapshot) {
          if (historySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (historySnapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          }
          if (!historySnapshot.hasData || historySnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No history available.'));
          }

          DocumentSnapshot historyDoc = historySnapshot.data!.docs.first;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('history')
                .doc(historyDoc.id)
                .collection('topics')
                .snapshots(),
            builder: (context, topicsSnapshot) {
              if (topicsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (topicsSnapshot.hasError) {
                return const Center(child: Text('Error loading topics'));
              }
              if (!topicsSnapshot.hasData || topicsSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No topics available.'));
              }

              return ListView.builder(
                itemCount: topicsSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var topicDoc = topicsSnapshot.data!.docs[index];
                  var topicData = topicDoc.data() as Map<String, dynamic>;

                  final topic = topicData['topic'] ?? 'No Topic Available';
                  final lessonPlan = topicData['lessonPlan'] ?? 'No Lesson Plan Available';
                  final ppt = topicData['ppt'] ?? 'No PPT Available';
                  final handout = topicData['handout'] ?? 'No Handout Available';
                  final contextBuilder = topicData['contextBuilder'] ?? 'No Context Builder Available';
                  final applicationInRealLife = topicData['applicationsInRealLife'] ?? 'No Application in Real Life Available';
                  final date = topicData['createdAt'];

                  return Padding(
                    padding: EdgeInsets.all(scrWidth * 0.01),
                    child: Container(
                      height: scrHeight * 0.1,
                      width: scrWidth * 0.1,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: scrWidth * 0.05),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  topic.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: scrWidth * 0.015, // Smaller font size
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                SizedBox(width: scrWidth * 0.03),
                                TextButton.icon(
                                  onPressed: () {
                                    _showContentDialog("Lesson Plan", lessonPlan, "lessonPlan", topic, historyDoc.id, topicDoc.id);
                                  },
                                  icon: Icon(Icons.school, color: Colors.deepPurple, size: scrWidth * 0.02), // Smaller icon size
                                  label: Text(
                                    "Lesson Plan",
                                    style: TextStyle(fontSize: scrWidth * 0.01, color: Colors.deepPurple), // Smaller font size
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    _showContentDialog("PPT", ppt, "ppt", topic, historyDoc.id, topicDoc.id);
                                  },
                                  icon: Icon(Icons.slideshow, color: Colors.deepPurple, size: scrWidth * 0.02),
                                  label: Text(
                                    "PPT",
                                    style: TextStyle(fontSize: scrWidth * 0.01, color: Colors.deepPurple),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    _showContentDialog("Handout", handout, "handout", topic, historyDoc.id, topicDoc.id);
                                  },
                                  icon: Icon(Icons.assignment, color: Colors.deepPurple, size: scrWidth * 0.02),
                                  label: Text(
                                    "Handout",
                                    style: TextStyle(fontSize: scrWidth * 0.01, color: Colors.deepPurple),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    _showContentDialog("Context Builder", contextBuilder, "contextBuilder", topic, historyDoc.id, topicDoc.id);
                                  },
                                  icon: Icon(Icons.build, color: Colors.deepPurple, size: scrWidth * 0.02),
                                  label: Text(
                                    "Context Builder",
                                    style: TextStyle(fontSize: scrWidth * 0.01, color: Colors.deepPurple),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    _showContentDialog("Application in Real Life", applicationInRealLife, "applicationInRealLife", topic, historyDoc.id, topicDoc.id);
                                  },
                                  icon: Icon(Icons.public, color: Colors.deepPurple, size: scrWidth * 0.02),
                                  label: Text(
                                    "Applications In Real Life",
                                    style: TextStyle(fontSize: scrWidth * 0.01, color: Colors.deepPurple),
                                  ),
                                ),
                                Text(
                                  "DATE: $date",
                                  style: TextStyle(fontSize: scrWidth * 0.01, color: Colors.black54),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: scrWidth * 0.02),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Delete"),
                                          content: const Text("Are you sure you want to delete this item?", style: TextStyle(color: Colors.black)),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text("Delete"),
                                              onPressed: () {
                                                _deleteHistoryEntry(historyDoc.id, topicDoc.id);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showContentDialog(String title, String content, String fieldType, String topic, String historyDocId, String topicDocId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),

                // Content Text (formatted)
                _formatContent(content),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  child: Text(isContentGenerated ? "Regenerate" : "Generate"),
                  onPressed: () {
                    print("Prompt: ${isContentGenerated ? content : _generatePrompt(fieldType, topic)}");
                    print("Content Type: $fieldType");
                    print("History Doc ID: $historyDocId");
                    print("Topic: $topic");
                    print("Topic ID: $topicDocId");

                    setState(() {
                      isContentGenerated = false;
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => geminiScreen(
                          prompt:isContentGenerated?content : _generatePrompt(fieldType, topic),
                          topicId:topicDocId,
                          contentType: fieldType,
                          documentId: historyDocId, // Pass historyDoc.id here
                        ),
                      ),
                    );
                  },
                ),
                TextButton(
                  child: const Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _formatContent(String content) {
    if (content.contains("**")) {
      List<String> parts = content.split("**");
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts.map((part) {
          if (part.contains("**")) {
            return Text(
              part.replaceAll("**", ""),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            );
          }
          return Text(part);
        }).toList(),
      );
    }
    return Text(content);
  }

  void _deleteHistoryEntry(String historyDocId, String topicDocId) {
    FirebaseFirestore.instance
        .collection('history')
        .doc(historyDocId)
        .collection('topics')
        .doc(topicDocId)
        .delete()
        .then((_) {
      print("Topic deleted successfully");
    }).catchError((error) {
      print("Failed to delete topic: $error");
    });
  }

  String _generatePrompt(String fieldType, String topic) {
    return "Generate a $fieldType for the topic '$topic'.";
  }
}
