// Plain Dart: no Flutter imports in the model.
class Book {
  Book({
    required this.title,
    required this.author,
    required this.pages,
    this.year,
    this.read = false,
  });

  // Required keys are cast directly; optional ones stay nullable.
  Book.fromMap(Map<String, dynamic> m)
    : title = m['title'] as String,
      author = m['author'] as String,
      pages = m['pages'] as int,
      year = m['year'] as int?,
      read = m['read'] as bool? ?? false;

  final String title;
  final String author;
  final int pages;
  final int? year;
  bool read;

  @override
  String toString() =>
      '$title — $author, $pages pp.${year == null ? '' : ' ($year)'}';
}

final seed = <Book>[
  Book(
    title: 'Widgets All the Way Down',
    author: 'A. Nurmagambetova',
    pages: 288,
    year: 2021,
    read: true,
  ),
  Book(
    title: 'Null Safety for Humans',
    author: 'B. Seitkali',
    pages: 196,
    year: 2022,
  ),
  Book(
    title: 'Constraints Go Down, Sizes Go Up',
    author: 'C. Tashimova',
    pages: 320,
  ),
  Book(
    title: 'The Navigator Is a Stack',
    author: 'D. Alibekov',
    pages: 240,
    year: 2020,
  ),
  Book(
    title:
        'A Very Long Title About Forms, Focus, the Keyboard '
        'and Everything That Overflows',
    author: 'E. Omarova',
    pages: 176,
    year: 2023,
  ),
];

int totalPages(List<Book> books) => books.fold(0, (sum, b) => sum + b.pages);

List<Book> unread(List<Book> books) => books.where((b) => !b.read).toList();

// toSet() drops duplicates and keeps the first-seen order.
List<String> authors(List<Book> books) =>
    books.map((b) => b.author).toSet().toList();
