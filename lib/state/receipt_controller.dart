part of '../main.dart';

class ReceiptState {
  const ReceiptState({
    this.receipts = const [],
    this.loading = true,
    this.query = '',
    this.category = 'Tất cả',
  });
  final List<Receipt> receipts;
  final bool loading;
  final String query;
  final String category;
  ReceiptState copyWith({
    List<Receipt>? receipts,
    bool? loading,
    String? query,
    String? category,
  }) => ReceiptState(
    receipts: receipts ?? this.receipts,
    loading: loading ?? this.loading,
    query: query ?? this.query,
    category: category ?? this.category,
  );
  List<Receipt> get visible => receipts
      .where(
        (receipt) =>
            receipt.merchant.toLowerCase().contains(query.toLowerCase()) &&
            (category == 'Tất cả' || receipt.category == category),
      )
      .toList();
}

final receiptControllerProvider =
    StateNotifierProvider<ReceiptController, ReceiptState>(
      (ref) => ReceiptController(ref.read(repositoryProvider))..load(),
    );

class ReceiptController extends StateNotifier<ReceiptState> {
  ReceiptController(this._repository) : super(const ReceiptState());
  final ReceiptRepository _repository;
  Future<void> load() async {
    state = state.copyWith(receipts: await _repository.all(), loading: false);
  }

  void search(String value) => state = state.copyWith(query: value);
  void setCategory(String value) => state = state.copyWith(category: value);
  Future<void> save(Receipt receipt) async {
    if (receipt.id == null) {
      final saved = await _repository.add(receipt);
      state = state.copyWith(receipts: [saved, ...state.receipts]);
    } else {
      await _repository.update(receipt);
      state = state.copyWith(
        receipts: state.receipts
            .map((item) => item.id == receipt.id ? receipt : item)
            .toList(),
      );
    }
  }

  Future<void> remove(Receipt receipt) async {
    if (receipt.id != null) await _repository.delete(receipt.id!);
    state = state.copyWith(
      receipts: state.receipts.where((item) => item.id != receipt.id).toList(),
    );
  }
}
