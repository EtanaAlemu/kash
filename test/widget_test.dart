import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kash/app.dart';

void main() {
  testWidgets('Kash app builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KashApp()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Kash'), findsWidgets);
  });
}
