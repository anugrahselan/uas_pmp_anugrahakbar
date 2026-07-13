import 'package:flutter_test/flutter_test.dart';
import 'package:uas_pmp_anugrahakbar/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BukuApp());
    expect(find.text('Data Buku'), findsOneWidget);
  });
}
