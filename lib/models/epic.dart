class Epic {
  final int id;
  final int parentId;
  final int firebaseId;
  final String name;
  final String title;
  final String question;
  final String answer;
  final String mp3URL;
  final String pdfURL;
  final String createdTime;
  final String type;
  final String category;

  Epic({ this.id, this.parentId, this.firebaseId, this.name, this.title, this.question, this.answer, this.mp3URL, this.pdfURL, this.createdTime, this.type, this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'firebaseId': firebaseId, //Used to find the latest record on FB
      'name': name,
      'title': title,
      'question': question,
      'answer': answer,
      'mp3URL': mp3URL,
      'pdfURL': pdfURL,
      'createdTime': createdTime,
      'type': type, //PARENT, RECORD
      'category': category, // QandA, Speech, Lecture
    };
  }

  @override
  String toString() {
    return 'Epic{id: $id, '
        'parentId: $parentId, '
        'firebaseId: $firebaseId, '
        'name: $name, '
        'title: $title, '
        'question: $question, '
        'answer: $answer, '
        'mp3URL: $mp3URL, '
        'pdfURL: $pdfURL, '
        'createdTime: $createdTime, '
        'type: $type, '
        'category: $category}';
  }
}