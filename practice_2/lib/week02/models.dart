// --- Level 1 ---

class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  @override
  String toString() => 'Author(name: $name, country: $country)';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  final String label;
  const Genre(this.label);

  factory Genre.fromString(String? raw) {
    if (raw == null) return Genre.unknown;
    for (final genre in Genre.values) {
      if (genre.name == raw) return genre;
    }
    return Genre.unknown;
  }
}

// --- Level 2 ---

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();
  bool get isOld => year < 2000;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrowable: $title';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String? ?? 'Unknown Title',
      year: json['year'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      author: Author(
        name: json['author'] as String? ?? 'Unknown',
        country: json['country'] as String?,
      ),
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String describe() => 'Book: $title by ${author.name} ($year)';

  @override
  String toString() =>
      'Book(title: $title, year: $year, pages: $pages, author: $author, genre: $genre, description: $description)';
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() => 'Magazine: $title, Issue: $issue ($year)';
}

class Ghost implements LibraryItem {
  @override
  final String title;
  
  @override
  final int year;

  const Ghost({required this.title, required this.year});

  @override
  String describe() => 'Ghost item: $title';

  @override
  bool get isOld => year < 1900; 
}