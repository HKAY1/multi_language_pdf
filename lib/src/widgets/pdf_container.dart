import '../types/pdf_border.dart';
import '../types/pdf_color.dart';
import '../types/pdf_edge_insets.dart';
import 'pdf_widget.dart';

class PdfContainer extends PdfWidget {
  final double? width;
  final double? height;
  final PdfColor? color;
  final PdfEdgeInsets? padding;
  final PdfEdgeInsets? margin;
  final PdfBorder? border;
  final PdfWidget? child;

  const PdfContainer({
    this.width,
    this.height,
    this.color,
    this.padding,
    this.margin,
    this.border,
    this.child,
  });

  @override
  Future<void> resolve(bundle, client) async {
    await child?.resolve(bundle, client);
  }

  @override
  String toHtml() {
    final styles = <String>['box-sizing: border-box'];
    if (width != null) styles.add('width: ${width}px');
    if (height != null) styles.add('height: ${height}px');
    if (color != null) styles.add('background-color: ${color!.toCss()}');
    if (padding != null) styles.add('padding: ${padding!.toCss()}');
    if (margin != null) styles.add('margin: ${margin!.toCss()}');
    if (border != null) {
      styles.add('border: ${border!.toCss()}');
      if (border!.radius > 0) styles.add('border-radius: ${border!.toRadiusCss()}');
    }
    return '<div style="${styles.join('; ')}">${child?.toHtml() ?? ''}</div>';
  }
}
