import '../types/pdf_edge_insets.dart';

enum PdfPageOrientation { portrait, landscape }

class PdfPageConfig {
  final PdfPageOrientation orientation;
  final PdfEdgeInsets margin;

  const PdfPageConfig({
    this.orientation = PdfPageOrientation.portrait,
    this.margin = const PdfEdgeInsets.all(30),
  });

  static PdfPageConfig a4Portrait({
    PdfEdgeInsets margin = const PdfEdgeInsets.all(30),
  }) =>
      PdfPageConfig(orientation: PdfPageOrientation.portrait, margin: margin);

  static PdfPageConfig a4Landscape({
    PdfEdgeInsets margin = const PdfEdgeInsets.all(30),
  }) =>
      PdfPageConfig(orientation: PdfPageOrientation.landscape, margin: margin);

  /// A4 at 96 DPI: 794×1123 px (portrait), 1123×794 px (landscape)
  double get widthPx =>
      orientation == PdfPageOrientation.portrait ? 794 : 1123;
  double get heightPx =>
      orientation == PdfPageOrientation.portrait ? 1123 : 794;
}
