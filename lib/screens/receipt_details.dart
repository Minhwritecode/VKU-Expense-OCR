part of '../main.dart';

class ReceiptDetailPage extends ConsumerWidget {
  const ReceiptDetailPage({super.key, required this.receiptId});
  final int? receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref
        .watch(receiptControllerProvider)
        .receipts
        .where((item) => item.id == receiptId)
        .firstOrNull;
    if (receipt == null) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Không tìm thấy hóa đơn',
        message: 'Khoản chi có thể đã bị xóa hoặc chưa tải xong.',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chi tiết hóa đơn',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              ReceiptCard(receipt: receipt),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ghi chú',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        receipt.note.isEmpty
                            ? 'Chưa có ghi chú.'
                            : receipt.note,
                      ),
                      if (receipt.rawText.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          'OCR raw text',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(receipt.rawText),
                      ],
                    ],
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
