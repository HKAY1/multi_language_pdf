import 'package:flutter/widgets.dart';
import '../types/pdf_color.dart';
import 'pdf_widget.dart';

class PdfIcon extends PdfWidget {
  final IconData icon;
  final double size;
  final PdfColor? color;

  const PdfIcon(this.icon, {this.size = 24, this.color});

  @override
  String toHtml() {
    final char = String.fromCharCode(icon.codePoint);
    final styles = <String>[
      'font-family: Material Icons',
      'font-size: ${size % 1 == 0 ? size.toInt() : size}px',
      'font-style: normal',
      'display: inline-block',
      'line-height: 1',
      if (color != null) 'color: ${color!.toCss()}',
    ];
    return '<span style="${styles.join('; ')}">$char</span>';
  }
}
