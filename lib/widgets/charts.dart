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

enum SpendingRange { last7Days, last30Days, thisMonth }

extension SpendingRangeLabel on SpendingRange {
  String get label => switch (this) {
    SpendingRange.last7Days => '7 ngày qua',
    SpendingRange.last30Days => '30 ngày qua',
    SpendingRange.thisMonth => 'Tháng này',
  };
}

class _ChartBucket {
  const _ChartBucket({
    required this.label,
    required this.tooltipLabel,
    required this.amount,
    required this.isToday,
  });
  final String label;
  final String tooltipLabel;
  final double amount;
  final bool isToday;
}

List<_ChartBucket> _buildChartBuckets(
  List<Receipt> receipts,
  SpendingRange range,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final starts = <DateTime>[];
  final ends = <DateTime>[];
  final labels = <String>[];
  final tooltipLabels = <String>[];

  if (range == SpendingRange.last7Days) {
    final start = today.subtract(const Duration(days: 6));
    for (var i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      starts.add(day);
      ends.add(day);
      labels.add(_weekdayLabel(day.weekday));
      tooltipLabels.add('${_weekdayLabel(day.weekday)}, ${_shortDate(day)}');
    }
  } else if (range == SpendingRange.last30Days) {
    final start = today.subtract(const Duration(days: 29));
    for (var i = 0; i < 5; i++) {
      final bucketStart = start.add(Duration(days: i * 6));
      final bucketEnd = DateTime(
        bucketStart.year,
        bucketStart.month,
        bucketStart.day + 5,
      );
      starts.add(bucketStart);
      ends.add(bucketEnd.isAfter(today) ? today : bucketEnd);
      labels.add('${bucketStart.day}-${ends.last.day}');
      tooltipLabels.add(
        '${_shortDate(bucketStart)} – ${_shortDate(ends.last)}',
      );
    }
  } else {
    final start = DateTime(today.year, today.month);
    for (var day = 1; day <= today.day; day += 7) {
      final bucketStart = DateTime(today.year, today.month, day);
      final bucketEnd = DateTime(
        today.year,
        today.month,
        math.min(day + 6, today.day),
      );
      starts.add(bucketStart);
      ends.add(bucketEnd);
      labels.add('${bucketStart.day}-${bucketEnd.day}');
      tooltipLabels.add(
        '${_shortDate(bucketStart)} – ${_shortDate(bucketEnd)}',
      );
    }
    if (starts.isEmpty) {
      starts.add(start);
      ends.add(today);
      labels.add('1-${today.day}');
      tooltipLabels.add('${_shortDate(start)} – ${_shortDate(today)}');
    }
  }

  return List.generate(starts.length, (index) {
    final amount = receipts
        .where((receipt) {
          final day = DateTime(
            receipt.date.year,
            receipt.date.month,
            receipt.date.day,
          );
          return !day.isBefore(starts[index]) && !day.isAfter(ends[index]);
        })
        .fold<double>(0, (sum, receipt) => sum + receipt.amount);
    return _ChartBucket(
      label: labels[index],
      tooltipLabel: tooltipLabels[index],
      amount: amount,
      isToday: !today.isBefore(starts[index]) && !today.isAfter(ends[index]),
    );
  });
}

String _weekdayLabel(int weekday) =>
    const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][weekday - 1];

String _shortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({
    super.key,
    required this.receipts,
    this.height = 230,
    this.range = SpendingRange.last7Days,
    this.onEmptyAction,
  });
  final List<Receipt> receipts;
  final double height;
  final SpendingRange range;
  final VoidCallback? onEmptyAction;

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  int? _selectedIndex;

  void _selectAt(Offset position, double width, int count) {
    if (width <= 0 || count == 0) return;
    final index = (position.dx / width * count)
        .floor()
        .clamp(0, count - 1)
        .toInt();
    if (_selectedIndex != index) setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final buckets = _buildChartBuckets(
      widget.receipts,
      widget.range,
      DateTime.now(),
    );
    final hasExpenses = buckets.any((bucket) => bucket.amount > 0);
    if (!hasExpenses) {
      return _WeeklyChartEmpty(
        range: widget.range,
        onAction: widget.onEmptyAction,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final selected =
            _selectedIndex != null && _selectedIndex! < buckets.length
            ? _selectedIndex
            : null;
        final tooltipWidth = math.min(156.0, math.max(120.0, width - 16));
        final tooltipLeft = selected == null
            ? 0.0
            : (width * ((selected + .5) / buckets.length) - tooltipWidth / 2)
                  .clamp(8.0, math.max(8.0, width - tooltipWidth - 8))
                  .toDouble();

        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: Stack(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, progress, secondaryProgress) => MouseRegion(
                  cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
                  onHover: (event) =>
                      _selectAt(event.localPosition, width, buckets.length),
                  onExit: (_) {
                    if (kIsWeb && mounted) {
                      setState(() => _selectedIndex = null);
                    }
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        _selectAt(details.localPosition, width, buckets.length),
                    child: CustomPaint(
                      size: Size(width, widget.height),
                      painter: _WeeklyBarPainter(
                        buckets: buckets,
                        progress: progress,
                        selectedIndex: selected,
                      ),
                    ),
                  ),
                ),
              ),
              if (selected != null)
                Positioned(
                  left: tooltipLeft,
                  top: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween(begin: .96, end: 1.0).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Container(
                      key: ValueKey(selected),
                      width: tooltipWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buckets[selected].tooltipLabel,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            buckets[selected].amount == 0
                                ? 'Chưa có khoản chi'
                                : formatVnd(buckets[selected].amount),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyChartEmpty extends StatelessWidget {
  const _WeeklyChartEmpty({
    this.range = SpendingRange.last7Days,
    this.onAction,
  });
  final SpendingRange range;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 230,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_graph_rounded,
              size: 34,
              color: AppColors.blue,
            ),
            const SizedBox(height: 12),
            const Text(
              'Chưa có nhịp chi tiêu',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm một khoản chi trong ${range.label.toLowerCase()} để biểu đồ xuất hiện.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF77808C),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nhập khoản chi'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _WeeklyBarPainter extends CustomPainter {
  _WeeklyBarPainter({
    required this.buckets,
    required this.progress,
    this.selectedIndex,
  });
  final List<_ChartBucket> buckets;
  final double progress;
  final int? selectedIndex;
  @override
  void paint(Canvas canvas, Size size) {
    final text = TextPainter(textDirection: ui.TextDirection.ltr);
    final values = buckets.map((bucket) => bucket.amount).toList();
    final rawMax = values.reduce((a, b) => a > b ? a : b);
    final maxValue = math.max(1.0, rawMax);
    final bottom = size.height - 26;
    final top = 12.0;
    final chartHeight = bottom - top;
    final grid = Paint()
      ..color = const Color(0xFFDADDE3)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final baseline = Paint()
      ..color = const Color(0xFFB8BEC8)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, bottom), Offset(size.width, bottom), baseline);
    final count = buckets.length;
    final barWidth = math.min(38.0, size.width / (count * 1.65));
    final gap = math.max(8.0, (size.width - barWidth * count) / (count + 1));
    for (var i = 0; i < count; i++) {
      final x = gap + i * (barWidth + gap);
      final barHeight = chartHeight * (values[i] / maxValue) * progress;
      if (selectedIndex == i) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 5, top - 4, barWidth + 10, chartHeight + 8),
            const Radius.circular(14),
          ),
          Paint()..color = AppColors.blue.withValues(alpha: .08),
        );
      }
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
          ..color = selectedIndex == i
              ? AppColors.blueDark
              : buckets[i].isToday
              ? AppColors.orange
              : AppColors.blue,
      );
      text.text = TextSpan(
        text: buckets[i].label,
        style: const TextStyle(
          fontFamily: 'LedgerlySans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5E6875),
        ),
      );
      text.layout();
      text.paint(canvas, Offset(x + (barWidth - text.width) / 2, bottom + 9));
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarPainter old) =>
      old.progress != progress ||
      old.selectedIndex != selectedIndex ||
      old.buckets != buckets;
}
