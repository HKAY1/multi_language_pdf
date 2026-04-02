import 'pdf_widget.dart';

class PdfListView extends PdfWidget {
  final List<PdfWidget> children;
  final double gap;

  const PdfListView({required this.children, this.gap = 0});

  @override
  Future<void> resolve(bundle, client) async {
    await Future.wait(children.map((c) => c.resolve(bundle, client)));
  }

  @override
  String toHtml() {
    final styles = [
      'display: flex',
      'flex-direction: column',
      if (gap > 0) 'gap: ${gap.toInt()}px',
    ].join('; ');
    final childrenHtml = children.map((c) => c.toHtml()).join();
    return '<div style="$styles">$childrenHtml</div>';
  }
}
