import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('renders Turkish app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IslamicApp()));

    expect(find.text('Giriş'), findsWidgets);
    expect(find.text('Bugün'), findsWidgets);
    expect(find.text('Kur\'an'), findsWidgets);
    expect(find.text('Keşfet'), findsWidgets);
    expect(find.text('Ayarlar'), findsWidgets);
  });
}
