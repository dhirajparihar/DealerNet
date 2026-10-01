import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealer_app/app/app.dart';

void main() {
  testWidgets('App renders splash smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DealerApp(),
      ),
    );

    // Initial splash frame
    expect(find.text('DealerNet'), findsOneWidget);

    // Allow splash timer to complete and route
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify navigation landed on Home / DealerNet
    expect(find.text('DealerNet'), findsWidgets);
  });
}
