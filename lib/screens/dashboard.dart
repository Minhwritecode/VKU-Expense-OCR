part of '../main.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  SpendingRange _range = SpendingRange.last7Days;

  Future<void> _chooseRange() async {
    final selected = await showModalBottomSheet<SpendingRange>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => _RangePicker(selected: _range),
    );
    if (selected != null && selected != _range && mounted) {
      setState(() => _range = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = LedgerlyActions.of(context);
    final state = ref.watch(receiptControllerProvider);
    final receipts = state.receipts;
    final total = receipts.fold<double>(0, (sum, item) => sum + item.amount);
    final monthTotal = receipts
        .where((item) => item.date.month == DateTime.now().month)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MotionFadeSlide(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sổ chi tiêu của bạn',
                            style: theme.textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    const _Logo(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth > 670;
                  final summary = _SummaryCard(
                    monthTotal: monthTotal,
                    total: total,
                    count: receipts.length,
                    onCountTap: () => context.go('/receipts'),
                    onTotalTap: () => context.go('/insights'),
                  );
                  final quickActions = _QuickActions(
                    onScan: actions.scan,
                    onManual: actions.manual,
                  );
                  return twoColumns
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: MotionFadeSlide(delay: 70, child: summary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MotionFadeSlide(
                                delay: 120,
                                child: quickActions,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            MotionFadeSlide(delay: 70, child: summary),
                            const SizedBox(height: 16),
                            MotionFadeSlide(delay: 120, child: quickActions),
                          ],
                        );
                },
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nhịp chi tiêu', style: theme.textTheme.headlineSmall),
                  _Pill(
                    label: _range.label,
                    icon: Icons.calendar_today_rounded,
                    onTap: _chooseRange,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // The chart already has its own value animation. Keeping the
              // card visible immediately prevents a partially faded chart
              // from looking like a blank loading column on first paint.
              _ChartCard(
                child: WeeklyBarChart(
                  receipts: receipts,
                  range: _range,
                  onEmptyAction: actions.manual,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Gần đây', style: theme.textTheme.headlineSmall),
                  TextButton(
                    onPressed: () => context.go('/receipts'),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (state.loading)
                const _LoadingList()
              else if (receipts.isEmpty)
                const _EmptyState()
              else
                ...receipts
                    .take(4)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (entry) => MotionFadeSlide(
                        delay: 240 + entry.key * 45,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ReceiptCard(
                            receipt: entry.value,
                            onTap: entry.value.id == null
                                ? null
                                : () => context.push(
                                    '/receipts/${entry.value.id}',
                                  ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'Chào buổi sáng ☀️';
  if (hour < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối 🌙';
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.monthTotal,
    required this.total,
    required this.count,
    required this.onCountTap,
    required this.onTotalTap,
  });
  final double monthTotal;
  final double total;
  final int count;
  final VoidCallback onCountTap;
  final VoidCallback onTotalTap;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(
        colors: [AppColors.blue, AppColors.blueDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.blue.withValues(alpha: .22),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TỔNG THÁNG NÀY',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          formatVnd(monthTotal),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _MiniStat(
              label: '$count khoản',
              icon: Icons.receipt_long_rounded,
              onTap: onCountTap,
              tooltip: 'Mở sổ chi tiêu',
            ),
            const SizedBox(width: 12),
            _MiniStat(
              label: 'Tổng ${formatVnd(total)}',
              icon: Icons.auto_graph_rounded,
              onTap: onTotalTap,
              tooltip: 'Mở phân tích chi tiêu',
            ),
          ],
        ),
      ],
    ),
  );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      label: '$label. $tooltip',
      child: Material(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white70, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _RangePicker extends StatelessWidget {
  const _RangePicker({required this.selected});
  final SpendingRange selected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Khoảng thời gian', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Chọn phạm vi để xem nhịp chi tiêu rõ hơn.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ...SpendingRange.values.map(
          (range) => ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: 52,
            leading: Icon(
              range == selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: range == selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              range.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onTap: () => Navigator.pop(context, range),
          ),
        ),
      ],
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onScan, required this.onManual});
  final Future<void> Function(ImageSource) onScan;
  final Future<void> Function() onManual;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ghi lại trong 10 giây',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(
            'Chụp hóa đơn, để Ledgerly làm phần còn lại.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.camera_alt_rounded,
                  label: 'Chụp ảnh',
                  color: AppColors.orange,
                  onTap: () => onScan(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.photo_library_rounded,
                  label: 'Thư viện',
                  color: AppColors.lavender,
                  onTap: () => onScan(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.edit_note_rounded,
                  label: 'Nhập tay',
                  color: AppColors.mint,
                  onTap: onManual,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: .13),
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Column(
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
