import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/models/book.dart';

void main() {
  test('totals match the console line', () {
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
  });

  test('fromMap without year and read', () {
    final b = Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10});
    expect(b.year, isNull);
    expect(b.read, isFalse);
    expect(b.toString(), 'X — Y, 10 pp.');
  });

  test('toString shows a known year', () {
    expect(
      seed[1].toString(),
      'Null Safety for Humans — B. Seitkali, 196 pp. (2022)',
    );
  });

  test('authors keeps first-seen order without duplicates', () {
    final books = [seed[1], seed[0], seed[1]];
    expect(authors(books), ['B. Seitkali', 'A. Nurmagambetova']);
  });
}
