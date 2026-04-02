import 'pdf_positioned.dart';
import 'pdf_widget.dart';

class PdfStack extends PdfWidget {
  final List<PdfPositioned> children;

  const PdfStack({required this.children});

  @override
  Future<void> resolve(bundle, client) async {
    await Future.wait(children.map((c) => c.resolve(bundle, client)));
  }

  @override
  String toHtml() {
    final childrenHtml = children.map((c) => c.toHtml()).join();
    return '<div style="position: relative">$childrenHtml</div>';
  }
}
