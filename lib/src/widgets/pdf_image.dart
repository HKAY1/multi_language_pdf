import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'pdf_widget.dart';

enum _PdfImageSource { asset, memory, network }

class PdfImage extends PdfWidget {
  final _PdfImageSource _source;
  final String? _path;
  final Uint8List? _bytes;
  final double? width;
  final double? height;

  String? _resolvedDataUri;

  PdfImage._({
    required _PdfImageSource source,
    String? path,
    Uint8List? bytes,
    this.width,
    this.height,
  })  : _source = source,
        _path = path,
        _bytes = bytes;

  factory PdfImage.asset(String path, {double? width, double? height}) =>
      PdfImage._(source: _PdfImageSource.asset, path: path, width: width, height: height);

  factory PdfImage.memory(Uint8List bytes, {double? width, double? height}) =>
      PdfImage._(source: _PdfImageSource.memory, bytes: bytes, width: width, height: height);

  factory PdfImage.network(String url, {double? width, double? height}) =>
      PdfImage._(source: _PdfImageSource.network, path: url, width: width, height: height);

  @override
  Future<void> resolve(dynamic bundle, dynamic client) async {
    switch (_source) {
      case _PdfImageSource.asset:
        final data = await (bundle as AssetBundle).load(_path!);
        final bytes = data.buffer.asUint8List();
        _resolvedDataUri = 'data:image/png;base64,${base64Encode(bytes)}';
      case _PdfImageSource.memory:
        _resolvedDataUri = 'data:image/png;base64,${base64Encode(_bytes!)}';
      case _PdfImageSource.network:
        final response = await (client as http.Client).get(Uri.parse(_path!));
        final mimeType = response.headers['content-type'] ?? 'image/png';
        _resolvedDataUri = 'data:$mimeType;base64,${base64Encode(response.bodyBytes)}';
    }
  }

  @override
  String toHtml() {
    if (_resolvedDataUri == null) {
      throw StateError('PdfImage.resolve() must be called before toHtml().');
    }
    final styles = <String>['object-fit: cover'];
    if (width != null) styles.add('width: ${width}px');
    if (height != null) styles.add('height: ${height}px');
    return '<img src="$_resolvedDataUri" style="${styles.join('; ')}" />';
  }
}
