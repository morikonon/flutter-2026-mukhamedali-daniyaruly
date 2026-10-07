import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:never_overflows/contact_card.dart';
import 'package:never_overflows/contacts.dart';
import 'package:never_overflows/main.dart';

void main() {
  testWidgets('list shows the header and scrolls to the last contact', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('20 contacts'), findsOneWidget);
    expect(find.text(contacts.first.name), findsOneWidget);

    await tester.scrollUntilVisible(find.text(contacts.last.name), 300);
    expect(find.text(contacts.last.name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long name wraps without overflowing on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts[4])),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('badge is absent when unread is 0', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ContactCard(contact: contacts[0]),
              ContactCard(contact: contacts[3]),
            ],
          ),
        ),
      ),
    );

    expect(contacts[0].unread, 0);
    expect(find.byType(Positioned), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
