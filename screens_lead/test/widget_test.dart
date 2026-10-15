import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screens_lead/main.dart';

// Opens Aida's detail screen, then the edit form.
Future<void> openEdit(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.text('Aida Akhmetova'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Edit'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('root list has no back arrow', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Students'), findsOneWidget);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('tap opens detail with an automatic back arrow', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    expect(find.text('aida@kbtu.kz'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Students'), findsOneWidget);
  });

  testWidgets('Save returns the new name to detail', (tester) async {
    await openEdit(tester);
    await tester.enterText(find.byType(TextField), 'Aida A.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Aida A.'), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('clean form pops without a dialog', (tester) async {
    await openEdit(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
  });

  testWidgets('dirty form asks before leaving', (tester) async {
    await openEdit(tester);
    await tester.enterText(find.byType(TextField), 'Draft');
    // Rebuild so PopScope sees canPop: false.
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Aida Akhmetova'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });
}
