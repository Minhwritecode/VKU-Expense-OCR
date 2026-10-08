part of '../main.dart';

const _routePaths = ['/', '/receipts', '/insights', '/settings'];
const _receiptCategories = [
  'Tất cả',
  'Ăn uống',
  'Di chuyển',
  'Mua sắm',
  'Học tập',
  'Khác',
];

class ReceiptFilterScope extends InheritedWidget {
  const ReceiptFilterScope({
    super.key,
    required this.category,
    required super.child,
  });
  final String? category;

  static ReceiptFilterScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ReceiptFilterScope>();

  @override
  bool updateShouldNotify(ReceiptFilterScope oldWidget) =>
      category != oldWidget.category;
}

Page<void> _routePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(.025, 0),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );

final ledgerlyRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    if (state.uri.path == '/receipts') {
      final category = state.uri.queryParameters['category'];
      if (category != null && !_receiptCategories.contains(category)) {
        return '/receipts';
      }
    }
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(
        child: ReceiptFilterScope(
          category: state.uri.queryParameters['category'],
          child: child,
        ),
      ),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, state) => _routePage(state, const DashboardPage()),
        ),
        GoRoute(
          path: '/receipts',
          pageBuilder: (_, state) => _routePage(state, const ReceiptsPage()),
          routes: [
            GoRoute(
              path: ':receiptId',
              pageBuilder: (_, state) => _routePage(
                state,
                ReceiptDetailPage(
                  receiptId: int.tryParse(
                    state.pathParameters['receiptId'] ?? '',
                  ),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/insights',
          pageBuilder: (_, state) => _routePage(state, const InsightsPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (_, state) => _routePage(state, const SettingsPage()),
        ),
      ],
    ),
  ],
);
