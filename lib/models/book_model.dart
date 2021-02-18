class Book {
  final int id;
  final String name;
  final String description;
  final String imageURL;
  final String pdfURL;

  Book({ this.id, this.description, this.name, this.imageURL, this.pdfURL});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageURL': imageURL,
      'pdfURL': pdfURL,
    };
  }

  // Implement toString to make it easier to see information about
  // each book when using the print statement.
  @override
  String toString() {
    return 'Book{id: $id, name: $name, imageURL: $imageURL, pdfURL: $pdfURL}';
  }
}