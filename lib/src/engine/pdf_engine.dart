import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef PdfSuccessCallback = void Function(File file);
typedef PdfErrorCallback = void Function(Object error);
typedef PdfProgressCallback = void Function(int page, int total);

class PdfEngine {
  late final WebViewController controller;

  PdfSuccessCallback? _onSuccess;
  PdfErrorCallback? _onError;
  PdfProgressCallback? _onProgress;
  String _fileName = 'document';

  Timer? _timeoutTimer;
  bool _callbackFired = false;

  PdfEngine() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Ready',
        onMessageReceived: (_) {
          // Engine loaded — nothing to do, generation is demand-driven.
        },
      )
      ..addJavaScriptChannel(
        'Callback',
        onMessageReceived: (JavaScriptMessage msg) {
          _settle(() => _handleSuccess(msg.message));
        },
      )
      ..addJavaScriptChannel(
        'Error',
        onMessageReceived: (JavaScriptMessage msg) {
          _settle(() => _onError?.call(msg.message));
        },
      )
      ..addJavaScriptChannel(
        'Progress',
        onMessageReceived: (JavaScriptMessage msg) {
          final data = jsonDecode(msg.message) as Map<String, dynamic>;
          _onProgress?.call(data['current'] as int, data['total'] as int);
        },
      )
      ..loadFlutterAsset(
        'packages/multi_language_pdf/assets/pdf_engine/index.html',
      );
  }

  /// Injects the assembled HTML into the engine and starts generation.
  /// [innerHtml] is the content of #content (the data-pdf-block divs).
  Future<void> generate({
    required String innerHtml,
    required double pageWidthPx,
    required double pageHeightPx,
    required double marginTop,
    required double marginRight,
    required double marginBottom,
    required double marginLeft,
    required String fileName,
    required PdfSuccessCallback onSuccess,
    required PdfErrorCallback onError,
    PdfProgressCallback? onProgress,
  }) async {
    _callbackFired = false;
    _onSuccess = onSuccess;
    _onError = onError;
    _onProgress = onProgress;
    _fileName = fileName;

    // 30 second timeout — replaces the old blind 5-second delay
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      _settle(() => _onError?.call('PDF generation timed out after 30 seconds.'));
    });

    // Escape the HTML for safe injection into a JS template literal
    final escaped = innerHtml
        .replaceAll('\\', '\\\\')
        .replaceAll('`', '\\`')
        .replaceAll('\$', '\\\$');

    await controller.runJavaScript(
      'generatePdf(`$escaped`, $pageWidthPx, $pageHeightPx, '
      '$marginTop, $marginRight, $marginBottom, $marginLeft)',
    );
  }

  Future<void> _handleSuccess(String base64Pdf) async {
    try {
      final bytes = base64Decode(base64Pdf);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$_fileName.pdf');
      await file.writeAsBytes(bytes);
      _onSuccess?.call(file);
    } catch (e) {
      _onError?.call(e);
    }
  }

  void _settle(void Function() action) {
    if (_callbackFired) return;
    _callbackFired = true;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    action();
  }

  void dispose() {
    _timeoutTimer?.cancel();
  }
}
