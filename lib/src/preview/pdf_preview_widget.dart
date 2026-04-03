import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../document/pdf_document.dart';
import '../engine/html_assembler.dart';

/// Renders a visual preview of [document] in a WebView.
///
/// This does NOT generate a PDF — it renders the same HTML that will be used
/// for generation, so the developer sees an accurate representation of the output.
///
/// The generate button (if needed) is the caller's responsibility:
/// ```dart
/// Column(children: [
///   Expanded(child: PdfPreviewWidget(document: doc)),
///   ElevatedButton(onPressed: () => PdfGenerator.generate(...), child: Text('Export PDF')),
/// ])
/// ```
class PdfPreviewWidget extends StatefulWidget {
  final PdfDocument document;
  final Widget? loadingWidget;

  const PdfPreviewWidget({
    required this.document,
    this.loadingWidget,
    super.key,
  });

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ));
    _loadPreview();
  }

  @override
  void didUpdateWidget(PdfPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) _loadPreview();
  }

  Future<void> _loadPreview() async {
    if (mounted) setState(() => _loading = true);
    final html = await HtmlAssembler.assemble(widget.document);
    _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          Center(
            child: widget.loadingWidget ?? const CircularProgressIndicator(),
          ),
      ],
    );
  }
}
