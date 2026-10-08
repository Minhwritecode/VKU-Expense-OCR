import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

part 'core/theme.dart';
part 'core/router.dart';
part 'models/receipt.dart';
part 'services/receipt_repository.dart';
part 'services/ocr_service.dart';
part 'state/receipt_controller.dart';
part 'screens/app_shell.dart';
part 'screens/dashboard.dart';
part 'screens/receipts.dart';
part 'screens/receipt_details.dart';
part 'screens/insights.dart';
part 'screens/settings.dart';
part 'widgets/receipt_editor_sheet.dart';
part 'widgets/charts.dart';
part 'widgets/common.dart';
part 'widgets/motion.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const LedgerlyLaunch(child: LedgerlyApp())));
}
