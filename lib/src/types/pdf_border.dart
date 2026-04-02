import 'pdf_color.dart';

class PdfBorder {
  final PdfColor color;
  final double width;
  final double radius;

  const PdfBorder({required this.color, this.width = 1, this.radius = 0});

  String toCss() => '${width}px solid ${color.toCss()}';

  String toRadiusCss() => radius > 0 ? '${radius}px' : '';
}
