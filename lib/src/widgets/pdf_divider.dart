import '../types/pdf_color.dart';
import 'pdf_widget.dart';

class PdfDivider extends PdfWidget {
  final double thickness;
  final PdfColor color;
  final double indent;
  final double endIndent;

  const PdfDivider({
    this.thickness = 1,
    this.color = const PdfColor(238, 238, 238),
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  String toHtml() {
    return '<hr style="border: none; border-top: ${thickness}px solid ${color.toCss()}; '
        'margin: 0 ${endIndent}px 0 ${indent}px;" />';
  }
}
