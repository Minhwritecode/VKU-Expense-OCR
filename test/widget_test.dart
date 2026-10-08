import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vku_expense_ocr/main.dart';

void main() {
  test('Vietnamese currency formatting stays readable', () {
    expect(formatVnd(1234567), '1.234.567 đ');
    expect(parseVndInput('42.000'), 42000);
    expect(parseVndInput(' 1,250,000 '), 1250000);
    expect(parseVndInput('abc'), isNull);
    expect(parseVndInput('0'), 0);
  });

  test('receipt parser extracts total, date and category heuristics', () {
    final parsed = ReceiptParser.parse('''
      CAFE NHA GO
      Ngày: 03/10/2026
      Tổng cộng: 42.000
    ''');
    expect(parsed.amount, 42000);
    expect(parsed.date, DateTime(2026, 10, 3));
    expect(parsed.category, 'Ăn uống');
  });

  testWidgets('Ledgerly dashboard renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LedgerlyApp()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Sổ chi tiêu của bạn'), findsOneWidget);
    expect(find.text('Ghi lại trong 10 giây'), findsOneWidget);
  });

  test('GoRouter declares the primary destinations', () {
    Iterable<String> collectPaths(
      Iterable<RouteBase> routes, [
      String parent = '',
    ]) sync* {
      for (final route in routes) {
        if (route is GoRoute) {
          final path = route.path.startsWith('/')
              ? route.path
              : '${parent == '/' ? '' : parent}/${route.path}';
          yield path;
          yield* collectPaths(route.routes, path);
        } else {
          yield* collectPaths(route.routes, parent);
        }
      }
    }

    final paths = collectPaths(ledgerlyRouter.configuration.routes).toSet();
    expect(
      paths,
      containsAll([
        '/',
        '/receipts',
        '/receipts/:receiptId',
        '/insights',
        '/settings',
      ]),
    );
  });
}
