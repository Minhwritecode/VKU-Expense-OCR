part of '../main.dart';

class LedgerlyApp extends ConsumerWidget {
  const LedgerlyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Ledgerly',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: mode,
      routerConfig: ledgerlyRouter,
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class LedgerlyActions extends InheritedWidget {
  const LedgerlyActions({
    super.key,
    required this.scan,
    required this.manual,
    required super.child,
  });

  final Future<void> Function(ImageSource source) scan;
  final Future<void> Function() manual;

  static LedgerlyActions of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LedgerlyActions>()!;

  @override
  bool updateShouldNotify(LedgerlyActions oldWidget) =>
      scan != oldWidget.scan || manual != oldWidget.manual;
}

class _AppShellState extends ConsumerState<AppShell> {
  final _ocr = OcrService();
  final _titles = const ['Tổng quan', 'Sổ chi tiêu', 'Phân tích', 'Cài đặt'];
  bool _scanning = false;

  int get _index {
    final path = GoRouterState.of(context).uri.path;
    if (path == '/receipts' || path.startsWith('/receipts/')) return 1;
    if (path == '/insights') return 2;
    if (path == '/settings') return 3;
    return 0;
  }

  void _navigate(int index) {
    if (index == _index) return;
    context.go(_routePaths[index]);
  }

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  Future<void> _scan(ImageSource source) async {
    if (_scanning) return;
    setState(() => _scanning = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final parsed = await _ocr.scan(source);
      if (!mounted || parsed == null) return;
      final receipt = await showModalBottomSheet<Receipt>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        builder: (_) => ReceiptEditorSheet(parsed: parsed),
      );
      if (receipt != null) {
        await ref.read(receiptControllerProvider.notifier).save(receipt);
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Đã lưu hóa đơn vào sổ')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Không thể đọc ảnh: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _manual() async {
    final receipt = await showModalBottomSheet<Receipt>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => const ReceiptEditorSheet(),
    );
    if (receipt != null) {
      await ref.read(receiptControllerProvider.notifier).save(receipt);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đã thêm khoản chi')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _index;
    return LedgerlyActions(
      scan: _scan,
      manual: _manual,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 780;
          final content = Scaffold(
            appBar: wide
                ? null
                : AppBar(
                    title: Text(
                      _titles[index],
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    actions: [
                      IconButton(
                        onPressed: _manual,
                        icon: const Icon(Icons.edit_note_rounded),
                        tooltip: 'Nhập tay',
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
            body: widget.child,
            floatingActionButton: index == 0
                ? FloatingActionButton.extended(
                    onPressed: _scanning
                        ? null
                        : () => _scan(ImageSource.camera),
                    icon: AnimatedSwitcher(
                      duration: MotionTokens.fast,
                      child: _scanning
                          ? const SizedBox(
                              key: ValueKey('fab-loading'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.document_scanner_rounded,
                              key: ValueKey('fab-scan'),
                            ),
                    ),
                    label: AnimatedSwitcher(
                      duration: MotionTokens.fast,
                      child: Text(
                        _scanning ? 'Đang đọc…' : 'Quét hóa đơn',
                        key: ValueKey(_scanning),
                      ),
                    ),
                  )
                : null,
            bottomNavigationBar: wide
                ? null
                : NavigationBar(
                    selectedIndex: index,
                    onDestinationSelected: _navigate,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.grid_view_rounded),
                        label: 'Tổng quan',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.receipt_long_outlined),
                        selectedIcon: Icon(Icons.receipt_long_rounded),
                        label: 'Sổ chi tiêu',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.insights_outlined),
                        selectedIcon: Icon(Icons.insights_rounded),
                        label: 'Phân tích',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.tune_outlined),
                        selectedIcon: Icon(Icons.tune_rounded),
                        label: 'Cài đặt',
                      ),
                    ],
                  ),
          );
          if (!wide) return content;
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: _navigate,
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 28, 10, 40),
                    child: const _Logo(compact: true),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      label: Text('Tổng quan'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_rounded),
                      label: Text('Sổ chi tiêu'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_rounded),
                      label: Text('Phân tích'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.tune_rounded),
                      label: Text('Cài đặt'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          );
        },
      ),
    );
  }
}
