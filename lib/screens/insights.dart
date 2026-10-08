part of '../main.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(receiptControllerProvider).receipts;
    final byCategory = <String, double>{};
    for (final receipt in receipts) {
      byCategory[receipt.category] =
          (byCategory[receipt.category] ?? 0) + receipt.amount;
    }
    final total = byCategory.values.fold<double>(0, (a, b) => a + b);
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhìn rộng hơn',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'tiền đang đi đâu?',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final split = constraints.maxWidth > 650;
                  final donut = _ChartCard(
                    child: SizedBox(
                      height: 270,
                      child: DonutChart(data: byCategory, total: total),
                    ),
                  );
                  final note = Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phân bổ danh mục',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...sorted.map(
                            (entry) => _LegendRow(
                              category: entry.key,
                              value: entry.value,
                              total: total,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  return split
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: donut),
                            const SizedBox(width: 16),
                            Expanded(child: note),
                          ],
                        )
                      : Column(
                          children: [donut, const SizedBox(height: 16), note],
                        );
                },
              ),
              const SizedBox(height: 20),
              Text('Theo tuần', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _ChartCard(
                child: WeeklyBarChart(receipts: receipts, height: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.category,
    required this.value,
    required this.total,
  });
  final String category;
  final double value;
  final double total;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: categoryColor(category),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          '${total == 0 ? 0 : (value / total * 100).round()}%',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          formatVnd(value),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
