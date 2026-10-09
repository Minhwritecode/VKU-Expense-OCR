part of '../main.dart';

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 15),
        child: child,
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, size: 16),
          ],
        ],
      ),
    );
    final pill = Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(30),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              child: content,
            ),
    );
    return Semantics(
      button: onTap != null,
      label: onTap == null ? label : '$label. Chọn khoảng thời gian',
      child: Tooltip(
        message: onTap == null ? label : 'Chọn khoảng thời gian',
        child: pill,
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: compact ? 37 : 42,
        height: compact ? 37 : 42,
        child: CustomPaint(painter: _LedgerlyMarkPainter()),
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

class _LedgerlyMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 512;
    canvas.save();
    canvas.scale(scale);

    final background = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3867F0), Color(0xFF2045B5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(24, 24, 464, 464));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 24, 464, 464),
        const Radius.circular(128),
      ),
      background,
    );

    canvas.drawCircle(
      const Offset(394, 118),
      22,
      Paint()..color = AppColors.orange,
    );
    final paper = Path()
      ..moveTo(167, 94)
      ..lineTo(318, 94)
      ..lineTo(369, 145)
      ..lineTo(369, 393)
      ..quadraticBezierTo(369, 417, 345, 417)
      ..lineTo(167, 417)
      ..quadraticBezierTo(143, 417, 143, 393)
      ..lineTo(143, 118)
      ..quadraticBezierTo(143, 94, 167, 94)
      ..close();
    canvas.drawShadow(paper, const Color(0x440B2470), 14, true);
    canvas.drawPath(paper, Paint()..color = AppColors.paper);

    final fold = Path()
      ..moveTo(318, 94)
      ..lineTo(318, 145)
      ..lineTo(369, 145)
      ..close();
    canvas.drawPath(fold, Paint()..color = const Color(0xFFE9EDF8));
    canvas.drawPath(
      fold,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0xFFD9E0F2),
    );

    final blueLine = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(193, 184), const Offset(319, 184), blueLine);
    canvas.drawLine(const Offset(193, 224), const Offset(285, 224), blueLine);

    final trend = Paint()
      ..color = AppColors.orange
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final trendPath = Path()
      ..moveTo(187, 323)
      ..lineTo(230, 285)
      ..lineTo(268, 303)
      ..lineTo(325, 235);
    canvas.drawPath(trendPath, trend);
    final dot = Paint()..color = AppColors.orange;
    canvas.drawCircle(const Offset(187, 323), 9, dot);
    canvas.drawCircle(const Offset(325, 235), 9, dot);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LedgerlyMarkPainter oldDelegate) => false;
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
