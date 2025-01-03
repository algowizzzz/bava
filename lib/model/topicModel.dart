class TopicModel {
  final String id; // Unique identifier for the topic
  final String topic; // Topic name
  final String lessonPlan; // Lesson plan content
  final String ppt; // PPT content or URL
  final String handout; // Handout content or URL
  final String contextBuilder; // Context builder content
  final String applicationsInRealLife; // Real-life application examples
  final DateTime createdAt; // Timestamp for when the topic was created or updated

  TopicModel({
    required this.id,
    required this.topic,
    required this.lessonPlan,
    required this.ppt,
    required this.handout,
    required this.contextBuilder,
    required this.applicationsInRealLife,
    required this.createdAt,
  });

  // Convert TopicModel to a map for Firestore or JSON storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic': topic,
      'lessonPlan': lessonPlan,
      'ppt': ppt,
      'handout': handout,
      'contextBuilder': contextBuilder,
      'applicationsInRealLife': applicationsInRealLife,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create TopicModel from a map (useful for Firestore or JSON)
  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] ?? '',
      topic: map['topic'] ?? '',
      lessonPlan: map['lessonPlan'] ?? '',
      ppt: map['ppt'] ?? '',
      handout: map['handout'] ?? '',
      contextBuilder: map['contextBuilder'] ?? '',
      applicationsInRealLife: map['applicationsInRealLife'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
