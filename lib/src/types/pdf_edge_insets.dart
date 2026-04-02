class PdfEdgeInsets {
  final double left, top, right, bottom;

  const PdfEdgeInsets.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  const PdfEdgeInsets.all(double value)
      : left = value, top = value, right = value, bottom = value;

  const PdfEdgeInsets.symmetric({double horizontal = 0, double vertical = 0})
      : left = horizontal, right = horizontal, top = vertical, bottom = vertical;

  static const PdfEdgeInsets zero = PdfEdgeInsets.all(0);

  // CSS shorthand: top right bottom left
  String toCss() => '${top}px ${right}px ${bottom}px ${left}px';
}
