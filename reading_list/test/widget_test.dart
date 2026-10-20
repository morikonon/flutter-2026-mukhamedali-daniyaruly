import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';

Future<void> setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpAndSettle();
}

Finder stat(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(Column));

String statValue(WidgetTester tester, String label) =>
    tester
        .widgetList<Text>(
          find.descendant(of: stat(label).first, matching: find.byType(Text)),
        )
        .first
        .data ??
    '';

Finder field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  // [...seed] copies the list, not the books: reset the shared read flags.
  final initialRead = [for (final b in seed) b.read];
  setUp(() {
    for (var i = 0; i < seed.length; i++) {
      seed[i].read = initialRead[i];
    }
  });

  testWidgets('header, filter and AppBar count', (tester) async {
    await setSize(tester, const Size(400, 800));
    await tester.pumpWidget(const MyApp());
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(statValue(tester, 'Pages'), '1220');

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (4)'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Read'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (1)'), findsOneWidget);
    // The header follows _books, not the filter.
    expect(statValue(tester, 'Books'), '5');
  });

  testWidgets('ticking a checkbox updates the header', (tester) async {
    await setSize(tester, const Size(400, 800));
    await tester.pumpWidget(const MyApp());
    expect(statValue(tester, 'Unread'), '4');
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    expect(statValue(tester, 'Unread'), '3');
  });

  testWidgets('long title is ellipsized, no overflow in both orientations', (
    tester,
  ) async {
    for (final size in [const Size(360, 740), const Size(740, 360)]) {
      await setSize(tester, size);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$size');
    }
    await setSize(tester, const Size(360, 740));
    final title = tester.widget<Text>(
      find.textContaining('A Very Long Title').first,
    );
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    final xs = tester
        .widgetList(find.byType(Checkbox))
        .map((w) => tester.getTopLeft(find.byWidget(w)).dx)
        .toSet();
    expect(xs.length, 1);
  });

  testWidgets('detail toggles, back changes nothing, delete asks', (
    tester,
  ) async {
    await setSize(tester, const Size(400, 800));
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Constraints Go Down, Sizes Go Up'));
    await tester.pumpAndSettle();
    expect(find.text('Year unknown'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(statValue(tester, 'Unread'), '4');

    await tester.tap(find.text('Constraints Go Down, Sizes Go Up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as read'));
    await tester.pumpAndSettle();
    expect(statValue(tester, 'Unread'), '3');

    await tester.tap(find.text('The Navigator Is a Stack'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text("Delete 'The Navigator Is a Stack'?"), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Mark as read'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (4)'), findsOneWidget);
    expect(find.text('The Navigator Is a Stack'), findsNothing);
  });

  testWidgets('add form: 3 errors, bad pages, empty year saves', (
    tester,
  ) async {
    await setSize(tester, const Size(400, 800));
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Add book'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);

    await tester.tap(find.byTooltip('Add book'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('At least 2 characters'), findsOneWidget);
    expect(find.text('Enter the author'), findsOneWidget);
    expect(find.text('A whole number above 0'), findsOneWidget);
    expect(find.textContaining('A year between'), findsNothing);

    await tester.enterText(field('Title'), 'Dart Streams');
    await tester.enterText(field('Author'), 'F. Test');
    await tester.enterText(field('Pages'), 'abc');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('A whole number above 0'), findsOneWidget);
    expect(find.text('Add book'), findsOneWidget);

    await tester.enterText(field('Pages'), '100');
    await tester.enterText(field('Year (optional)'), '1200');
    await tester.pump();
    expect(find.textContaining('A year between'), findsOneWidget);
    await tester.enterText(field('Year (optional)'), '');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Reading list (6)'), findsOneWidget);
    expect(statValue(tester, 'Books'), '6');
    expect(statValue(tester, 'Pages'), '1320');
    expect(statValue(tester, 'Unread'), '5');

    await tester.ensureVisible(find.text('Dart Streams'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dart Streams'));
    await tester.pumpAndSettle();
    expect(find.text('Year unknown'), findsOneWidget);
  });
}
