import 'pdf_widget.dart';

class PdfPositioned extends PdfWidget {
  final PdfWidget child;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const PdfPositioned({
    required this.child,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Future<void> resolve(bundle, client) => child.resolve(bundle, client);

  @override
  String toHtml() {
    final styles = <String>['position: absolute'];
    if (top != null) styles.add('top: ${top}px');
    if (bottom != null) styles.add('bottom: ${bottom}px');
    if (left != null) styles.add('left: ${left}px');
    if (right != null) styles.add('right: ${right}px');
    return '<div style="${styles.join('; ')}">${child.toHtml()}</div>';
  }
}
