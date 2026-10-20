import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_form/main.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> setWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpAndSettle();
}

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Name'), 'Aida');
  await tester.enterText(field('Email'), 'aida@kbtu.kz');
  await tester.enterText(field('Password'), 'secret123');
  await tester.enterText(field('Confirm password'), 'secret123');
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('IT-2302').last);
  await tester.pumpAndSettle();
  await tester.tap(field('Date of birth'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('I agree to the rules'));
  await tester.pumpAndSettle();
}

final signUp = find.widgetWithText(FilledButton, 'Sign up');

FilledButton signUpButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Sign up'));

void main() {
  testWidgets('empty form shows no errors, button grey until ticked', (
    tester,
  ) async {
    await setWidth(tester, 400);
    await tester.pumpWidget(const MyApp());
    expect(find.text('Name is too short'), findsNothing);
    expect(signUpButton(tester).onPressed, isNull);

    await tester.tap(find.text('I agree to the rules'));
    await tester.pump();
    expect(signUpButton(tester).onPressed, isNotNull);
  });

  testWidgets('Sign up on an empty form shows every error at once', (
    tester,
  ) async {
    await setWidth(tester, 400);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('I agree to the rules'));
    await tester.pump();
    await tester.ensureVisible(signUp);
    await tester.tap(signUp);
    await tester.pump();
    for (final error in [
      'Name is too short',
      'Email looks wrong',
      'Password is too short',
      'Choose a group',
      'Choose a date of birth',
    ]) {
      expect(find.text(error), findsOneWidget, reason: error);
    }
    expect(find.text('Account created'), findsNothing);

    // Fixing one field clears only its own message.
    await tester.enterText(field('Name'), 'Aida');
    await tester.pump();
    expect(find.text('Name is too short'), findsNothing);
    expect(find.text('Email looks wrong'), findsOneWidget);
  });

  testWidgets('different passwords turn Confirm red immediately', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.enterText(field('Password'), 'secret123');
    await tester.pump();
    expect(find.text('9 of 8'), findsOneWidget);
    await tester.enterText(field('Confirm password'), 'secret12');
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('keyboard actions walk the fields and submit', (tester) async {
    await setWidth(tester, 400);
    await tester.pumpWidget(const MyApp());
    await fillValidForm(tester);

    await tester.showKeyboard(field('Name'));
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    final focused = FocusManager.instance.primaryFocus?.context;
    final editable = focused?.findAncestorWidgetOfExactType<EditableText>();
    expect(editable?.controller.text, 'aida@kbtu.kz');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Account created'), findsOneWidget);
    expect(find.text('Start over'), findsOneWidget);
  });

  testWidgets('keyboard open on Confirm: no overflow', (tester) async {
    await setWidth(tester, 400);
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MyApp());
    await tester.showKeyboard(field('Confirm password'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      signUp,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(signUp.hitTestable(), findsOneWidget);
  });

  testWidgets('date picker Cancel keeps the old date', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(field('Date of birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('01.01.2005'), findsOneWidget);

    await tester.tap(field('Date of birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('01.01.2005'), findsOneWidget);
  });

  testWidgets('summary switches 1 <-> 2 columns, Start over resets', (
    tester,
  ) async {
    await setWidth(tester, 400);
    await tester.pumpWidget(const MyApp());
    await fillValidForm(tester);
    await tester.ensureVisible(signUp);
    await tester.tap(signUp);
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsNothing);
    expect(find.text('01.01.2005'), findsOneWidget);

    await setWidth(tester, 800);
    expect(find.byType(GridView), findsOneWidget);
    await setWidth(tester, 400);
    expect(find.byType(GridView), findsNothing);

    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();
    expect(find.text('Aida'), findsNothing);
    expect(find.text('0 of 8'), findsOneWidget);
    expect(find.text('Name is too short'), findsNothing);
    expect(signUpButton(tester).onPressed, isNull);
  });
}
