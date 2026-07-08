import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('renders Turkish app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IslamicApp()));

    expect(find.text('Ana Sayfa'), findsWidgets);
    expect(find.text('Namaz'), findsOneWidget);
    expect(find.text('Kur\'an'), findsOneWidget);
    expect(find.text('Keşfet'), findsOneWidget);
    expect(find.text('Ayarlar'), findsOneWidget);
  });
}
