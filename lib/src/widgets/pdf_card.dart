import '../types/pdf_color.dart';
import '../types/pdf_edge_insets.dart';
import 'pdf_widget.dart';

class PdfCard extends PdfWidget {
  final PdfWidget child;
  final double elevation;
  final PdfColor color;
  final double borderRadius;
  final PdfEdgeInsets padding;

  const PdfCard({
    required this.child,
    this.elevation = 2,
    this.color = const PdfColor(255, 255, 255),
    this.borderRadius = 8,
    this.padding = const PdfEdgeInsets.all(16),
  });

  @override
  Future<void> resolve(bundle, client) => child.resolve(bundle, client);

  @override
  String toHtml() {
    final blur = elevation * 4;
    final spread = elevation;
    final shadow = '0 ${elevation * 2}px ${blur}px ${spread}px rgba(0,0,0,0.12)';
    final styles = [
      'background-color: ${color.toCss()}',
      'border-radius: ${borderRadius}px',
      'padding: ${padding.toCss()}',
      'box-shadow: $shadow',
      'box-sizing: border-box',
    ].join('; ');
    return '<div style="$styles">${child.toHtml()}</div>';
  }
}
