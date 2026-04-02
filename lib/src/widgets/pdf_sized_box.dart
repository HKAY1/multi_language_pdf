import 'pdf_widget.dart';

class PdfSizedBox extends PdfWidget {
  final double? width;
  final double? height;

  const PdfSizedBox({this.width, this.height});

  @override
  String toHtml() {
    final styles = <String>[
      'display: block',
      if (width != null) 'width: ${width}px',
      if (height != null) 'height: ${height}px',
    ];
    return '<div style="${styles.join('; ')}"></div>';
  }
}
