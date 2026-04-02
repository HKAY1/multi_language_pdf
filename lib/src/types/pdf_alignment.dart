enum PdfMainAxisAlignment {
  start,
  center,
  end,
  spaceBetween,
  spaceAround;

  String toCss() => switch (this) {
        PdfMainAxisAlignment.start => 'flex-start',
        PdfMainAxisAlignment.center => 'center',
        PdfMainAxisAlignment.end => 'flex-end',
        PdfMainAxisAlignment.spaceBetween => 'space-between',
        PdfMainAxisAlignment.spaceAround => 'space-around',
      };
}

enum PdfCrossAxisAlignment {
  start,
  center,
  end,
  stretch;

  String toCss() => switch (this) {
        PdfCrossAxisAlignment.start => 'flex-start',
        PdfCrossAxisAlignment.center => 'center',
        PdfCrossAxisAlignment.end => 'flex-end',
        PdfCrossAxisAlignment.stretch => 'stretch',
      };
}

enum PdfTextAlign {
  left,
  center,
  right,
  justify;

  String toCss() => name;
}
