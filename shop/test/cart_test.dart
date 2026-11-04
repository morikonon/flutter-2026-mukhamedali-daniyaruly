import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  test('works without a screen', () {
    final cart = Cart()
      ..add(books[0])
      ..add(books[1]);
    expect(cart.add(books[0]), isFalse);
    cart.remove(books[0]);
    expect('${cart.count} items, ${cart.total} ₸', '1 items, 3100 ₸');
  });

  test('items cannot be changed from outside', () {
    expect(() => Cart().items.add(books[0]), throwsUnsupportedError);
  });

  test('count is distinct books, total multiplies by quantity', () {
    final cart = Cart()
      ..add(books[0])
      ..add(books[1])
      ..increment(books[0])
      ..increment(books[0]);
    expect(cart.qtyOf(books[0]), 3);
    expect(cart.count, 2);
    expect(cart.total, 3 * 4200 + 3100);
  });

  test('every change notifies, a refused add does not', () {
    var calls = 0;
    final cart = Cart()..addListener(() => calls++);
    cart.add(books[0]);
    cart.add(books[0]);
    cart.increment(books[0]);
    cart.remove(books[0]);
    cart.clear();
    expect(calls, 4);
  });
}
