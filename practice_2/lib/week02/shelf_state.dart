import 'models.dart';

sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;
  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
      Empty() => 'The shelf is empty.',
      Ready(books: final b) => 'The shelf is ready and holds ${b.length} books.',
      Broken(message: final m) => 'The shelf is broken! Reason: $m',
    };

({int count, double avgPages}) statsOf(List<Book> books) {
  final count = books.length;
  final avgPages = count == 0
      ? 0.0
      : books.fold<int>(0, (sum, book) => sum + book.pages) / count;
  return (count: count, avgPages: avgPages);
}