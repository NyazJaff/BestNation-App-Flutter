class Epic {
  final int id;
  final String parentId;
  final String firebaseId;
  final String name;
  final String body;
  final String title;
  final String question;
  final String answer;
  final String mp3URL;
  final String pdfURL;
  final String createdTime;
  final String type;
  final String category;
  bool filePathExists;

  Epic({ this.id =1 ,
    this.parentId = "",
    this.firebaseId ="",
    this.name = "",
    this.body = '',
    this.title = "",
    this.question ="",
    this.answer ="",
    this.mp3URL = "",
    this.pdfURL = "",
    this.createdTime = "",
    this.type = "",
    this.category = "",
    this.filePathExists = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'firebaseId': firebaseId, //Used to find the latest record on FB
      'name': name,
      'title': title,
      'body': body,
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
        'body: $body, '
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