part of '../main.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.data, required this.total});
  final Map<String, double> data;
  final double total;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 850),
    curve: Curves.easeOutCubic,
    builder: (_, progress, secondaryProgress) => CustomPaint(
      painter: DonutPainter(data: data, total: total, progress: progress),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatVnd(total),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'tổng đã ghi',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class DonutPainter extends CustomPainter {
  DonutPainter({
    required this.data,
    required this.total,
    required this.progress,
  });
  final Map<String, double> data;
  final double total;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 24;
    final stroke = math.max(22.0, radius * .25);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE7E7E2),
    );
    if (total <= 0) return;
    var start = -math.pi / 2;
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in entries) {
      final sweep = 2 * math.pi * entry.value / total * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        math.max(0.01, sweep - .045).toDouble(),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = categoryColor(entry.key),
      );
      start += 2 * math.pi * entry.value / total;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter old) =>
      old.progress != progress || old.data != data;
}

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.receipts, this.height = 230});
  final List<Receipt> receipts;
  final double height;

  bool get hasRecentExpenses {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return receipts.any((receipt) {
      final receiptDay = DateTime(
        receipt.date.year,
        receipt.date.month,
        receipt.date.day,
      );
      final diff = start.difference(receiptDay).inDays;
      return diff >= 0 && diff < 7;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasRecentExpenses) return const _WeeklyChartEmpty();
    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (_, progress, secondaryProgress) => CustomPaint(
          painter: WeeklyBarPainter(receipts: receipts, progress: progress),
        ),
      ),
    );
  }
}

class _WeeklyChartEmpty extends StatelessWidget {
  const _WeeklyChartEmpty();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 230,
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_graph_rounded, size: 34, color: AppColors.blue),
            SizedBox(height: 12),
            Text(
              'Chưa có nhịp chi tiêu',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, height: 1.3),
            ),
            SizedBox(height: 4),
            Text(
              'Thêm một khoản chi trong 7 ngày qua để biểu đồ xuất hiện.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF77808C),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class WeeklyBarPainter extends CustomPainter {
  WeeklyBarPainter({required this.receipts, required this.progress});
  final List<Receipt> receipts;
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final text = TextPainter(textDirection: ui.TextDirection.ltr);
    final values = List<double>.filled(7, 0);
    final today = DateTime.now();
    for (final receipt in receipts) {
      final diff = DateTime(today.year, today.month, today.day)
          .difference(
            DateTime(receipt.date.year, receipt.date.month, receipt.date.day),
          )
          .inDays;
      if (diff >= 0 && diff < 7) values[6 - diff] += receipt.amount;
    }
    final rawMax = values.reduce((a, b) => a > b ? a : b);
    final maxValue = math.max(1.0, rawMax);
    final bottom = size.height - 26;
    final top = 12.0;
    final chartHeight = bottom - top;
    final grid = Paint()
      ..color = const Color(0xFFE7E7E2)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final barWidth = math.min(38.0, size.width / 10);
    final gap = (size.width - barWidth * 7) / 8;
    final labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    for (var i = 0; i < 7; i++) {
      final x = gap + i * (barWidth + gap);
      final barHeight = chartHeight * (values[i] / maxValue) * progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            bottom - barHeight,
            barWidth,
            math.max(5, barHeight),
          ),
          const Radius.circular(10),
        ),
        Paint()
          ..color = i == 6
              ? AppColors.orange
              : AppColors.blue.withValues(alpha: .72),
      );
      text.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF77808C),
        ),
      );
      text.layout();
      text.paint(canvas, Offset(x + (barWidth - text.width) / 2, bottom + 9));
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyBarPainter old) =>
      old.progress != progress || old.receipts != receipts;
}
