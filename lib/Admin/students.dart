import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../model/studentModel.dart';
import '../tab_bar.dart';

class Students extends StatefulWidget {
  @override
  _StudentsState createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  final String currentSchoolId = 'school_123';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController parentNumberController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void _showAddStudentDialog() {
    TextEditingController classController = TextEditingController();
    Set<String> selectedSubjects = {};  // Use a Set to track selected subjects

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Add Student",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: "Student Name",
                      icon: Icons.person,
                    ),
                    _buildTextField(
                      controller: passwordController,
                      label: "Enter Password",
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    _buildTextField(
                      controller: emailController,
                      label: "Enter Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: ageController,
                      label: "Age",
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: schoolController,
                      label: "School Name",
                      icon: Icons.school,
                    ),
                    _buildTextField(
                      controller: classController,
                      label: "Class",
                      icon: Icons.class_,
                    ),
                    const SizedBox(height: 10),
                    // Multi-Subject Selection using CheckboxListTile
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('history')
                          .where('className', isEqualTo: classController.text)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text(
                            "No subjects available.",
                            style: TextStyle(color: Colors.red),
                          );
                        }

                        List<String> subjects = snapshot.data!.docs
                            .map((doc) => doc['subject'].toString())
                            .toList();

                        return Column(
                          children: subjects.map((subject) {
                            return CheckboxListTile(
                              title: Text(subject),
                              value: selectedSubjects.contains(subject),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected != null && selected) {
                                    selectedSubjects.add(subject);
                                  } else {
                                    selectedSubjects.remove(subject);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: addressController,
                      label: "Address",
                      icon: Icons.location_on,
                    ),
                    _buildTextField(
                      controller: parentNumberController,
                      label: "Parent Contact Number",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                // Cancel Button
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                // Save Button
                ElevatedButton(
                  onPressed: () {
                    _saveStudent(selectedSubjects.toList());  // Pass selected subjects as list
                  },
                  child: const Text("Add Student"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  Future<void> _saveStudent(List<String> selectedSubjects) async {
    // Check if any fields are empty and selectedSubjects is not empty
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        classController.text.isNotEmpty &&
        schoolController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        parentNumberController.text.isNotEmpty &&
        selectedSubjects.isNotEmpty) {

      setState(() {
        isLoading = true;
      });

      try {
        // Create a new user with email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Generate a unique ID for the student
        String id = FirebaseFirestore.instance.collection('students').doc().id;

        // Create a new student object
        Student newStudent = Student(
          id: id,
          name: nameController.text.trim(),
          password: passwordController.text.trim(),
          age: int.parse(ageController.text.trim()),
          studentClass: classController.text.trim(),
          subjects: selectedSubjects,  // Store multiple subjects as a list
          schoolName: schoolController.text.trim(),
          address: addressController.text.trim(),
          parentNumber: parentNumberController.text.trim(),
          email: emailController.text.trim(),
          historyId: [],
          schoolId: 'school_123',
        );

        // Save the student data to Firestore
        await FirebaseFirestore.instance.collection('students').doc(id).set(newStudent.toMap());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Student added successfully!")),
        );

        // Clear the input fields
        nameController.clear();
        passwordController.clear();
        emailController.clear();
        ageController.clear();
        classController.clear();
        schoolController.clear();
        addressController.clear();
        parentNumberController.clear();

        // Close the dialog
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Error")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding student: $e")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // If any required field is empty, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
    }
  }

  // Future<void> _saveStudent() async {
  //   if (nameController.text.isNotEmpty &&
  //       emailController.text.isNotEmpty &&
  //       passwordController.text.isNotEmpty &&
  //       ageController.text.isNotEmpty &&
  //       classController.text.isNotEmpty &&
  //       schoolController.text.isNotEmpty &&
  //       addressController.text.isNotEmpty &&
  //       parentNumberController.text.isNotEmpty &&
  //       subjectsController.text.isNotEmpty &&
  //       marksController.text.isNotEmpty) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     try {
  //       // Create a new user with email and password
  //       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //         email: emailController.text.trim(),
  //         password: passwordController.text.trim(),
  //       );
  //
  //       // Generate student ID
  //       String id = FirebaseFirestore.instance.collection(userCredential.user!.uid).doc().id;
  //
  //       // Create the student model
  //       Student newStudent = Student(
  //         id: id,
  //         name: nameController.text.trim(),
  //         password: passwordController.text.trim(),
  //         age: int.parse(ageController.text.trim()),
  //         studentClass: classController.text.trim(),
  //         subjects: subjectsController.text.trim().split(',').map((e) => e.trim()).toList(),
  //         schoolName: schoolController.text.trim(),
  //         address: addressController.text.trim(),
  //         parentNumber: parentNumberController.text.trim(),
  //         marks: _parseMarks(marksController.text.trim()),
  //         email: emailController.text.trim(),
  //         historyId: [],
  //         schoolId: 'school_123',
  //       );
  //
  //       // Save the student to Firestore
  //       await FirebaseFirestore.instance
  //           .collection('students')
  //           .doc(id)
  //           .set(newStudent.toMap());
  //
  //       // Provide feedback to the user
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Student added successfully!")),
  //       );
  //
  //       // Clear fields after saving and navigate
  //       nameController.clear();
  //       passwordController.clear();
  //       emailController.clear();
  //       ageController.clear();
  //       classController.clear();
  //       schoolController.clear();
  //       addressController.clear();
  //       parentNumberController.clear();
  //       subjectsController.clear();
  //       marksController.clear();
  //
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => LoginTabScreen()),
  //       );
  //     } on FirebaseAuthException catch (e) {
  //       // Handle FirebaseAuthException (like email already in use)
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.message ?? "failed")),
  //       );
  //     } catch (e) {
  //       // Handle other errors
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error adding student: $e")),
  //       );
  //     } finally {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please fill out all fields")),
  //     );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students Details"),),
      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: const Text("Add Student"),
                  onPressed: _showAddStudentDialog,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
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
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .where('schoolId', isEqualTo: currentSchoolId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No student data found.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                // Filter students based on search query
                List<QueryDocumentSnapshot> students = snapshot.data!.docs
                    .where((studentDoc) {
                  return studentDoc['name'].toString().toLowerCase().contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    var student = students[index].data() as Map<String, dynamic>;
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
                          student['name'] ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email: ${student['email'] ?? 'No Email'}"),
                            Text("Class: ${student['class'] ?? 'N/A'}"),
                            Text("School ID: ${student['schoolId'] ?? 'N/A'}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentDetailView(studentData: student,),
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

class StudentDetailView extends StatelessWidget {
  final Map<String, dynamic> studentData;

  StudentDetailView({required this.studentData});

  @override
  Widget build(BuildContext context) {
    List<String> subjects = List<String>.from(studentData['subjects'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('${studentData['name']}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${studentData['name']}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 8),
            _infoRow('Email', studentData['email']),
            _infoRow('Age', studentData['age']),
            _infoRow('Class', studentData['class']),
            _infoRow('Parent Number', studentData['parentNumber']),
            _infoRow('School', studentData['schoolName']),
            SizedBox(height: 16),
            Text(
              'Subjects & Teachers:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 8),
            subjects.isNotEmpty
                ? Column(
              children: subjects.map((subject) {
                return _subjectWithTeacher(subject, studentData['class'], studentData['schoolId'] ?? ''); // Provide default empty string if null
              }).toList(),
            )
                : Text('No subjects available.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _subjectWithTeacher(String subject, String className, String schoolId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('history')
          .where('subject', isEqualTo: subject)
          .where('className', isEqualTo: className)
      // .where('schoolId', isEqualTo: schoolId) // Uncomment if needed
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$subject: Loading...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$subject: No teacher available',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        }

        List teacherUids = snapshot.data!.docs.map((doc) {
          return doc['userUid']; // Make sure 'userUid' exists
        }).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$subject:',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              teacherUids.isNotEmpty
                  ? Column(
                children: teacherUids.map((uid) {
                  return _fetchTeacherName(uid);
                }).toList(),
              )
                  : Text('No teacher available', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  Widget _fetchTeacherName(String userUid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Teacher').doc(userUid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Loading teacher name...'),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Teacher not found', style: TextStyle(color: Colors.black)),
          );
        }

        String teacherName = snapshot.data!['name'] ?? 'Unknown Teacher';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  teacherName,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              '$value',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

