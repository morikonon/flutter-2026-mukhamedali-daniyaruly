import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

Widget app() =>
    ChangeNotifierProvider(create: (_) => Cart(), child: const Shell());

Finder addButton(Book b) => find.descendant(
  of: find.widgetWithText(ListTile, b.title),
  matching: find.widgetWithText(OutlinedButton, 'Add'),
);

Finder badge(String label) =>
    find.descendant(of: find.byType(Badge), matching: find.text(label));

Future<List<String>> printsDuring(Future<void> Function() action) async {
  final lines = <String>[];
  final original = debugPrint;
  debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
  try {
    await action();
  } finally {
    debugPrint = original;
  }
  return lines;
}

Finder total(String value) => find.descendant(
  of: find.widgetWithText(ListTile, 'Total'),
  matching: find.text(value),
);

void main() {
  testWidgets('both screens see the same cart', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(addButton(books[0]));
    await tester.tap(addButton(books[1]));
    await tester.pump();
    expect(find.text('Added'), findsNWidgets(2));
    expect(badge('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    expect(total('7300 ₸'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove').first);
    await tester.pump();
    expect(total('3100 ₸'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsOneWidget);
    expect(addButton(books[0]), findsOneWidget);
    expect(badge('1'), findsOneWidget);
  });

  testWidgets('+ changes the total but does not rebuild the badge', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.tap(addButton(books[0]));
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    final lines = await printsDuring(() async {
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byTooltip('One more'));
        await tester.pump();
      }
    });
    expect(find.text('×4'), findsOneWidget);
    expect(total('16800 ₸'), findsOneWidget);
    expect(lines, isNot(contains('badge build')));
  });

  testWidgets('Add shows a SnackBar', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(addButton(books[2]));
    await tester.pump();
    expect(
      find.widgetWithText(SnackBar, 'Added: ${books[2].title}'),
      findsOneWidget,
    );
  });

  testWidgets('Clear asks first and clears only on yes', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(addButton(books[0]));
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(total('4200 ₸'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(total('0 ₸'), findsOneWidget);
  });

  testWidgets('search filters the list by title or author', (tester) async {
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(SearchBar), 'navigator');
    await tester.pump();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text(books[3].title), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'omarova');
    await tester.pump();
    expect(find.text(books[4].title), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'zzz');
    await tester.pump();
    expect(find.text('No books found'), findsOneWidget);
  });
}
