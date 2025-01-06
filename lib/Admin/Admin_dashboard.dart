import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/historyModel.dart';
import '../model/teacherModel.dart';
import '../screens/home_page/functions/Tab_Bar/class_history.dart';
import '../student/functions/teacher_details_view.dart';
import 'teacher_details.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final CollectionReference teacherCollection =
  FirebaseFirestore.instance.collection('Teacher');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? adminSchoolId;
  bool isLoading = false;
  String searchTerm = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final CollectionReference _classesCollection =
  FirebaseFirestore.instance.collection('history');
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _getAdminSchoolId();
  }

  Future<void> _getAdminSchoolId() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final adminDoc =
        await FirebaseFirestore.instance.collection('Teacher').doc(userId).get();

        if (adminDoc.exists) {
          setState(() {
            adminSchoolId = adminDoc.data()?['schoolId'];
          });
        } else {
          throw Exception('Admin data not found');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching admin data: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addTeacher() async {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await teacherCollection.doc(userCredential.user!.uid).set(
          TeacherModel(
            id: userCredential.user!.uid,
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            isAdmin: false,
            schoolId: adminSchoolId ?? 'school_123',
            classList: [],
          ).toFirestore(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Teacher added successfully!")),
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Failed to add teacher")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher Details"),),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Teacher Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Add Teacher'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(labelText: 'Name'),
                              ),
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(labelText: 'Email'),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(labelText: 'Password'),
                                obscureText: true,
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: addTeacher,
                              child: const Text('Add'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Add Teacher',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: teacherCollection
                  .where('isAdmin', isEqualTo: false)
                  .where('schoolId', isEqualTo: adminSchoolId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading data"));
                }

                final teachers = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  return name.contains(searchTerm);
                }).toList();

                if (teachers.isEmpty) {
                  return const Center(child: Text("No teachers found"));
                }

                return ListView.builder(
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacherData = teachers[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple[100],
                          child: const Icon(Icons.person, color: Colors.deepPurple),
                        ),
                        title: Text(
                          teacherData['name'] ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email: ${teacherData['email'] ?? 'No Email'}"),
                            Text("School ID: ${teacherData['schoolId'] ?? 'N/A'}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeacherDetailView(
                                  teacherData: teacherData,  // Pass the teacher data to the detail view
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



