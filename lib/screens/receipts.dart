part of '../main.dart';

class ReceiptsPage extends ConsumerWidget {
  const ReceiptsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(receiptControllerProvider);
    final controller = ref.read(receiptControllerProvider.notifier);
    final queryCategory = ReceiptFilterScope.maybeOf(context)?.category;
    final activeCategory = queryCategory ?? state.category;
    final visible = queryCategory == null
        ? state.visible
        : state.copyWith(category: queryCategory).visible;
    const filters = [
      'Tất cả',
      'Ăn uống',
      'Di chuyển',
      'Mua sắm',
      'Học tập',
      'Khác',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lịch sử rõ ràng,',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'đầu óc nhẹ tênh.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: controller.search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Tìm theo tên cửa hàng...',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final active = activeCategory == filters[index];
                    return ChoiceChip(
                      label: Text(filters[index]),
                      selected: active,
                      onSelected: (_) {
                        final category = filters[index];
                        controller.setCategory(category);
                        context.go(
                          category == 'Tất cả'
                              ? '/receipts'
                              : '/receipts?category=${Uri.encodeComponent(category)}',
                        );
                      },
                      showCheckmark: false,
                      side: BorderSide(
                        color: active
                            ? Colors.transparent
                            : Theme.of(context).dividerColor,
                      ),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: active
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (visible.isEmpty && !state.loading)
                const _EmptyState()
              else
                ...visible.map(
                  (receipt) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ReceiptCard(receipt: receipt, editable: true),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptCard extends ConsumerWidget {
  const ReceiptCard({
    super.key,
    required this.receipt,
    this.editable = false,
    this.onTap,
  });
  final Receipt receipt;
  final bool editable;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = categoryColor(receipt.category);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap:
            onTap ??
            (editable && receipt.id != null
                ? () => context.push('/receipts/${receipt.id}')
                : null),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(categoryIcon(receipt.category), color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.merchant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${receipt.category} · ${formatDate(receipt.date)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatVnd(receipt.amount),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (editable)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      onSelected: (value) {
                        if (value == 'edit') _edit(context, ref);
                        if (value == 'delete') _delete(context, ref);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa khoản chi'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<Receipt>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => ReceiptEditorSheet(receipt: receipt),
    );
    if (result != null) {
      await ref.read(receiptControllerProvider.notifier).save(result);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật khoản chi')));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa khoản chi?'),
        content: Text('Xóa “${receipt.merchant}” khỏi sổ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (yes == true) {
      await ref.read(receiptControllerProvider.notifier).remove(receipt);
    }
  }
}
