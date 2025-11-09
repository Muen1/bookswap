class Book {
  final String? id;
  final String title;
  final String author;
  final String condition;
  final String? imageUrl;
  final String ownerId;
  final String ownerEmail;
  final DateTime createdAt;
  final String? swapFor;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    required this.ownerId,
    required this.ownerEmail,
    required this.createdAt,
    this.swapFor,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'swapFor': swapFor,
    };
  }

  static Book fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'],
      author: map['author'],
      condition: map['condition'],
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'],
      ownerEmail: map['ownerEmail'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      swapFor: map['swapFor'],
    );
  }
}