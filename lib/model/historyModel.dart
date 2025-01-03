class HistoryModel {
  String history_id; // Unique identifier for the entry
  DateTime date; // Date of the entry
  String topic; // Topic of the lesson
  String className; // Name of the class
  String subject; // Subject of the class
  String userUid; // Subject of the class

  HistoryModel({
    required this.history_id,
    required this.date,
    required this.topic,
    required this.className,
    required this.subject, // Include subject in constructor
    required this.userUid, // Include subject in constructor
  });

  // Factory method to create a HistoryModel from a map
  factory HistoryModel.fromMap(String history_id, Map<String, dynamic> map) {
    return HistoryModel(
      history_id: history_id, // Set the id when creating the model
      date: DateTime.parse(map['date']), // Convert string to DateTime
      topic: map['topic'],
      className: map['className'], // Added class name
      subject: map['subject'], // Added subject
      userUid: map['userUid'], // Added subject
    );
  }

  // Convert HistoryModel to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'history_id':history_id,
      'date': date.toIso8601String(), // Convert DateTime to string
      'topic': topic,
      'className': className, // Include class name
      'subject': subject, // Include subject
      'userUid': userUid, // Include subject
    };
  }
}
