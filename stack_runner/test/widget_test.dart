import 'package:flutter_test/flutter_test.dart';

import 'package:stack_runner/app/app.dart';

void main() {
  testWidgets('menu renders start button', (tester) async {
    await tester.pumpWidget(const StackRunnerApp());

    expect(find.text('Stack Runner'), findsOneWidget);
    expect(find.text('Start Run'), findsOneWidget);
  });
}
