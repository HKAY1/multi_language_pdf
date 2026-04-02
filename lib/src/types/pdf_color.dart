class PdfColor {
  final int r, g, b;
  final double a;

  const PdfColor(this.r, this.g, this.b, {this.a = 1.0});

  factory PdfColor.fromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    return PdfColor(
      int.parse(h.substring(0, 2), radix: 16),
      int.parse(h.substring(2, 4), radix: 16),
      int.parse(h.substring(4, 6), radix: 16),
    );
  }

  static const PdfColor transparent = PdfColor(0, 0, 0, a: 0.0);

  String toCss() => 'rgba($r,$g,$b,$a)';
}
