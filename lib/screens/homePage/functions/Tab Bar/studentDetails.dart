import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsPage extends StatefulWidget {
  final String classname;
  final String subject;

  StudentDetailsPage({required this.classname, required this.subject});

  @override
  _StudentDetailsPageState createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students in ${widget.classname} - ${widget.subject}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('class', isEqualTo: widget.classname)
            .where('subjects', arrayContains: widget.subject)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No students found for ${widget.classname} - ${widget.subject}.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading data', style: TextStyle(color: Colors.red)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var studentData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                  color: Colors.white,
                ),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      studentData['name'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    studentData['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(text: 'Email: ${studentData['email']}\n'),
                        TextSpan(text: 'Age: ${studentData['age']}'),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentDetailView(studentData: studentData),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
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
              'Subjects:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 8),
            subjects.isNotEmpty
                ? Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: subjects.map((subject) => Chip(label: Text(subject))).toList(),
            )
                : Text('No subjects available.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
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
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
