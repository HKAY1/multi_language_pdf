import 'pdf_alignment.dart';

class PdfTableColumn {
  final String label;
  final int flex;
  final PdfTextAlign textAlign;

  const PdfTableColumn({
    required this.label,
    this.flex = 1,
    this.textAlign = PdfTextAlign.left,
  });
}
