import 'package:deutsch_guide/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('dashboard loads and shows planned sections', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GermanLearningApp()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Level A1'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Vocabulary'), findsOneWidget);
  });
}
