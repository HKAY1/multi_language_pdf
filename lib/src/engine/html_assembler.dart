import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../document/pdf_document.dart';

class HtmlAssembler {
  HtmlAssembler._();

  static final _httpClient = http.Client();

  /// Resolves all async assets in [doc], then builds and returns
  /// the complete HTML string ready for injection into the WebView.
  static Future<String> assemble(PdfDocument doc) async {
    // Resolve all widgets (images, etc.) concurrently
    await Future.wait(
      doc.children.map((w) => w.resolve(rootBundle, _httpClient)),
    );

    final config = doc.pageConfig;
    final margin = config.margin;

    // Each child is wrapped in a data-pdf-block div so the JS engine
    // can measure and group them into pages without splitting mid-widget.
    final blocksHtml = doc.children
        .map((w) => '<div data-pdf-block="true">${w.toHtml()}</div>')
        .join('\n');

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <style>
    * { box-sizing: border-box; font-family: sans-serif; }
    body { margin: 0; padding: 0; background: #fff; }
    #content {
      width: ${config.widthPx}px;
      padding: ${margin.toCss()};
    }
  </style>
</head>
<body>
  <div id="content">
$blocksHtml
  </div>
  <script>
    // Signals to PdfEngine that the page is ready for JS injection.
    window.addEventListener('load', () => Ready.postMessage('ready'));
  </script>
</body>
</html>''';
  }
}
