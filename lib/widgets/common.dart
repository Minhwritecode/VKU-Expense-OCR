part of '../main.dart';

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 15),
      child: child,
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _Logo extends StatelessWidget {
  const _Logo({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: compact ? 37 : 42,
        height: compact ? 37 : 42,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
      ),
      if (!compact) ...[
        const SizedBox(width: 9),
        Text(
          'ledgerly',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -.25,
            height: 1.15,
          ),
        ),
      ],
    ],
  );
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: LedgerlyLoading(size: 54, label: 'Đang tải sổ chi tiêu'),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    this.icon = Icons.receipt_long_outlined,
    this.title = 'Chưa có khoản chi nào',
    this.message = 'Chụp hóa đơn đầu tiên để bắt đầu.',
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(26),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 38,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(message, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
}

String formatVnd(double value) =>
    '${NumberFormat('#,##0', 'vi_VN').format(value).replaceAll(',', '.')} đ';
double? parseVndInput(String raw) {
  final compact = raw.trim().replaceAll(RegExp(r'\s+'), '');
  if (compact.isEmpty || !RegExp(r'^\d[\d.,]*$').hasMatch(compact)) return null;
  final digits = compact.replaceAll(RegExp(r'[.,]'), '');
  final value = double.tryParse(digits);
  return value == null || value.isNaN || value.isInfinite ? null : value;
}

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
IconData categoryIcon(String category) => switch (category) {
  'Ăn uống' => Icons.restaurant_rounded,
  'Di chuyển' => Icons.directions_car_rounded,
  'Mua sắm' => Icons.shopping_bag_rounded,
  'Học tập' => Icons.menu_book_rounded,
  _ => Icons.more_horiz_rounded,
};
Color categoryColor(String category) => switch (category) {
  'Ăn uống' => AppColors.orange,
  'Di chuyển' => AppColors.blue,
  'Mua sắm' => AppColors.lavender,
  'Học tập' => AppColors.mint,
  _ => AppColors.red,
};
