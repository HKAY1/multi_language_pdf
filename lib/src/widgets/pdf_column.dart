import '../types/pdf_alignment.dart';
import 'pdf_widget.dart';

class PdfColumn extends PdfWidget {
  final List<PdfWidget> children;
  final PdfMainAxisAlignment mainAxisAlignment;
  final PdfCrossAxisAlignment crossAxisAlignment;
  final double gap;

  const PdfColumn({
    required this.children,
    this.mainAxisAlignment = PdfMainAxisAlignment.start,
    this.crossAxisAlignment = PdfCrossAxisAlignment.stretch,
    this.gap = 0,
  });

  @override
  Future<void> resolve(bundle, client) async {
    await Future.wait(children.map((c) => c.resolve(bundle, client)));
  }

  @override
  String toHtml() {
    final styles = [
      'display: flex',
      'flex-direction: column',
      'justify-content: ${mainAxisAlignment.toCss()}',
      'align-items: ${crossAxisAlignment.toCss()}',
      if (gap > 0) 'gap: ${gap.toInt()}px',
    ].join('; ');
    final childrenHtml = children.map((c) => c.toHtml()).join();
    return '<div style="$styles">$childrenHtml</div>';
  }
}
