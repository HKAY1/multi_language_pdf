import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../document/pdf_document.dart';
import '../engine/html_assembler.dart';
import '../engine/pdf_engine.dart';

/// Wrap your app or screen with [PdfGeneratorScope] once.
/// It mounts the hidden WebView needed for PDF generation.
///
/// ```dart
/// PdfGeneratorScope(
///   child: MyApp(),
/// )
/// ```
class PdfGeneratorScope extends StatefulWidget {
  final Widget child;
  const PdfGeneratorScope({required this.child, super.key});

  @override
  State<PdfGeneratorScope> createState() => _PdfGeneratorScopeState();
}

class _PdfGeneratorScopeState extends State<PdfGeneratorScope> {
  late final PdfEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = PdfEngine();
    PdfGenerator._engine = _engine;
  }

  @override
  void dispose() {
    _engine.dispose();
    PdfGenerator._engine = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Hidden 1x1 pixel WebView — must be in the widget tree for JS to execute.
        Positioned(
          left: -1,
          top: -1,
          width: 1,
          height: 1,
          child: WebViewWidget(controller: _engine.controller),
        ),
      ],
    );
  }
}

/// Generates PDFs from a [PdfDocument].
///
/// Requires [PdfGeneratorScope] to be present in the widget tree above
/// the call site before [generate] is called.
class PdfGenerator {
  PdfGenerator._();

  static PdfEngine? _engine;

  /// Generates a PDF from [document] and delivers the result via callbacks.
  ///
  /// [fileName] is the base name of the output file (no `.pdf` extension needed).
  /// [onSuccess] is called with the written [File] on success.
  /// [onError] is called with an error description on failure.
  /// [onProgress] is optional — called after each page is rendered.
  static void generate({
    required PdfDocument document,
    String fileName = 'document',
    required void Function(File file) onSuccess,
    required void Function(Object error) onError,
    void Function(int page, int total)? onProgress,
  }) {
    assert(
      _engine != null,
      'PdfGeneratorScope must be present in the widget tree before calling PdfGenerator.generate().',
    );

    if (document.children.isEmpty) {
      onError('Document has no content.');
      return;
    }

    final config = document.pageConfig;
    final margin = config.margin;

    HtmlAssembler.assemble(document).then((fullHtml) {
      // Extract only the inner blocks HTML for the engine.
      // The engine's index.html provides the outer shell;
      // we inject the data-pdf-block divs via generatePdf().
      final innerHtml = _extractInnerHtml(fullHtml);

      _engine!.generate(
        innerHtml: innerHtml,
        pageWidthPx: config.widthPx,
        pageHeightPx: config.heightPx,
        marginTop: margin.top,
        marginRight: margin.right,
        marginBottom: margin.bottom,
        marginLeft: margin.left,
        fileName: fileName,
        onSuccess: onSuccess,
        onError: onError,
        onProgress: onProgress,
      );
    }).catchError((Object e) {
      onError(e);
    });
  }

  /// Extracts the content inside <div id="content">...</div>
  static String _extractInnerHtml(String fullHtml) {
    final start = fullHtml.indexOf('<div id="content">');
    final end = fullHtml.lastIndexOf('</div>');
    if (start == -1 || end == -1) return fullHtml;
    final openTagEnd = fullHtml.indexOf('>', start) + 1;
    return fullHtml.substring(openTagEnd, end).trim();
  }
}
