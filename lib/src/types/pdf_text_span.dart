import 'pdf_color.dart';

class PdfTextSpan {
  final String text;
  final double? fontSize;
  final bool bold;
  final bool italic;
  final bool underline;
  final PdfColor? color;

  const PdfTextSpan(
    this.text, {
    this.fontSize,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color,
  });

  String toHtml() {
    final parts = <String>[];
    if (bold) parts.add('font-weight: bold');
    if (italic) parts.add('font-style: italic');
    if (underline) parts.add('text-decoration: underline');
    if (fontSize != null) parts.add('font-size: ${fontSize}px');
    if (color != null) parts.add('color: ${color!.toCss()}');
    final style = parts.join('; ');
    return '<span style="$style">${_escape(text)}</span>';
  }

  String _escape(String t) => t
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
