import '../types/pdf_edge_insets.dart';
import 'pdf_widget.dart';

class PdfPadding extends PdfWidget {
  final PdfEdgeInsets padding;
  final PdfWidget child;

  const PdfPadding({required this.padding, required this.child});

  @override
  Future<void> resolve(bundle, client) => child.resolve(bundle, client);

  @override
  String toHtml() =>
      '<div style="padding: ${padding.toCss()}">${child.toHtml()}</div>';
}
