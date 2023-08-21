
class CommentAndBookmark {

  final int id;
  final int bookId;
  final int pageIndex;
  final String comment;
  final String type;

  CommentAndBookmark({ this.id = 1, this.bookId = 1, this.pageIndex = 1, this.comment = "", this.type = ""});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'pageIndex': pageIndex,
      'comment': comment,
      'type': type,
    };
  }

  // Implement toString to make it easier to see information about
  // each CommentAndBookmark when using the print statement.
  @override
  String toString() {
    return 'CommentAndBookmark{id: $id, bookId: $bookId, pageIndex: $pageIndex, comment: $comment, type: $type}';
  }
}
