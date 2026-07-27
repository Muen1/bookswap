class Book {
  final String? id;
  final String title;
  final String author;
  final String isbn;
  final String condition;
  final String category;
  final String? description;
  final String? imageUrl;
  final String ownerId;
  final String ownerEmail;
  final DateTime createdAt;
  final String? swapFor;
  final bool isAvailable;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.condition,
    required this.category,
    this.description,
    this.imageUrl,
    required this.ownerId,
    required this.ownerEmail,
    required this.createdAt,
    this.swapFor,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'condition': condition,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'swapFor': swapFor,
      'isAvailable': isAvailable,
    };
  }

static Book fromMap(Map<String, dynamic> map, String id) {
  return Book(
    id: id,
    title: map['title'] ?? 'Untitled',
    author: map['author'] ?? 'Unknown',
    isbn: map['isbn'] ?? '',
    condition: map['condition'] ?? 'Unknown',
    category: map['category'] ?? 'Other',
    description: map['description'],
    imageUrl: map['imageUrl'],
    ownerId: map['ownerId'] ?? '',
    ownerEmail: map['ownerEmail'] ?? '',
    createdAt: map['createdAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
        : DateTime.now(),
    swapFor: map['swapFor'],
    isAvailable: map['isAvailable'] ?? true,
  );
}

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? condition,
    String? category,
    String? description,
    String? imageUrl,
    String? ownerId,
    String? ownerEmail,
    DateTime? createdAt,
    String? swapFor,
    bool? isAvailable,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      condition: condition ?? this.condition,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      swapFor: swapFor ?? this.swapFor,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}