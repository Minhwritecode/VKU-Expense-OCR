part of '../main.dart';

class ReceiptEditorSheet extends StatefulWidget {
  const ReceiptEditorSheet({super.key, this.parsed, this.receipt});
  final ParsedReceipt? parsed;
  final Receipt? receipt;
  @override
  State<ReceiptEditorSheet> createState() => _ReceiptEditorSheetState();
}

class _ReceiptEditorSheetState extends State<ReceiptEditorSheet> {
  late final TextEditingController _merchant;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DateTime _date;
  late String _category;
  final _formKey = GlobalKey<FormState>();
  final _merchantFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _categories = const [
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Học tập',
    'Khác',
  ];
  @override
  void initState() {
    super.initState();
    final source = widget.receipt;
    _merchant = TextEditingController(
      text: source?.merchant ?? widget.parsed?.merchant ?? '',
    );
    _amount = TextEditingController(
      text: source == null
          ? (widget.parsed?.amount ?? 0).round().toString()
          : source.amount.round().toString(),
    );
    _note = TextEditingController(text: source?.note ?? '');
    _date = source?.date ?? widget.parsed?.date ?? DateTime.now();
    _category = source?.category ?? widget.parsed?.category ?? 'Khác';
  }

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    _note.dispose();
    _merchantFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.receipt != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.parsed == null
                          ? Icons.edit_note_rounded
                          : Icons.verified_rounded,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          editing
                              ? 'Chỉnh sửa khoản chi'
                              : widget.parsed == null
                              ? 'Thêm khoản chi'
                              : 'Kiểm tra hóa đơn',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          editing
                              ? 'Cập nhật lại cho chính xác nhé'
                              : widget.parsed == null
                              ? 'Một dòng rõ ràng là đủ'
                              : 'OCR đã đọc xong - bạn kiểm tra lại',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _merchant,
                focusNode: _merchantFocus,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Cửa hàng / đơn vị',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhập tên cửa hàng'
                    : null,
                onFieldSubmitted: (_) => _amountFocus.requestFocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                focusNode: _amountFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Số tiền (VNĐ)',
                  prefixIcon: Icon(Icons.payments_outlined),
                  hintText: 'Ví dụ: 42.000',
                ),
                validator: (value) {
                  final amount = parseVndInput(value ?? '');
                  return amount == null || amount <= 0
                      ? 'Nhập số tiền lớn hơn 0'
                      : null;
                },
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                      items: _categories
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _category = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Ngày'),
                        child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (không bắt buộc)',
                  alignLabelWithHint: true,
                ),
              ),
              if (widget.parsed != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      'Xem văn bản OCR gốc',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.parsed!.rawText.isEmpty
                              ? 'Không nhận diện được chữ.'
                              : widget.parsed!.rawText,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(editing ? 'Lưu thay đổi' : 'Lưu vào sổ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _date.isAfter(DateTime.now()) ? DateTime.now() : _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseVndInput(_amount.text);
    if (amount == null) return;
    Navigator.pop(
      context,
      Receipt(
        id: widget.receipt?.id,
        merchant: _merchant.text.trim(),
        amount: amount,
        date: _date,
        category: _category,
        note: _note.text.trim(),
        imagePath: widget.receipt?.imagePath ?? widget.parsed?.imagePath,
        rawText: widget.receipt?.rawText ?? widget.parsed?.rawText ?? '',
      ),
    );
  }
}
