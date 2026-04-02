import '../widgets/pdf_widget.dart';
import 'pdf_page_config.dart';

class PdfDocument {
  final PdfPageConfig pageConfig;
  final List<PdfWidget> children;

  const PdfDocument({
    required this.children,
    PdfPageConfig? pageConfig,
  }) : pageConfig = pageConfig ?? const PdfPageConfig();
}
