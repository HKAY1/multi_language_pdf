import '../types/pdf_text_span.dart';
import 'pdf_widget.dart';

class PdfRichText extends PdfWidget {
  final List<PdfTextSpan> spans;

  const PdfRichText({required this.spans});

  @override
  String toHtml() {
    final spansHtml = spans.map((s) => s.toHtml()).join();
    return '<p style="margin: 0">$spansHtml</p>';
  }
}
