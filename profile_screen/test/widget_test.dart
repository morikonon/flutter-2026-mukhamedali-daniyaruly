import 'package:flutter_test/flutter_test.dart';
import 'package:profile_screen/data.dart';
import 'package:profile_screen/main.dart';

void main() {
  testWidgets('shows the name and all four facts', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(myName), findsOneWidget);
    for (final fact in facts) {
      expect(find.text(fact.label), findsOneWidget);
      expect(find.text(fact.value), findsOneWidget);
    }
  });
}
