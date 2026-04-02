import 'package:flutter_test/flutter_test.dart';
import 'package:multi_language_pdf/src/widgets/pdf_table.dart';
import 'package:multi_language_pdf/src/types/pdf_table_column.dart';
import 'package:multi_language_pdf/src/types/pdf_table_row.dart';
import 'package:multi_language_pdf/src/types/pdf_color.dart';
import 'package:multi_language_pdf/src/types/pdf_border.dart';
import 'package:multi_language_pdf/src/types/pdf_text_style.dart';

void main() {
  final columns = [
    PdfTableColumn(label: 'Name', flex: 2),
    PdfTableColumn(label: 'Amount', flex: 1),
  ];
  final rows = [
    PdfTableRow(cells: ['Alice', '500']),
    PdfTableRow(cells: ['Bob', '320'], highlight: true),
  ];

  test('renders a table element', () {
    final html = PdfTable(columns: columns, rows: rows).toHtml();
    expect(html, contains('<table'));
    expect(html, contains('</table>'));
  });

  test('renders column headers', () {
    final html = PdfTable(columns: columns, rows: rows).toHtml();
    expect(html, contains('Name'));
    expect(html, contains('Amount'));
  });

  test('renders row cells', () {
    final html = PdfTable(columns: columns, rows: rows).toHtml();
    expect(html, contains('Alice'));
    expect(html, contains('500'));
    expect(html, contains('Bob'));
  });

  test('applies header background color', () {
    final html = PdfTable(
      columns: columns,
      rows: rows,
      headerBackground: PdfColor(33, 150, 243),
    ).toHtml();
    expect(html, contains('rgba(33,150,243,1.0)'));
  });

  test('applies header text style', () {
    final html = PdfTable(
      columns: columns,
      rows: rows,
      headerStyle: PdfTextStyle(bold: true),
    ).toHtml();
    expect(html, contains('font-weight: bold'));
  });

  test('applies border', () {
    final html = PdfTable(
      columns: columns,
      rows: rows,
      border: PdfBorder(color: PdfColor(0, 0, 0), width: 1),
    ).toHtml();
    expect(html, contains('border:'));
  });
}
