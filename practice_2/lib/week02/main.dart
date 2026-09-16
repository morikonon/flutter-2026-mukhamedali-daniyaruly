import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  // 1. Инициализация из сырых данных (fromJson справляется с неполными entry)
  final List<Book> books = rawBooks.map((json) => Book.fromJson(json)).toList();

  // 2. Работа с библиотекой
  final library = Library();
  library.open(); // Инициализация late final переменной
  for (final book in books) {
    library.add(book);
  }

  // 3. Вывод результатов Level 4 (Collections)
  print('--- Display List ---');
  for (final line in library.displayList) {
    print(line);
  }

  print('\n--- Queries ---');
  print('Country of Clean Code: ${library.countryOf('Clean Code')}');
  print('Average pages: ${library.averagePageCount.toStringAsFixed(2)}');
  print('Books per author: ${library.authorBookCount}');
  print('Distinct genres: ${library.distinctGenres.map((g) => g.label).toList()}');
  
  // Вызов кэшированного отчета
  print('\n--- Report ---');
  print(library.report); 

  // 4. Вывод Dart 3 Features (Level 5)
  print('\n--- Dart 3 Features ---');
  
  // Использование Record (Записей)
  final stats = statsOf(books);
  print('Stats Record: ${stats.count} books, ${stats.avgPages.toStringAsFixed(1)} avg pages');

  // Тест Sealed классов и switch без default
  final states = [
    Empty(),
    Ready(books),
    Broken('Termites ate the wood'),
  ];

  for (final state in states) {
    print(describe(state));
  }
}