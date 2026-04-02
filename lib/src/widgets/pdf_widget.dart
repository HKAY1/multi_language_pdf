import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

abstract class PdfWidget {
  const PdfWidget();

  /// Override to pre-load async resources (images, fonts).
  /// Layout widgets must call resolve() on all children.
  Future<void> resolve(AssetBundle bundle, http.Client client) async {}

  /// Returns the HTML string for this widget.
  /// Must only be called after resolve() completes.
  String toHtml();
}
