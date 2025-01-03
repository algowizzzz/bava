import 'package:chatbot/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../model/classModel.dart';
import '../../../model/historyModel.dart';
import '../../../model/teacherModel.dart';
import '../../forgot password/createnewpswrd.dart';
import '../../homePage/functions/Tab Bar/class_history.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TeacherModel? teacher;
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _showDeleteConfirmationDialog(BuildContext context, String historyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple[100],
          title: const Text('Delete History', style: TextStyle(color: Colors.deepPurple)),
          content: const Text('Are you sure you want to delete this history?', style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('history').doc(historyId).delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchProfileData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection("Teacher")
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          setState(() {
            teacher = TeacherModel.fromFirestore(docSnapshot);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile not found.")),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching profile data: $e")),
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: const Text("Profile", style: TextStyle(fontSize: 22)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : teacher == null
                  ? Center(
                child: Text(
                  "No profile data available",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              )
                  : Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.purple,
                        // backgroundImage: NetworkImage(teacher!.photoUrl ?? 'https://www.example.com/default-avatar.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(teacher: teacher!),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[700],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, size: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: scrWidth * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "Full Name: ${teacher!.name}",
                          style: TextStyle(color: Colors.purple, fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Email: ${teacher!.email}",
                          style: TextStyle(color: Colors.purple, fontSize: 18),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreateNewPassword()),
                            );
                          },
                          child: Text(
                            "Change Password",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          child: Text("View Classes", style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  content: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('history')
                                        .where('userUid', isEqualTo: currentUserUid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text("Error loading history", style: TextStyle(color: Colors.white)));
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      }

                                      final historyDocs = snapshot.data?.docs ?? [];
                                      final Set<String> uniqueClasses = {};
                                      final List<HistoryModel> uniqueHistory = [];

                                      for (var doc in historyDocs) {
                                        final historyData = doc.data() as Map<String, dynamic>;
                                        final className = historyData['className'] ?? 'No Class Name';
                                        final subject = historyData['subject'] ?? 'No Subject';
                                        final uniqueKey = '$className|$subject';

                                        if (!uniqueClasses.contains(uniqueKey)) {
                                          uniqueClasses.add(uniqueKey);
                                          uniqueHistory.add(HistoryModel(
                                            history_id: historyData['history_id'],
                                            date: DateTime.now(),
                                            topic: historyData['topic'] ?? 'No Topic',
                                            className: className,
                                            subject: subject,
                                            userUid: '',
                                          ));
                                        }
                                      }

                                      uniqueHistory.sort((a, b) => b.date.compareTo(a.date));

                                      if (uniqueHistory.isEmpty) {
                                        return Center(
                                            child: Text("No history available.", style: TextStyle(fontSize: 18, color: Colors.grey)));
                                      }

                                      return ListView.builder(
                                        itemCount: uniqueHistory.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final history = uniqueHistory[index];
                                          return ListTile(
                                            title: Text('Class: ${history.className} \nSubject: ${history.subject}', style: TextStyle(color: Colors.white)),
                                            trailing: IconButton(
                                              icon: Icon(Icons.delete, color: Colors.white),
                                              onPressed: () {
                                                _showDeleteConfirmationDialog(context, history.history_id);
                                              },
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ClassHistoryPage(subject:
                                                    history.subject, classname: history.className),
                                              ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
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
}
