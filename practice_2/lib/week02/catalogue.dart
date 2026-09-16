import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? _cachedReport;

  String get report => _cachedReport ??= 'Library opened at $openedAt. Total items: ${items.length}';

  // --- Level 4 ---

  Iterable<String> get everyTitle => items.map((item) => item.title);

  Iterable<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010);

  // Почему fold, а не reduce: reduce выбросит ошибку на пустой коллекции 
  // и требует, чтобы тип аккумулятора совпадал с типом элемента коллекции (Book).
  // fold позволяет использовать начальное значение (0) и другой тип (int/double).
  double get averagePageCount {
    final books = items.whereType<Book>();
    return books.isEmpty
        ? 0.0
        : books.fold<int>(0, (sum, book) => sum + book.pages) / books.length;
  }

  Map<String, int> get authorBookCount =>
      items.whereType<Book>().fold<Map<String, int>>({}, (map, book) {
        map[book.author.name] = (map[book.author.name] ?? 0) + 1;
        return map;
      });

  Set<String> get distinctAuthorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get distinctGenres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
        'CATALOGUE',
        for (final book in items.whereType<Book>()) '${book.title} (${book.year})',
        ...distinctAuthorNames,
        if (items.whereType<Book>().any((book) => book.pages == 0))
          '(incomplete data)'
      ];
}