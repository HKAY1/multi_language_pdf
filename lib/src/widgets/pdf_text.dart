import '../types/pdf_alignment.dart';
import '../types/pdf_color.dart';
import 'pdf_widget.dart';

class PdfText extends PdfWidget {
  final String text;
  final double fontSize;
  final bool bold;
  final bool italic;
  final bool underline;
  final PdfColor? color;
  final PdfTextAlign textAlign;
  final int? maxLines;

  const PdfText(
    this.text, {
    this.fontSize = 14,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color,
    this.textAlign = PdfTextAlign.left,
    this.maxLines,
  });

  @override
  String toHtml() {
    final styles = <String>[
      'margin: 0',
      'font-size: ${fontSize}px',
      'text-align: ${textAlign.toCss()}',
      if (color != null) 'color: ${color!.toCss()}',
      if (bold) 'font-weight: bold',
      if (italic) 'font-style: italic',
      if (underline) 'text-decoration: underline',
      if (maxLines != null) 'overflow: hidden',
      if (maxLines != null) 'display: -webkit-box',
      if (maxLines != null) '-webkit-line-clamp: $maxLines',
      if (maxLines != null) '-webkit-box-orient: vertical',
    ];
    return '<p style="${styles.join('; ')}">${_escape(text)}</p>';
  }

  String _escape(String t) => t
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
