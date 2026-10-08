part of '../main.dart';

class ParsedReceipt {
  const ParsedReceipt({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    required this.rawText,
    this.imagePath,
  });
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;
  final String rawText;
  final String? imagePath;
}

class ReceiptParser {
  static ParsedReceipt parse(String rawText, {String? imagePath}) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final merchant = _parseMerchant(lines);
    return ParsedReceipt(
      merchant: merchant,
      amount: _parseAmount(rawText),
      date: _parseDate(rawText) ?? DateTime.now(),
      category: _categoryFor(merchant, rawText),
      rawText: rawText,
      imagePath: imagePath,
    );
  }

  static double _parseAmount(String text) {
    final priority = RegExp(
      r'(?:total|thành tiền|tổng cộng|grand total)[^\d]{0,18}([\d., ]{4,})',
      caseSensitive: false,
    ).firstMatch(text);
    final match =
        priority ??
        RegExp(r'(?<!\d)(\d{1,3}(?:[., ]\d{3}){1,3})(?!\d)').firstMatch(text);
    if (match == null) return 0;
    return double.tryParse(match.group(1)!.replaceAll(RegExp(r'[., ]'), '')) ??
        0;
  }

  static DateTime? _parseDate(String text) {
    final match = RegExp(r'(?<!\d)(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})(?!\d)')
        .firstMatch(text);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(3)!.padLeft(4, '20')),
      int.parse(match.group(2)!),
      int.parse(match.group(1)!),
    );
  }

  static String _parseMerchant(List<String> lines) {
    for (final line in lines.take(5)) {
      final lower = line.toLowerCase();
      if (line.length >= 3 &&
          !RegExp(r'^\d').hasMatch(line) &&
          !lower.contains('hóa đơn') &&
          !lower.contains('invoice')) {
        return line;
      }
    }
    return 'Cửa hàng chưa nhận diện';
  }

  static String _categoryFor(String merchant, String rawText) {
    final text = '$merchant $rawText'.toLowerCase();
    if (RegExp(r'grab|be |taxi|xăng|bus|di chuyển').hasMatch(text)) {
      return 'Di chuyển';
    }
    if (RegExp(r'nhà sách|sách|vku|học|in ấn|photo').hasMatch(text)) {
      return 'Học tập';
    }
    if (RegExp(r'circle|winmart|siêu thị|shop|mua').hasMatch(text)) {
      return 'Mua sắm';
    }
    if (RegExp(r'cà phê|coffee|cafe|căn tin|nhà hàng|quán|food|ăn')
        .hasMatch(text)) {
      return 'Ăn uống';
    }
    return 'Khác';
  }
}

class OcrService {
  final _picker = ImagePicker();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Future<ParsedReceipt?> scan(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return null;
    final text = await _recognizer.processImage(
      InputImage.fromFilePath(picked.path),
    );
    var storedPath = picked.path;
    try {
      final folder = Directory(
        p.join(await getDatabasesPath(), 'receipt_photos'),
      );
      await folder.create(recursive: true);
      final target = p.join(
        folder.path,
        'receipt_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}',
      );
      storedPath = (await File(picked.path).copy(target)).path;
    } catch (_) {
      // The original picker path is still useful for the current review session.
    }
    return ReceiptParser.parse(text.text, imagePath: storedPath);
  }

  Future<void> dispose() => _recognizer.close();
}

class DeviceInfoService {
  static const _channel = MethodChannel('vn.edu.vku/device_info');

  static Future<int?> getBatteryLevel() async {
    try {
      return await _channel.invokeMethod<int>('getBatteryLevel');
    } on PlatformException catch (_) {
      return null;
    } on MissingPluginException catch (_) {
      return null;
    }
  }
}

final batteryLevelProvider = FutureProvider.autoDispose<int?>(
  (ref) => DeviceInfoService.getBatteryLevel(),
);
