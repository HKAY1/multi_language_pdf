import '../types/pdf_border.dart';
import '../types/pdf_color.dart';
import '../types/pdf_table_column.dart';
import '../types/pdf_table_row.dart';
import '../types/pdf_text_style.dart';
import 'pdf_widget.dart';

class PdfTable extends PdfWidget {
  final List<PdfTableColumn> columns;
  final List<PdfTableRow> rows;
  final PdfTextStyle? headerStyle;
  final PdfColor? headerBackground;
  final PdfColor? rowAlternateColor;
  final PdfBorder? border;

  const PdfTable({
    required this.columns,
    required this.rows,
    this.headerStyle,
    this.headerBackground,
    this.rowAlternateColor,
    this.border,
  });

  @override
  String toHtml() {
    final borderCss = border != null
        ? 'border: ${border!.toCss()}; border-collapse: collapse;'
        : 'border-collapse: collapse;';
    final buffer = StringBuffer('<table style="width: 100%; $borderCss">');

    // Header row
    buffer.write('<thead><tr>');
    for (final col in columns) {
      final bgCss = headerBackground != null
          ? 'background-color: ${headerBackground!.toCss()};'
          : '';
      final styleCss = headerStyle?.toCss() ?? '';
      final borderTdCss = border != null ? 'border: ${border!.toCss()};' : '';
      buffer.write(
        '<th style="$bgCss $styleCss $borderTdCss padding: 10px; '
        'text-align: ${col.textAlign.toCss()}; flex: ${col.flex}">'
        '${_escape(col.label)}</th>',
      );
    }
    buffer.write('</tr></thead>');

    // Body rows
    buffer.write('<tbody>');
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final isAlt = i.isOdd && rowAlternateColor != null;
      final rowBg = row.highlight
          ? 'background-color: rgba(255,243,128,1.0);'
          : isAlt
              ? 'background-color: ${rowAlternateColor!.toCss()};'
              : '';
      buffer.write('<tr style="$rowBg">');
      for (int j = 0; j < row.cells.length && j < columns.length; j++) {
        final borderTdCss = border != null ? 'border: ${border!.toCss()};' : '';
        buffer.write(
          '<td style="$borderTdCss padding: 10px; '
          'text-align: ${columns[j].textAlign.toCss()}">'
          '${_escape(row.cells[j])}</td>',
        );
      }
      buffer.write('</tr>');
    }
    buffer.write('</tbody></table>');
    return buffer.toString();
  }

  String _escape(String t) => t
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
