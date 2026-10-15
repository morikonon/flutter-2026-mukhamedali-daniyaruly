import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final List<Book> books = rawBooks.map((json) => Book.fromJson(json)).toList();

  final library = Library();
  library.open(); // Инициализация late final переменной
  for (final book in books) {
    library.add(book);
  }

  print('--- Display List ---');
  for (final line in library.displayList) {
    print(line);
  }

  print('\n--- Queries ---');
  print('Country of Clean Code: ${library.countryOf('Clean Code')}');
  print('Average pages: ${library.averagePageCount.toStringAsFixed(2)}');
  print('Books per author: ${library.authorBookCount}');
  print('Distinct genres: ${library.distinctGenres.map((g) => g.label).toList()}');
  
  print('\n--- Report ---');
  print(library.report); 

  print('\n--- Dart 3 Features ---');
  
  final stats = statsOf(books);
  print('Stats Record: ${stats.count} books, ${stats.avgPages.toStringAsFixed(1)} avg pages');

  final states = [
    Empty(),
    Ready(books),
    Broken('Termites ate the wood'),
  ];

  for (final state in states) {
    print(describe(state));
  }
}