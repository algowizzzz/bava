class Student {
  String id;
  String name;
  String email;
  String password;
  int age;
  String studentClass;
  List<String> subjects;
  String schoolName;
  String address;
  String parentNumber;
  List<String> historyId;
  String schoolId;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.studentClass,
    required this.subjects,
    required this.schoolName,
    required this.address,
    required this.parentNumber,
    required this.historyId,
    required this.schoolId,
  });

  // Method to convert a Student object to a Map (useful for Firebase or JSON storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'class': studentClass,
      'subjects': subjects,
      'schoolName': schoolName,
      'address': address,
      'parentNumber': parentNumber,
      'historyId': historyId,
      'schoolId': schoolId,
    };
  }

  // Factory method to create a Student object from a Map
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      age: map['age'],
      studentClass: map['class'],
      subjects: List<String>.from(map['subjects']),
      schoolName: map['schoolName'],
      address: map['address'],
      parentNumber: map['parentNumber'],
      historyId: List<String>.from(map['historyId']),  // List of history IDs
      schoolId: map['schoolId'],
    );
  }
}
