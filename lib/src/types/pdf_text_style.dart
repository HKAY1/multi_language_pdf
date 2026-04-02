import 'pdf_color.dart';

class PdfTextStyle {
  final bool bold;
  final bool italic;
  final double? fontSize;
  final PdfColor? color;

  const PdfTextStyle({
    this.bold = false,
    this.italic = false,
    this.fontSize,
    this.color,
  });

  String toCss() {
    final parts = <String>[];
    if (bold) parts.add('font-weight: bold');
    if (italic) parts.add('font-style: italic');
    if (fontSize != null) parts.add('font-size: ${fontSize}px');
    if (color != null) parts.add('color: ${color!.toCss()}');
    return parts.join('; ');
  }
}
