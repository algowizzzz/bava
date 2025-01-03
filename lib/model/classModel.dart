class ClassModel {
  String id; // Unique ID for Firebase documents
  String classLabel;
  String className; // Change className to a List<String>
  String subject;

  ClassModel({
    required this.id,
    required this.classLabel,
    required this.className, // Update the constructor parameter
    required this.subject,
  });

  // Factory method to create a ClassModel from Firebase document
  factory ClassModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Change className to classNames when creating the ClassModel
    return ClassModel(
      id: documentId,
      classLabel: map['classLabel'],
      className:  map['className'], // Convert to List<String>
      subject: map['subject'],
    );
  }

  // Convert ClassModel to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classLabel': classLabel,
      'className': className, // Store classNames as a list
      'subject': subject,
    };
  }
}
