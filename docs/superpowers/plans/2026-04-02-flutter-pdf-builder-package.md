# Flutter PDF Builder Package Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

## Progress Status (updated 2026-04-02)

| Task | Status |
|------|--------|
| Task 1: Package Scaffolding | ✅ DONE |
| Task 2: Supporting Types | ✅ DONE |
| Task 3: PdfWidget base, PdfPageConfig, PdfDocument | ✅ DONE |
| Task 4: Leaf Widgets (PdfText, PdfRichText, PdfSizedBox, PdfDivider) | ✅ DONE |
| Task 5: Layout Widgets (PdfPadding, PdfRow, PdfColumn, PdfListView, PdfContainer, PdfCard) | ✅ DONE |
| Task 6: PdfStack and PdfPositioned | ✅ DONE |
| Task 7: PdfImage | ✅ DONE |
| Task 8: PdfIcon | ✅ DONE |
| Task 9: PdfTable | ✅ DONE |
| Task 10: HtmlAssembler | ✅ DONE |
| Task 11: JavaScript Engine (index.html) | ⏳ TODO |
| Task 12: PdfEngine (WebView lifecycle + JS bridge) | ⏳ TODO |
| Task 13: PdfGeneratorScope + PdfGenerator | ⏳ TODO |
| Task 14: PdfPreviewWidget | ⏳ TODO |
| Task 15: Barrel export + README | ⏳ TODO |

**Test suite at last checkpoint: 54/54 tests passing**  
**Package name:** `multi_language_pdf` (built in `/Users/admin/Harsh/package/multi_language_pdf/multi_language_pdf/`)  
**Resume from:** Task 11

**Goal:** Build and publish a zero-state-manager Flutter package that lets developers compose PDFs using a Flutter-inspired DSL, rendered via a hidden WebView (html2canvas + jsPDF) with semantic pagination and an optional preview widget.

**Architecture:** A `PdfDocument` holds a tree of `PdfWidget` nodes. Each widget implements `toHtml()` for synchronous HTML serialisation and `resolve()` for async asset pre-loading. A `PdfGeneratorScope` widget mounts a hidden `WebViewWidget` in the tree; `PdfGenerator.generate()` uses it to run the measure-then-render-per-page JavaScript engine and returns the result via callbacks. `PdfPreviewWidget` uses its own independent `WebViewWidget` to render the HTML for visual preview without PDF generation.

**Tech Stack:** Dart 3, Flutter, `webview_flutter ^4.0.0`, `path_provider ^2.0.0`, `http ^1.0.0`, `html2canvas` (bundled JS), `jsPDF` (bundled JS), `flutter_test`, `test`

**Package root:** `/Users/admin/Harsh/flutter/flutter_pdf_builder/`  
**Spec:** `sachiv/docs/superpowers/specs/2026-04-02-flutter-pdf-builder-package-design.md`

---

## File Map

```
flutter_pdf_builder/
├── lib/
│   ├── flutter_pdf_builder.dart                    # barrel export
│   └── src/
│       ├── types/
│       │   ├── pdf_color.dart
│       │   ├── pdf_edge_insets.dart
│       │   ├── pdf_border.dart
│       │   ├── pdf_text_style.dart
│       │   ├── pdf_text_span.dart
│       │   ├── pdf_alignment.dart
│       │   ├── pdf_table_column.dart
│       │   └── pdf_table_row.dart
│       ├── document/
│       │   ├── pdf_page_config.dart
│       │   └── pdf_document.dart
│       ├── widgets/
│       │   ├── pdf_widget.dart                     # abstract base
│       │   ├── pdf_text.dart
│       │   ├── pdf_rich_text.dart
│       │   ├── pdf_sized_box.dart
│       │   ├── pdf_divider.dart
│       │   ├── pdf_padding.dart
│       │   ├── pdf_row.dart
│       │   ├── pdf_column.dart
│       │   ├── pdf_list_view.dart
│       │   ├── pdf_container.dart
│       │   ├── pdf_card.dart
│       │   ├── pdf_stack.dart
│       │   ├── pdf_positioned.dart
│       │   ├── pdf_image.dart
│       │   ├── pdf_icon.dart
│       │   └── pdf_table.dart
│       ├── engine/
│       │   ├── html_assembler.dart                 # PdfDocument → full HTML string
│       │   └── pdf_engine.dart                     # WebViewController lifecycle + JS bridge
│       ├── generator/
│       │   └── pdf_generator.dart                  # PdfGeneratorScope widget + PdfGenerator static API
│       └── preview/
│           └── pdf_preview_widget.dart
├── assets/
│   └── pdf_engine/
│       ├── index.html                              # measure-then-render JS engine
│       └── js/
│           ├── html2canvas.min.js
│           └── jspdf.umd.min.js
├── test/
│   ├── types/
│   │   ├── pdf_color_test.dart
│   │   ├── pdf_edge_insets_test.dart
│   │   └── pdf_border_test.dart
│   ├── widgets/
│   │   ├── pdf_text_test.dart
│   │   ├── pdf_rich_text_test.dart
│   │   ├── pdf_row_test.dart
│   │   ├── pdf_column_test.dart
│   │   ├── pdf_container_test.dart
│   │   ├── pdf_table_test.dart
│   │   ├── pdf_stack_test.dart
│   │   └── pdf_image_test.dart
│   └── engine/
│       └── html_assembler_test.dart
└── pubspec.yaml
```

---

## Task 1: Package Scaffolding

**Files:**
- Create: `flutter_pdf_builder/pubspec.yaml`
- Create: `flutter_pdf_builder/lib/flutter_pdf_builder.dart` (empty barrel for now)
- Create: all directories in the file map above

- [ ] **Step 1: Create the Flutter package**

```bash
cd /Users/admin/Harsh/flutter
flutter create --template=package flutter_pdf_builder
cd flutter_pdf_builder
```

Expected: Flutter package scaffold created with `lib/flutter_pdf_builder.dart` and `pubspec.yaml`.

- [ ] **Step 2: Replace pubspec.yaml**

```yaml
name: flutter_pdf_builder
description: Build PDFs using a Flutter-inspired DSL. Multi-language support via WebView rendering. Zero state-manager dependency.
version: 0.1.0
homepage: https://github.com/yourusername/flutter_pdf_builder

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  webview_flutter: 4.13.1
  path_provider: ^2.1.5
  http: ^1.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  test: ^1.24.0

flutter:
  assets:
    - packages/flutter_pdf_builder/assets/pdf_engine/index.html
    - packages/flutter_pdf_builder/assets/pdf_engine/js/html2canvas.min.js
    - packages/flutter_pdf_builder/assets/pdf_engine/js/jspdf.umd.min.js
```

- [ ] **Step 3: Create all source directories**

```bash
mkdir -p lib/src/types lib/src/document lib/src/widgets lib/src/engine lib/src/generator lib/src/preview
mkdir -p assets/pdf_engine/js
mkdir -p test/types test/widgets test/engine
```

- [ ] **Step 4: Copy JS libraries from sachiv into package assets**

```bash
cp /Users/admin/Harsh/flutter/sachiv/assets/pdf_engine/js/html2canvas.min.js assets/pdf_engine/js/
cp /Users/admin/Harsh/flutter/sachiv/assets/pdf_engine/js/jspdf.umd.min.js assets/pdf_engine/js/
```

- [ ] **Step 5: Verify flutter pub get succeeds**

```bash
flutter pub get
```
Expected: Resolves without errors.

- [ ] **Step 6: Commit**

```bash
git init && git add .
git commit -m "feat: scaffold flutter_pdf_builder package"
```

---

## Task 2: Supporting Types

**Files:**
- Create: `lib/src/types/pdf_color.dart`
- Create: `lib/src/types/pdf_edge_insets.dart`
- Create: `lib/src/types/pdf_border.dart`
- Create: `lib/src/types/pdf_text_style.dart`
- Create: `lib/src/types/pdf_text_span.dart`
- Create: `lib/src/types/pdf_alignment.dart`
- Create: `lib/src/types/pdf_table_column.dart`
- Create: `lib/src/types/pdf_table_row.dart`
- Test: `test/types/pdf_color_test.dart`
- Test: `test/types/pdf_edge_insets_test.dart`
- Test: `test/types/pdf_border_test.dart`

- [ ] **Step 1: Write failing tests for PdfColor**

`test/types/pdf_color_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/types/pdf_color.dart';

void main() {
  group('PdfColor', () {
    test('toCss produces rgba string', () {
      expect(PdfColor(255, 0, 0).toCss(), 'rgba(255,0,0,1.0)');
    });

    test('toCss respects alpha', () {
      expect(PdfColor(0, 0, 0, a: 0.5).toCss(), 'rgba(0,0,0,0.5)');
    });

    test('fromHex parses 6-char hex', () {
      expect(PdfColor.fromHex('#2196F3').toCss(), 'rgba(33,150,243,1.0)');
    });

    test('fromHex works without hash prefix', () {
      expect(PdfColor.fromHex('FF0000').toCss(), 'rgba(255,0,0,1.0)');
    });

    test('transparent has alpha 0', () {
      expect(PdfColor.transparent.toCss(), 'rgba(0,0,0,0.0)');
    });
  });
}
```

- [ ] **Step 2: Run tests — expect failure**

```bash
flutter test test/types/pdf_color_test.dart
```
Expected: FAIL — `pdf_color.dart` does not exist.

- [ ] **Step 3: Implement PdfColor**

`lib/src/types/pdf_color.dart`:
```dart
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
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/types/pdf_color_test.dart
```
Expected: All 5 tests pass.

- [ ] **Step 5: Write failing tests for PdfEdgeInsets**

`test/types/pdf_edge_insets_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/types/pdf_edge_insets.dart';

void main() {
  group('PdfEdgeInsets', () {
    test('all sets all sides', () {
      final e = PdfEdgeInsets.all(8);
      expect(e.toCss(), '8.0px 8.0px 8.0px 8.0px');
    });

    test('symmetric sets horizontal and vertical', () {
      final e = PdfEdgeInsets.symmetric(horizontal: 16, vertical: 4);
      expect(e.toCss(), '4.0px 16.0px 4.0px 16.0px');
    });

    test('only sets specified sides, others default to 0', () {
      final e = PdfEdgeInsets.only(left: 10, bottom: 5);
      expect(e.toCss(), '0.0px 0.0px 5.0px 10.0px');
    });

    test('zero produces all zeros', () {
      expect(PdfEdgeInsets.zero.toCss(), '0.0px 0.0px 0.0px 0.0px');
    });
  });
}
```

- [ ] **Step 6: Implement PdfEdgeInsets**

`lib/src/types/pdf_edge_insets.dart`:
```dart
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
```

- [ ] **Step 7: Run PdfEdgeInsets tests — expect pass**

```bash
flutter test test/types/pdf_edge_insets_test.dart
```
Expected: All 4 tests pass.

- [ ] **Step 8: Write failing test for PdfBorder**

`test/types/pdf_border_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/types/pdf_border.dart';
import 'package:flutter_pdf_builder/src/types/pdf_color.dart';

void main() {
  group('PdfBorder', () {
    test('toCss produces correct border shorthand', () {
      final b = PdfBorder(color: PdfColor(0, 0, 0), width: 1);
      expect(b.toCss(), '1.0px solid rgba(0,0,0,1.0)');
    });

    test('toRadiusCss produces border-radius value', () {
      final b = PdfBorder(color: PdfColor(0, 0, 0), width: 1, radius: 8);
      expect(b.toRadiusCss(), '8.0px');
    });

    test('toRadiusCss returns empty string when radius is zero', () {
      final b = PdfBorder(color: PdfColor(0, 0, 0), width: 1);
      expect(b.toRadiusCss(), '');
    });
  });
}
```

- [ ] **Step 9: Implement PdfBorder, PdfTextStyle, PdfTextSpan, enums, PdfTableColumn, PdfTableRow**

`lib/src/types/pdf_border.dart`:
```dart
import 'pdf_color.dart';

class PdfBorder {
  final PdfColor color;
  final double width;
  final double radius;

  const PdfBorder({required this.color, this.width = 1, this.radius = 0});

  String toCss() => '${width}px solid ${color.toCss()}';

  String toRadiusCss() => radius > 0 ? '${radius}px' : '';
}
```

`lib/src/types/pdf_text_style.dart`:
```dart
import 'pdf_color.dart';

class PdfTextStyle {
  final bool bold;
  final bool italic;
  final double? fontSize;
  final PdfColor? color;

  const PdfTextStyle({
    this.bold = false,
    this.italic = false,
    this.fontSize,
    this.color,
  });

  String toCss() {
    final parts = <String>[];
    if (bold) parts.add('font-weight: bold');
    if (italic) parts.add('font-style: italic');
    if (fontSize != null) parts.add('font-size: ${fontSize}px');
    if (color != null) parts.add('color: ${color!.toCss()}');
    return parts.join('; ');
  }
}
```

`lib/src/types/pdf_text_span.dart`:
```dart
import 'pdf_color.dart';

class PdfTextSpan {
  final String text;
  final double? fontSize;
  final bool bold;
  final bool italic;
  final bool underline;
  final PdfColor? color;

  const PdfTextSpan(
    this.text, {
    this.fontSize,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color,
  });

  String toHtml() {
    final parts = <String>[];
    if (bold) parts.add('font-weight: bold');
    if (italic) parts.add('font-style: italic');
    if (underline) parts.add('text-decoration: underline');
    if (fontSize != null) parts.add('font-size: ${fontSize}px');
    if (color != null) parts.add('color: ${color!.toCss()}');
    final style = parts.join('; ');
    return '<span style="$style">${_escape(text)}</span>';
  }

  String _escape(String t) => t
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
```

`lib/src/types/pdf_alignment.dart`:
```dart
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
```

`lib/src/types/pdf_table_column.dart`:
```dart
import 'pdf_alignment.dart';

class PdfTableColumn {
  final String label;
  final int flex;
  final PdfTextAlign textAlign;

  const PdfTableColumn({
    required this.label,
    this.flex = 1,
    this.textAlign = PdfTextAlign.left,
  });
}
```

`lib/src/types/pdf_table_row.dart`:
```dart
class PdfTableRow {
  final List<String> cells;
  final bool highlight;

  const PdfTableRow({required this.cells, this.highlight = false});
}
```

- [ ] **Step 10: Run all type tests — expect pass**

```bash
flutter test test/types/
```
Expected: All tests pass.

- [ ] **Step 11: Commit**

```bash
git add lib/src/types/ test/types/
git commit -m "feat: add supporting types — PdfColor, PdfEdgeInsets, PdfBorder, PdfTextStyle, PdfTextSpan, alignments, PdfTableColumn, PdfTableRow"
```

---

## Task 3: PdfWidget Base, PdfPageConfig, PdfDocument

**Files:**
- Create: `lib/src/widgets/pdf_widget.dart`
- Create: `lib/src/document/pdf_page_config.dart`
- Create: `lib/src/document/pdf_document.dart`

- [ ] **Step 1: Implement PdfWidget abstract base**

`lib/src/widgets/pdf_widget.dart`:
```dart
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

abstract class PdfWidget {
  const PdfWidget();

  /// Override to pre-load async resources (images, fonts).
  /// Layout widgets must call resolve() on all children.
  Future<void> resolve(AssetBundle bundle, http.Client client) async {}

  /// Returns the HTML string for this widget.
  /// Must only be called after resolve() completes.
  String toHtml();
}
```

- [ ] **Step 2: Implement PdfPageConfig**

`lib/src/document/pdf_page_config.dart`:
```dart
import '../types/pdf_edge_insets.dart';

enum PdfPageOrientation { portrait, landscape }

class PdfPageConfig {
  final PdfPageOrientation orientation;
  final PdfEdgeInsets margin;

  const PdfPageConfig._({required this.orientation, required this.margin});

  factory PdfPageConfig.a4Portrait({
    PdfEdgeInsets margin = const PdfEdgeInsets.all(30),
  }) =>
      PdfPageConfig._(orientation: PdfPageOrientation.portrait, margin: margin);

  factory PdfPageConfig.a4Landscape({
    PdfEdgeInsets margin = const PdfEdgeInsets.all(30),
  }) =>
      PdfPageConfig._(orientation: PdfPageOrientation.landscape, margin: margin);

  /// A4 at 96 DPI: 794×1123 px (portrait), 1123×794 px (landscape)
  double get widthPx => orientation == PdfPageOrientation.portrait ? 794 : 1123;
  double get heightPx => orientation == PdfPageOrientation.portrait ? 1123 : 794;
}
```

- [ ] **Step 3: Implement PdfDocument**

`lib/src/document/pdf_document.dart`:
```dart
import '../widgets/pdf_widget.dart';
import 'pdf_page_config.dart';

class PdfDocument {
  final PdfPageConfig pageConfig;
  final List<PdfWidget> children;

  const PdfDocument({
    required this.children,
    PdfPageConfig? pageConfig,
  }) : pageConfig = pageConfig ?? const _DefaultA4();
}

class _DefaultA4 extends PdfPageConfig {
  const _DefaultA4()
      : super._(
          orientation: PdfPageOrientation.portrait,
          margin: const PdfEdgeInsets.all(30),
        );
}
```

Wait — `PdfPageConfig._` is a private constructor. Fix by making the base constructor `const` accessible. Revise `pdf_page_config.dart` to use a named `const` constructor instead:

`lib/src/document/pdf_page_config.dart` (revised):
```dart
import '../types/pdf_edge_insets.dart';

enum PdfPageOrientation { portrait, landscape }

class PdfPageConfig {
  final PdfPageOrientation orientation;
  final PdfEdgeInsets margin;

  const PdfPageConfig({
    this.orientation = PdfPageOrientation.portrait,
    this.margin = const PdfEdgeInsets.all(30),
  });

  static PdfPageConfig a4Portrait({
    PdfEdgeInsets margin = const PdfEdgeInsets.all(30),
  }) =>
      PdfPageConfig(orientation: PdfPageOrientation.portrait, margin: margin);

  static PdfPageConfig a4Landscape({
    PdfEdgeInsets margin = const PdfEdgeInsets.all(30),
  }) =>
      PdfPageConfig(orientation: PdfPageOrientation.landscape, margin: margin);

  double get widthPx =>
      orientation == PdfPageOrientation.portrait ? 794 : 1123;
  double get heightPx =>
      orientation == PdfPageOrientation.portrait ? 1123 : 794;
}
```

`lib/src/document/pdf_document.dart` (revised):
```dart
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
```

- [ ] **Step 4: Commit**

```bash
git add lib/src/widgets/pdf_widget.dart lib/src/document/
git commit -m "feat: add PdfWidget base, PdfPageConfig, PdfDocument"
```

---

## Task 4: Leaf Widgets — PdfText, PdfRichText, PdfSizedBox, PdfDivider

**Files:**
- Create: `lib/src/widgets/pdf_text.dart`
- Create: `lib/src/widgets/pdf_rich_text.dart`
- Create: `lib/src/widgets/pdf_sized_box.dart`
- Create: `lib/src/widgets/pdf_divider.dart`
- Test: `test/widgets/pdf_text_test.dart`
- Test: `test/widgets/pdf_rich_text_test.dart`

- [ ] **Step 1: Write failing tests for PdfText**

`test/widgets/pdf_text_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_text.dart';
import 'package:flutter_pdf_builder/src/types/pdf_color.dart';
import 'package:flutter_pdf_builder/src/types/pdf_alignment.dart';

void main() {
  group('PdfText.toHtml', () {
    test('renders plain text in a paragraph', () {
      final html = PdfText('Hello').toHtml();
      expect(html, contains('<p'));
      expect(html, contains('Hello'));
      expect(html, contains('</p>'));
    });

    test('applies font-size', () {
      final html = PdfText('x', fontSize: 20).toHtml();
      expect(html, contains('font-size: 20px'));
    });

    test('applies bold', () {
      final html = PdfText('x', bold: true).toHtml();
      expect(html, contains('font-weight: bold'));
    });

    test('applies italic', () {
      final html = PdfText('x', italic: true).toHtml();
      expect(html, contains('font-style: italic'));
    });

    test('applies underline', () {
      final html = PdfText('x', underline: true).toHtml();
      expect(html, contains('text-decoration: underline'));
    });

    test('applies color', () {
      final html = PdfText('x', color: PdfColor(255, 0, 0)).toHtml();
      expect(html, contains('rgba(255,0,0,1.0)'));
    });

    test('applies text-align', () {
      final html = PdfText('x', textAlign: PdfTextAlign.center).toHtml();
      expect(html, contains('text-align: center'));
    });

    test('applies max-lines via webkit clamp', () {
      final html = PdfText('x', maxLines: 2).toHtml();
      expect(html, contains('-webkit-line-clamp: 2'));
    });

    test('escapes HTML special characters', () {
      final html = PdfText('<script>alert("xss")</script>').toHtml();
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });
  });
}
```

- [ ] **Step 2: Run tests — expect failure**

```bash
flutter test test/widgets/pdf_text_test.dart
```
Expected: FAIL — `pdf_text.dart` does not exist.

- [ ] **Step 3: Implement PdfText**

`lib/src/widgets/pdf_text.dart`:
```dart
import '../types/pdf_alignment.dart';
import '../types/pdf_color.dart';
import 'pdf_widget.dart';

class PdfText extends PdfWidget {
  final String text;
  final double fontSize;
  final bool bold;
  final bool italic;
  final bool underline;
  final PdfColor? color;
  final PdfTextAlign textAlign;
  final int? maxLines;

  const PdfText(
    this.text, {
    this.fontSize = 14,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color,
    this.textAlign = PdfTextAlign.left,
    this.maxLines,
  });

  @override
  String toHtml() {
    final styles = <String>[
      'margin: 0',
      'font-size: ${fontSize}px',
      'text-align: ${textAlign.toCss()}',
      if (color != null) 'color: ${color!.toCss()}',
      if (bold) 'font-weight: bold',
      if (italic) 'font-style: italic',
      if (underline) 'text-decoration: underline',
      if (maxLines != null) 'overflow: hidden',
      if (maxLines != null) 'display: -webkit-box',
      if (maxLines != null) '-webkit-line-clamp: $maxLines',
      if (maxLines != null) '-webkit-box-orient: vertical',
    ];
    return '<p style="${styles.join('; ')}">${_escape(text)}</p>';
  }

  String _escape(String t) => t
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
```

- [ ] **Step 4: Run PdfText tests — expect pass**

```bash
flutter test test/widgets/pdf_text_test.dart
```
Expected: All 9 tests pass.

- [ ] **Step 5: Write failing tests for PdfRichText**

`test/widgets/pdf_rich_text_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_rich_text.dart';
import 'package:flutter_pdf_builder/src/types/pdf_text_span.dart';
import 'package:flutter_pdf_builder/src/types/pdf_color.dart';

void main() {
  group('PdfRichText.toHtml', () {
    test('wraps spans inside a paragraph', () {
      final html = PdfRichText(spans: [PdfTextSpan('Hello')]).toHtml();
      expect(html, contains('<p'));
      expect(html, contains('<span'));
      expect(html, contains('Hello'));
      expect(html, contains('</p>'));
    });

    test('applies bold to a span', () {
      final html = PdfRichText(
        spans: [PdfTextSpan('Bold', bold: true)],
      ).toHtml();
      expect(html, contains('font-weight: bold'));
    });

    test('applies color to a span', () {
      final html = PdfRichText(
        spans: [PdfTextSpan('Red', color: PdfColor(255, 0, 0))],
      ).toHtml();
      expect(html, contains('rgba(255,0,0,1.0)'));
    });

    test('renders multiple spans in order', () {
      final html = PdfRichText(
        spans: [PdfTextSpan('A'), PdfTextSpan('B')],
      ).toHtml();
      expect(html.indexOf('A'), lessThan(html.indexOf('B')));
    });
  });
}
```

- [ ] **Step 6: Implement PdfRichText, PdfSizedBox, PdfDivider**

`lib/src/widgets/pdf_rich_text.dart`:
```dart
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
```

`lib/src/widgets/pdf_sized_box.dart`:
```dart
import 'pdf_widget.dart';

class PdfSizedBox extends PdfWidget {
  final double? width;
  final double? height;
  final PdfWidget? child;

  const PdfSizedBox({this.width, this.height, this.child});

  @override
  Future<void> resolve(bundle, client) async {
    await child?.resolve(bundle, client);
  }

  @override
  String toHtml() {
    final styles = <String>[
      'display: block',
      if (width != null) 'width: ${width}px',
      if (height != null) 'height: ${height}px',
    ];
    final childHtml = child?.toHtml() ?? '';
    return '<div style="${styles.join('; ')}">$childHtml</div>';
  }
}
```

`lib/src/widgets/pdf_divider.dart`:
```dart
import '../types/pdf_color.dart';
import 'pdf_widget.dart';

class PdfDivider extends PdfWidget {
  final double thickness;
  final PdfColor? color;
  final double indent;
  final double endIndent;

  const PdfDivider({
    this.thickness = 1,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  String toHtml() {
    final c = (color ?? PdfColor(238, 238, 238)).toCss();
    return '<hr style="border: none; border-top: ${thickness}px solid $c; '
        'margin-left: ${indent}px; margin-right: ${endIndent}px;" />';
  }
}
```

- [ ] **Step 7: Run all widget tests so far — expect pass**

```bash
flutter test test/widgets/
```
Expected: All tests pass.

- [ ] **Step 8: Commit**

```bash
git add lib/src/widgets/pdf_text.dart lib/src/widgets/pdf_rich_text.dart lib/src/widgets/pdf_sized_box.dart lib/src/widgets/pdf_divider.dart test/widgets/
git commit -m "feat: add PdfText, PdfRichText, PdfSizedBox, PdfDivider widgets"
```

---

## Task 5: Layout Widgets — PdfPadding, PdfRow, PdfColumn, PdfListView, PdfContainer, PdfCard

**Files:**
- Create: `lib/src/widgets/pdf_padding.dart`
- Create: `lib/src/widgets/pdf_row.dart`
- Create: `lib/src/widgets/pdf_column.dart`
- Create: `lib/src/widgets/pdf_list_view.dart`
- Create: `lib/src/widgets/pdf_container.dart`
- Create: `lib/src/widgets/pdf_card.dart`
- Test: `test/widgets/pdf_row_test.dart`
- Test: `test/widgets/pdf_column_test.dart`
- Test: `test/widgets/pdf_container_test.dart`

- [ ] **Step 1: Write failing tests for PdfRow**

`test/widgets/pdf_row_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_row.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_text.dart';
import 'package:flutter_pdf_builder/src/types/pdf_alignment.dart';

void main() {
  group('PdfRow.toHtml', () {
    test('uses flex-direction row', () {
      final html = PdfRow(children: [PdfText('a')]).toHtml();
      expect(html, contains('flex-direction: row'));
    });

    test('applies mainAxisAlignment', () {
      final html = PdfRow(
        children: [PdfText('a')],
        mainAxisAlignment: PdfMainAxisAlignment.spaceBetween,
      ).toHtml();
      expect(html, contains('justify-content: space-between'));
    });

    test('applies crossAxisAlignment', () {
      final html = PdfRow(
        children: [PdfText('a')],
        crossAxisAlignment: PdfCrossAxisAlignment.center,
      ).toHtml();
      expect(html, contains('align-items: center'));
    });

    test('applies gap', () {
      final html = PdfRow(children: [PdfText('a')], gap: 12).toHtml();
      expect(html, contains('gap: 12px'));
    });

    test('renders all children', () {
      final html = PdfRow(children: [PdfText('A'), PdfText('B')]).toHtml();
      expect(html, contains('A'));
      expect(html, contains('B'));
    });
  });
}
```

- [ ] **Step 2: Run tests — expect failure**

```bash
flutter test test/widgets/pdf_row_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Implement PdfPadding, PdfRow, PdfColumn, PdfListView, PdfContainer, PdfCard**

`lib/src/widgets/pdf_padding.dart`:
```dart
import '../types/pdf_edge_insets.dart';
import 'pdf_widget.dart';

class PdfPadding extends PdfWidget {
  final PdfEdgeInsets padding;
  final PdfWidget child;

  const PdfPadding({required this.padding, required this.child});

  @override
  Future<void> resolve(bundle, client) => child.resolve(bundle, client);

  @override
  String toHtml() =>
      '<div style="padding: ${padding.toCss()}">${child.toHtml()}</div>';
}
```

`lib/src/widgets/pdf_row.dart`:
```dart
import '../types/pdf_alignment.dart';
import 'pdf_widget.dart';

class PdfRow extends PdfWidget {
  final List<PdfWidget> children;
  final PdfMainAxisAlignment mainAxisAlignment;
  final PdfCrossAxisAlignment crossAxisAlignment;
  final double gap;

  const PdfRow({
    required this.children,
    this.mainAxisAlignment = PdfMainAxisAlignment.start,
    this.crossAxisAlignment = PdfCrossAxisAlignment.start,
    this.gap = 0,
  });

  @override
  Future<void> resolve(bundle, client) async {
    await Future.wait(children.map((c) => c.resolve(bundle, client)));
  }

  @override
  String toHtml() {
    final styles = [
      'display: flex',
      'flex-direction: row',
      'justify-content: ${mainAxisAlignment.toCss()}',
      'align-items: ${crossAxisAlignment.toCss()}',
      if (gap > 0) 'gap: ${gap}px',
    ].join('; ');
    final childrenHtml = children.map((c) => c.toHtml()).join();
    return '<div style="$styles">$childrenHtml</div>';
  }
}
```

`lib/src/widgets/pdf_column.dart`:
```dart
import '../types/pdf_alignment.dart';
import 'pdf_widget.dart';

class PdfColumn extends PdfWidget {
  final List<PdfWidget> children;
  final PdfMainAxisAlignment mainAxisAlignment;
  final PdfCrossAxisAlignment crossAxisAlignment;
  final double gap;

  const PdfColumn({
    required this.children,
    this.mainAxisAlignment = PdfMainAxisAlignment.start,
    this.crossAxisAlignment = PdfCrossAxisAlignment.stretch,
    this.gap = 0,
  });

  @override
  Future<void> resolve(bundle, client) async {
    await Future.wait(children.map((c) => c.resolve(bundle, client)));
  }

  @override
  String toHtml() {
    final styles = [
      'display: flex',
      'flex-direction: column',
      'justify-content: ${mainAxisAlignment.toCss()}',
      'align-items: ${crossAxisAlignment.toCss()}',
      if (gap > 0) 'gap: ${gap}px',
    ].join('; ');
    final childrenHtml = children.map((c) => c.toHtml()).join();
    return '<div style="$styles">$childrenHtml</div>';
  }
}
```

`lib/src/widgets/pdf_list_view.dart`:
```dart
import 'pdf_widget.dart';

class PdfListView extends PdfWidget {
  final List<PdfWidget> children;
  final double gap;

  const PdfListView({required this.children, this.gap = 0});

  @override
  Future<void> resolve(bundle, client) async {
    await Future.wait(children.map((c) => c.resolve(bundle, client)));
  }

  @override
  String toHtml() {
    final styles = [
      'display: flex',
      'flex-direction: column',
      if (gap > 0) 'gap: ${gap}px',
    ].join('; ');
    final childrenHtml = children.map((c) => c.toHtml()).join();
    return '<div style="$styles">$childrenHtml</div>';
  }
}
```

`lib/src/widgets/pdf_container.dart`:
```dart
import '../types/pdf_border.dart';
import '../types/pdf_color.dart';
import '../types/pdf_edge_insets.dart';
import 'pdf_widget.dart';

class PdfContainer extends PdfWidget {
  final double? width;
  final double? height;
  final PdfColor? color;
  final PdfEdgeInsets? padding;
  final PdfEdgeInsets? margin;
  final PdfBorder? border;
  final PdfWidget? child;

  const PdfContainer({
    this.width,
    this.height,
    this.color,
    this.padding,
    this.margin,
    this.border,
    this.child,
  });

  @override
  Future<void> resolve(bundle, client) async {
    await child?.resolve(bundle, client);
  }

  @override
  String toHtml() {
    final styles = <String>['box-sizing: border-box'];
    if (width != null) styles.add('width: ${width}px');
    if (height != null) styles.add('height: ${height}px');
    if (color != null) styles.add('background-color: ${color!.toCss()}');
    if (padding != null) styles.add('padding: ${padding!.toCss()}');
    if (margin != null) styles.add('margin: ${margin!.toCss()}');
    if (border != null) {
      styles.add('border: ${border!.toCss()}');
      if (border!.radius > 0) styles.add('border-radius: ${border!.toRadiusCss()}');
    }
    return '<div style="${styles.join('; ')}">${child?.toHtml() ?? ''}</div>';
  }
}
```

`lib/src/widgets/pdf_card.dart`:
```dart
import '../types/pdf_color.dart';
import '../types/pdf_edge_insets.dart';
import 'pdf_widget.dart';

class PdfCard extends PdfWidget {
  final PdfWidget child;
  final double elevation;
  final PdfColor color;
  final double borderRadius;
  final PdfEdgeInsets padding;

  const PdfCard({
    required this.child,
    this.elevation = 2,
    this.color = const PdfColor(255, 255, 255),
    this.borderRadius = 8,
    this.padding = const PdfEdgeInsets.all(16),
  });

  @override
  Future<void> resolve(bundle, client) => child.resolve(bundle, client);

  @override
  String toHtml() {
    final blur = elevation * 4;
    final spread = elevation;
    final shadow = '0 ${elevation * 2}px ${blur}px ${spread}px rgba(0,0,0,0.12)';
    final styles = [
      'background-color: ${color.toCss()}',
      'border-radius: ${borderRadius}px',
      'padding: ${padding.toCss()}',
      'box-shadow: $shadow',
      'box-sizing: border-box',
    ].join('; ');
    return '<div style="$styles">${child.toHtml()}</div>';
  }
}
```

- [ ] **Step 4: Run layout widget tests — expect pass**

```bash
flutter test test/widgets/pdf_row_test.dart
```
Expected: All 5 tests pass.

- [ ] **Step 5: Write and run PdfColumn and PdfContainer tests**

`test/widgets/pdf_column_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_column.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_text.dart';

void main() {
  test('PdfColumn uses flex-direction column', () {
    final html = PdfColumn(children: [PdfText('a')]).toHtml();
    expect(html, contains('flex-direction: column'));
  });

  test('PdfColumn renders all children', () {
    final html = PdfColumn(children: [PdfText('X'), PdfText('Y')]).toHtml();
    expect(html, contains('X'));
    expect(html, contains('Y'));
  });
}
```

`test/widgets/pdf_container_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_container.dart';
import 'package:flutter_pdf_builder/src/types/pdf_color.dart';
import 'package:flutter_pdf_builder/src/types/pdf_border.dart';

void main() {
  test('PdfContainer applies background color', () {
    final html = PdfContainer(color: PdfColor(255, 0, 0)).toHtml();
    expect(html, contains('rgba(255,0,0,1.0)'));
  });

  test('PdfContainer applies border and border-radius', () {
    final html = PdfContainer(
      border: PdfBorder(color: PdfColor(0, 0, 0), width: 2, radius: 10),
    ).toHtml();
    expect(html, contains('border:'));
    expect(html, contains('border-radius: 10.0px'));
  });

  test('PdfContainer applies width and height', () {
    final html = PdfContainer(width: 100, height: 50).toHtml();
    expect(html, contains('width: 100.0px'));
    expect(html, contains('height: 50.0px'));
  });
}
```

```bash
flutter test test/widgets/
```
Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/src/widgets/ test/widgets/
git commit -m "feat: add PdfPadding, PdfRow, PdfColumn, PdfListView, PdfContainer, PdfCard widgets"
```

---

## Task 6: PdfStack and PdfPositioned

**Files:**
- Create: `lib/src/widgets/pdf_stack.dart`
- Create: `lib/src/widgets/pdf_positioned.dart`
- Test: `test/widgets/pdf_stack_test.dart`

- [ ] **Step 1: Write failing test**

`test/widgets/pdf_stack_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_stack.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_positioned.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_text.dart';

void main() {
  group('PdfStack', () {
    test('stack uses position relative', () {
      final html = PdfStack(children: [
        PdfPositioned(top: 0, left: 0, child: PdfText('A')),
      ]).toHtml();
      expect(html, contains('position: relative'));
    });

    test('positioned child uses position absolute', () {
      final html = PdfPositioned(top: 10, left: 20, child: PdfText('A')).toHtml();
      expect(html, contains('position: absolute'));
      expect(html, contains('top: 10.0px'));
      expect(html, contains('left: 20.0px'));
    });

    test('renders child content inside positioned', () {
      final html = PdfStack(children: [
        PdfPositioned(top: 0, left: 0, child: PdfText('Hello')),
      ]).toHtml();
      expect(html, contains('Hello'));
    });
  });
}
```

- [ ] **Step 2: Run test — expect failure**

```bash
flutter test test/widgets/pdf_stack_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Implement PdfPositioned and PdfStack**

`lib/src/widgets/pdf_positioned.dart`:
```dart
import 'pdf_widget.dart';

class PdfPositioned extends PdfWidget {
  final PdfWidget child;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const PdfPositioned({
    required this.child,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Future<void> resolve(bundle, client) => child.resolve(bundle, client);

  @override
  String toHtml() {
    final styles = <String>['position: absolute'];
    if (top != null) styles.add('top: ${top}px');
    if (bottom != null) styles.add('bottom: ${bottom}px');
    if (left != null) styles.add('left: ${left}px');
    if (right != null) styles.add('right: ${right}px');
    return '<div style="${styles.join('; ')}">${child.toHtml()}</div>';
  }
}
```

`lib/src/widgets/pdf_stack.dart`:
```dart
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
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/widgets/pdf_stack_test.dart
```
Expected: All 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/pdf_stack.dart lib/src/widgets/pdf_positioned.dart test/widgets/pdf_stack_test.dart
git commit -m "feat: add PdfStack and PdfPositioned widgets"
```

---

## Task 7: PdfImage

**Files:**
- Create: `lib/src/widgets/pdf_image.dart`
- Test: `test/widgets/pdf_image_test.dart`

- [ ] **Step 1: Write failing tests**

`test/widgets/pdf_image_test.dart`:
```dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_image.dart';

void main() {
  group('PdfImage.memory', () {
    test('toHtml uses data URI after resolve with memory bytes', () async {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final img = PdfImage.memory(bytes, width: 100, height: 50);
      await img.resolve(rootBundle, null as dynamic);
      final html = img.toHtml();
      expect(html, contains('<img'));
      expect(html, contains('data:image/png;base64,'));
      expect(html, contains('width: 100.0px'));
      expect(html, contains('height: 50.0px'));
    });

    test('toHtml throws StateError if resolve not called', () {
      final img = PdfImage.memory(Uint8List(0), width: 10, height: 10);
      expect(() => img.toHtml(), throwsStateError);
    });
  });

  group('PdfImage.network', () {
    test('is created with a URL', () {
      final img = PdfImage.network('https://example.com/img.png', width: 50, height: 50);
      expect(img, isA<PdfImage>());
    });
  });
}
```

- [ ] **Step 2: Run tests — expect failure**

```bash
flutter test test/widgets/pdf_image_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Implement PdfImage**

`lib/src/widgets/pdf_image.dart`:
```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'pdf_widget.dart';

enum _PdfImageSource { asset, memory, network }

class PdfImage extends PdfWidget {
  final _PdfImageSource _source;
  final String? _path;
  final Uint8List? _bytes;
  final double? width;
  final double? height;

  String? _resolvedDataUri;

  PdfImage._({
    required _PdfImageSource source,
    String? path,
    Uint8List? bytes,
    this.width,
    this.height,
  })  : _source = source,
        _path = path,
        _bytes = bytes;

  factory PdfImage.asset(String path, {double? width, double? height}) =>
      PdfImage._(source: _PdfImageSource.asset, path: path, width: width, height: height);

  factory PdfImage.memory(Uint8List bytes, {double? width, double? height}) =>
      PdfImage._(source: _PdfImageSource.memory, bytes: bytes, width: width, height: height);

  factory PdfImage.network(String url, {double? width, double? height}) =>
      PdfImage._(source: _PdfImageSource.network, path: url, width: width, height: height);

  @override
  Future<void> resolve(AssetBundle bundle, http.Client client) async {
    switch (_source) {
      case _PdfImageSource.asset:
        final data = await bundle.load(_path!);
        final bytes = data.buffer.asUint8List();
        _resolvedDataUri = 'data:image/png;base64,${base64Encode(bytes)}';
      case _PdfImageSource.memory:
        _resolvedDataUri = 'data:image/png;base64,${base64Encode(_bytes!)}';
      case _PdfImageSource.network:
        final response = await client.get(Uri.parse(_path!));
        final mimeType = response.headers['content-type'] ?? 'image/png';
        _resolvedDataUri = 'data:$mimeType;base64,${base64Encode(response.bodyBytes)}';
    }
  }

  @override
  String toHtml() {
    if (_resolvedDataUri == null) {
      throw StateError('PdfImage.resolve() must be called before toHtml().');
    }
    final styles = <String>['object-fit: cover'];
    if (width != null) styles.add('width: ${width}px');
    if (height != null) styles.add('height: ${height}px');
    return '<img src="$_resolvedDataUri" style="${styles.join('; ')}" />';
  }
}
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/widgets/pdf_image_test.dart
```
Expected: Tests involving `.memory` pass. Network test verifies construction only (no real HTTP in unit tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/pdf_image.dart test/widgets/pdf_image_test.dart
git commit -m "feat: add PdfImage widget with asset, memory, and network sources"
```

---

## Task 8: PdfIcon

**Files:**
- Create: `lib/src/widgets/pdf_icon.dart`

- [ ] **Step 1: Write failing test**

`test/widgets/pdf_icon_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_icon.dart';
import 'package:flutter_pdf_builder/src/types/pdf_color.dart';

void main() {
  test('PdfIcon renders unicode codepoint as span', () {
    final html = PdfIcon(Icons.check_circle, size: 24).toHtml();
    expect(html, contains('<span'));
    expect(html, contains('font-family: Material Icons'));
    expect(html, contains('font-size: 24px'));
  });

  test('PdfIcon applies color', () {
    final html = PdfIcon(Icons.star, size: 16, color: PdfColor(255, 0, 0)).toHtml();
    expect(html, contains('rgba(255,0,0,1.0)'));
  });
}
```

- [ ] **Step 2: Run test — expect failure**

```bash
flutter test test/widgets/pdf_icon_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Implement PdfIcon**

The Material Icons font is loaded via a CDN `<link>` tag in `HtmlAssembler` (Task 10). `PdfIcon` only produces the `<span>` with the correct codepoint and font-family.

`lib/src/widgets/pdf_icon.dart`:
```dart
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
      'font-size: ${size}px',
      'font-style: normal',
      'display: inline-block',
      'line-height: 1',
      if (color != null) 'color: ${color!.toCss()}',
    ];
    return '<span style="${styles.join('; ')}">$char</span>';
  }
}
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/widgets/pdf_icon_test.dart
```
Expected: Both tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/pdf_icon.dart test/widgets/pdf_icon_test.dart
git commit -m "feat: add PdfIcon widget using Material Icons unicode codepoints"
```

---

## Task 9: PdfTable

**Files:**
- Create: `lib/src/widgets/pdf_table.dart`
- Test: `test/widgets/pdf_table_test.dart`

- [ ] **Step 1: Write failing tests**

`test/widgets/pdf_table_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_table.dart';
import 'package:flutter_pdf_builder/src/types/pdf_table_column.dart';
import 'package:flutter_pdf_builder/src/types/pdf_table_row.dart';
import 'package:flutter_pdf_builder/src/types/pdf_color.dart';
import 'package:flutter_pdf_builder/src/types/pdf_border.dart';
import 'package:flutter_pdf_builder/src/types/pdf_text_style.dart';

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
```

- [ ] **Step 2: Run tests — expect failure**

```bash
flutter test test/widgets/pdf_table_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Implement PdfTable**

`lib/src/widgets/pdf_table.dart`:
```dart
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
    final borderCss = border != null ? 'border: ${border!.toCss()}; border-collapse: collapse;' : 'border-collapse: collapse;';
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
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/widgets/pdf_table_test.dart
```
Expected: All 6 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/pdf_table.dart test/widgets/pdf_table_test.dart
git commit -m "feat: add PdfTable widget with headers, rows, alternating colors, and border"
```

---

## Task 10: HtmlAssembler

**Files:**
- Create: `lib/src/engine/html_assembler.dart`
- Test: `test/engine/html_assembler_test.dart`

- [ ] **Step 1: Write failing tests**

`test/engine/html_assembler_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pdf_builder/src/engine/html_assembler.dart';
import 'package:flutter_pdf_builder/src/document/pdf_document.dart';
import 'package:flutter_pdf_builder/src/document/pdf_page_config.dart';
import 'package:flutter_pdf_builder/src/widgets/pdf_text.dart';

void main() {
  group('HtmlAssembler.assemble', () {
    test('returns a complete HTML document string', () async {
      final doc = PdfDocument(children: [PdfText('Hello')]);
      final html = await HtmlAssembler.assemble(doc);
      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<html'));
      expect(html, contains('</html>'));
    });

    test('includes utf-8 charset meta tag', () async {
      final doc = PdfDocument(children: [PdfText('Hello')]);
      final html = await HtmlAssembler.assemble(doc);
      expect(html, contains('charset="utf-8"'));
    });

    test('wraps each child in a data-pdf-block div', () async {
      final doc = PdfDocument(
        children: [PdfText('A'), PdfText('B')],
      );
      final html = await HtmlAssembler.assemble(doc);
      expect('data-pdf-block'.allMatches(html).length, 2);
    });

    test('applies page width from PdfPageConfig', () async {
      final doc = PdfDocument(
        pageConfig: PdfPageConfig.a4Portrait(),
        children: [PdfText('x')],
      );
      final html = await HtmlAssembler.assemble(doc);
      expect(html, contains('794'));
    });

    test('includes Material Icons link for icon support', () async {
      final doc = PdfDocument(children: [PdfText('x')]);
      final html = await HtmlAssembler.assemble(doc);
      expect(html, contains('Material+Icons'));
    });
  });
}
```

- [ ] **Step 2: Run tests — expect failure**

```bash
flutter test test/engine/html_assembler_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Implement HtmlAssembler**

`lib/src/engine/html_assembler.dart`:
```dart
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../document/pdf_document.dart';

class HtmlAssembler {
  HtmlAssembler._();

  static final _httpClient = http.Client();

  /// Resolves all async assets in [doc], then builds and returns
  /// the complete HTML string ready for injection into the WebView.
  static Future<String> assemble(PdfDocument doc) async {
    // Resolve all widgets (images, etc.) concurrently
    await Future.wait(
      doc.children.map((w) => w.resolve(rootBundle, _httpClient)),
    );

    final config = doc.pageConfig;
    final margin = config.margin;

    // Each child is wrapped in a data-pdf-block div so the JS engine
    // can measure and group them into pages without splitting mid-widget.
    final blocksHtml = doc.children
        .map((w) => '<div data-pdf-block="true">${w.toHtml()}</div>')
        .join('\n');

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <style>
    * { box-sizing: border-box; font-family: sans-serif; }
    body { margin: 0; padding: 0; background: #fff; }
    #content {
      width: ${config.widthPx}px;
      padding: ${margin.toCss()};
    }
  </style>
</head>
<body>
  <div id="content">
$blocksHtml
  </div>
  <script>
    // Signals to PdfEngine that the page is ready for JS injection.
    window.addEventListener('load', () => Ready.postMessage('ready'));
  </script>
</body>
</html>''';
  }
}
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/engine/html_assembler_test.dart
```
Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/engine/html_assembler.dart test/engine/html_assembler_test.dart
git commit -m "feat: add HtmlAssembler — resolves assets and builds full HTML page string"
```

---

## Task 11: JavaScript Engine — Measure-Then-Render-Per-Page

**Files:**
- Create: `assets/pdf_engine/index.html`

This is the core JS engine. It runs entirely inside the WebView. Tests are manual (run via the test app in Task 15).

- [ ] **Step 1: Create the JavaScript engine**

`assets/pdf_engine/index.html`:
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <script src="js/html2canvas.min.js"></script>
  <script src="js/jspdf.umd.min.js"></script>
  <style>
    body { margin: 0; padding: 0; background: #fff; }
    #content { background: #fff; }
    #staging {
      position: absolute;
      left: -99999px;
      top: 0;
      background: #fff;
      overflow: hidden;
    }
  </style>
</head>
<body>
  <div id="content"></div>
  <div id="staging"></div>

  <script>
    // Called by HtmlAssembler output via runJavaScript.
    // html: full inner HTML of #content (includes data-pdf-block divs)
    // pageWidthPx: from PdfPageConfig.widthPx
    // pageHeightPx: from PdfPageConfig.heightPx
    // marginTop, marginRight, marginBottom, marginLeft: from PdfPageConfig.margin
    async function generatePdf(html, pageWidthPx, pageHeightPx, marginTop, marginRight, marginBottom, marginLeft) {
      try {
        // Inject HTML
        const content = document.getElementById('content');
        content.style.width = pageWidthPx + 'px';
        content.innerHTML = html;

        // Wait for images/fonts to load
        await new Promise(r => setTimeout(r, 600));

        // === PASS 1: MEASURE ===
        const blocks = Array.from(content.querySelectorAll('[data-pdf-block]'));
        if (blocks.length === 0) {
          Error.postMessage('No blocks found in document.');
          return;
        }
        const blockHeights = blocks.map(b => b.getBoundingClientRect().height);

        // === PASS 2: GROUP INTO PAGES ===
        const usableHeight = pageHeightPx - marginTop - marginBottom;
        const pages = [];
        let currentPageBlocks = [];
        let currentHeight = 0;

        for (let i = 0; i < blocks.length; i++) {
          const h = blockHeights[i];
          // If this block alone exceeds a full page, it still goes on its own page.
          if (currentHeight + h > usableHeight && currentPageBlocks.length > 0) {
            pages.push(currentPageBlocks);
            currentPageBlocks = [];
            currentHeight = 0;
          }
          currentPageBlocks.push(blocks[i]);
          currentHeight += h;
        }
        if (currentPageBlocks.length > 0) pages.push(currentPageBlocks);

        const totalPages = pages.length;

        // === PASS 3: RENDER PER PAGE ===
        const { jsPDF } = window.jspdf;
        const pdf = new jsPDF({
          orientation: pageWidthPx > pageHeightPx ? 'l' : 'p',
          unit: 'pt',
          format: 'a4',
          compress: true
        });

        const pageWidthPt = pdf.internal.pageSize.getWidth();
        const pageHeightPt = pdf.internal.pageSize.getHeight();
        const marginLeftPt = (marginLeft * 72) / 96;
        const marginTopPt = (marginTop * 72) / 96;
        const usableWidthPt = pageWidthPt - (marginLeft * 72 / 96) - (marginRight * 72 / 96);

        const staging = document.getElementById('staging');
        staging.style.width = pageWidthPx + 'px';

        for (let p = 0; p < pages.length; p++) {
          // Clone page blocks into staging area
          staging.innerHTML = '';
          staging.style.padding = `${marginTop}px ${marginRight}px ${marginBottom}px ${marginLeft}px`;
          pages[p].forEach(block => staging.appendChild(block.cloneNode(true)));

          // Capture
          const canvas = await html2canvas(staging, {
            scale: 2,
            useCORS: true,
            backgroundColor: '#ffffff',
            width: pageWidthPx,
          });

          const imgData = canvas.toDataURL('image/jpeg', 0.92);
          const sliceHeightPt = (canvas.height * usableWidthPt) / canvas.width;

          if (p > 0) pdf.addPage();
          pdf.setFillColor(255, 255, 255);
          pdf.rect(0, 0, pageWidthPt, pageHeightPt, 'F');
          pdf.addImage(imgData, 'JPEG', marginLeftPt, marginTopPt, usableWidthPt, sliceHeightPt);

          // Report progress
          Progress.postMessage(JSON.stringify({ current: p + 1, total: totalPages }));
        }

        staging.innerHTML = '';

        // Encode to base64
        const buffer = pdf.output('arraybuffer');
        const uint8Array = new Uint8Array(buffer);
        let binary = '';
        for (let i = 0; i < uint8Array.length; i++) {
          binary += String.fromCharCode(uint8Array[i]);
        }
        Callback.postMessage(btoa(binary));

      } catch (e) {
        Error.postMessage(e.toString());
      }
    }

    window.addEventListener('load', () => Ready.postMessage('ready'));
  </script>
</body>
</html>
```

- [ ] **Step 2: Verify the asset is registered**

```bash
cat pubspec.yaml | grep pdf_engine
```
Expected: `- packages/flutter_pdf_builder/assets/pdf_engine/index.html` is listed.

- [ ] **Step 3: Commit**

```bash
git add assets/pdf_engine/index.html
git commit -m "feat: add measure-then-render-per-page JavaScript engine"
```

---

## Task 12: PdfEngine — Internal WebView Lifecycle

**Files:**
- Create: `lib/src/engine/pdf_engine.dart`

The `PdfEngine` is internal and not exported. It is managed by `PdfGeneratorScope`.

- [ ] **Step 1: Implement PdfEngine**

`lib/src/engine/pdf_engine.dart`:
```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef PdfSuccessCallback = void Function(File file);
typedef PdfErrorCallback = void Function(Object error);
typedef PdfProgressCallback = void Function(int page, int total);

class PdfEngine {
  late final WebViewController controller;

  PdfSuccessCallback? _onSuccess;
  PdfErrorCallback? _onError;
  PdfProgressCallback? _onProgress;
  String _fileName = 'document';

  Timer? _timeoutTimer;
  bool _callbackFired = false;

  PdfEngine() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Ready',
        onMessageReceived: (_) {
          // Engine loaded — nothing to do, generation is demand-driven.
        },
      )
      ..addJavaScriptChannel(
        'Callback',
        onMessageReceived: (JavaScriptMessage msg) {
          _settle(() => _handleSuccess(msg.message));
        },
      )
      ..addJavaScriptChannel(
        'Error',
        onMessageReceived: (JavaScriptMessage msg) {
          _settle(() => _onError?.call(msg.message));
        },
      )
      ..addJavaScriptChannel(
        'Progress',
        onMessageReceived: (JavaScriptMessage msg) {
          final data = jsonDecode(msg.message) as Map<String, dynamic>;
          _onProgress?.call(data['current'] as int, data['total'] as int);
        },
      )
      ..loadFlutterAsset(
        'packages/flutter_pdf_builder/assets/pdf_engine/index.html',
      );
  }

  /// Injects the assembled HTML into the engine and starts generation.
  /// [innerHtml] is the content of #content (the data-pdf-block divs).
  Future<void> generate({
    required String innerHtml,
    required double pageWidthPx,
    required double pageHeightPx,
    required double marginTop,
    required double marginRight,
    required double marginBottom,
    required double marginLeft,
    required String fileName,
    required PdfSuccessCallback onSuccess,
    required PdfErrorCallback onError,
    PdfProgressCallback? onProgress,
  }) async {
    _callbackFired = false;
    _onSuccess = onSuccess;
    _onError = onError;
    _onProgress = onProgress;
    _fileName = fileName;

    // 30 second timeout — replaces the old blind 5-second delay
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      _settle(() => _onError?.call('PDF generation timed out after 30 seconds.'));
    });

    // Escape the HTML for safe injection into a JS string literal
    final escaped = innerHtml
        .replaceAll('\\', '\\\\')
        .replaceAll('`', '\\`')
        .replaceAll('\$', '\\\$');

    await controller.runJavaScript(
      'generatePdf(`$escaped`, $pageWidthPx, $pageHeightPx, '
      '$marginTop, $marginRight, $marginBottom, $marginLeft)',
    );
  }

  Future<void> _handleSuccess(String base64Pdf) async {
    try {
      final bytes = base64Decode(base64Pdf);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$_fileName.pdf');
      await file.writeAsBytes(bytes);
      _onSuccess?.call(file);
    } catch (e) {
      _onError?.call(e);
    }
  }

  void _settle(void Function() action) {
    if (_callbackFired) return;
    _callbackFired = true;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    action();
  }

  void dispose() {
    _timeoutTimer?.cancel();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/engine/pdf_engine.dart
git commit -m "feat: add PdfEngine — WebView lifecycle, JS channels, 30s timeout"
```

---

## Task 13: PdfGeneratorScope and PdfGenerator

**Files:**
- Create: `lib/src/generator/pdf_generator.dart`

- [ ] **Step 1: Implement PdfGeneratorScope and PdfGenerator**

`lib/src/generator/pdf_generator.dart`:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../document/pdf_document.dart';
import '../engine/html_assembler.dart';
import '../engine/pdf_engine.dart';

/// Wrap your app or screen with [PdfGeneratorScope] once.
/// It mounts the hidden WebView needed for PDF generation.
///
/// ```dart
/// PdfGeneratorScope(
///   child: MyApp(),
/// )
/// ```
class PdfGeneratorScope extends StatefulWidget {
  final Widget child;
  const PdfGeneratorScope({required this.child, super.key});

  @override
  State<PdfGeneratorScope> createState() => _PdfGeneratorScopeState();
}

class _PdfGeneratorScopeState extends State<PdfGeneratorScope> {
  late final PdfEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = PdfEngine();
    PdfGenerator._engine = _engine;
  }

  @override
  void dispose() {
    _engine.dispose();
    PdfGenerator._engine = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Hidden 1x1 pixel WebView — must be in the widget tree for JS to execute.
        Positioned(
          left: -1,
          top: -1,
          width: 1,
          height: 1,
          child: WebViewWidget(controller: _engine.controller),
        ),
      ],
    );
  }
}

/// Generates PDFs from a [PdfDocument].
///
/// Requires [PdfGeneratorScope] to be present in the widget tree above
/// the call site before [generate] is called.
class PdfGenerator {
  PdfGenerator._();

  static PdfEngine? _engine;

  /// Generates a PDF from [document] and delivers the result via callbacks.
  ///
  /// [fileName] is the base name of the output file (no `.pdf` extension needed).
  /// [onSuccess] is called with the written [File] on success.
  /// [onError] is called with an error description on failure.
  /// [onProgress] is optional — called after each page is rendered.
  static void generate({
    required PdfDocument document,
    String fileName = 'document',
    required void Function(File file) onSuccess,
    required void Function(Object error) onError,
    void Function(int page, int total)? onProgress,
  }) {
    assert(
      _engine != null,
      'PdfGeneratorScope must be present in the widget tree before calling PdfGenerator.generate().',
    );

    if (document.children.isEmpty) {
      onError('Document has no content.');
      return;
    }

    final config = document.pageConfig;
    final margin = config.margin;

    HtmlAssembler.assemble(document).then((fullHtml) {
      // Extract only the inner blocks HTML for the engine.
      // The engine's index.html provides the outer shell;
      // we inject the data-pdf-block divs via generatePdf().
      final innerHtml = _extractInnerHtml(fullHtml);

      _engine!.generate(
        innerHtml: innerHtml,
        pageWidthPx: config.widthPx,
        pageHeightPx: config.heightPx,
        marginTop: margin.top,
        marginRight: margin.right,
        marginBottom: margin.bottom,
        marginLeft: margin.left,
        fileName: fileName,
        onSuccess: onSuccess,
        onError: onError,
        onProgress: onProgress,
      );
    }).catchError((Object e) => onError(e));
  }

  /// Extracts the content inside <div id="content">...</div>
  static String _extractInnerHtml(String fullHtml) {
    final start = fullHtml.indexOf('<div id="content">');
    final end = fullHtml.lastIndexOf('</div>');
    if (start == -1 || end == -1) return fullHtml;
    final openTagEnd = fullHtml.indexOf('>', start) + 1;
    return fullHtml.substring(openTagEnd, end).trim();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/generator/pdf_generator.dart
git commit -m "feat: add PdfGeneratorScope widget and PdfGenerator static API"
```

---

## Task 14: PdfPreviewWidget

**Files:**
- Create: `lib/src/preview/pdf_preview_widget.dart`

- [ ] **Step 1: Implement PdfPreviewWidget**

`lib/src/preview/pdf_preview_widget.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../document/pdf_document.dart';
import '../engine/html_assembler.dart';

/// Renders a visual preview of [document] in a WebView.
///
/// This does NOT generate a PDF — it renders the same HTML that will be used
/// for generation, so the developer sees an accurate representation of the output.
///
/// The generate button (if needed) is the caller's responsibility:
/// ```dart
/// Column(children: [
///   Expanded(child: PdfPreviewWidget(document: doc)),
///   ElevatedButton(onPressed: () => PdfGenerator.generate(...), child: Text('Export PDF')),
/// ])
/// ```
class PdfPreviewWidget extends StatefulWidget {
  final PdfDocument document;
  final Widget? loadingWidget;

  const PdfPreviewWidget({
    required this.document,
    this.loadingWidget,
    super.key,
  });

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ));
    _loadPreview();
  }

  @override
  void didUpdateWidget(PdfPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) _loadPreview();
  }

  Future<void> _loadPreview() async {
    if (mounted) setState(() => _loading = true);
    final html = await HtmlAssembler.assemble(widget.document);
    _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          Center(
            child: widget.loadingWidget ?? const CircularProgressIndicator(),
          ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/preview/pdf_preview_widget.dart
git commit -m "feat: add PdfPreviewWidget — HTML-based preview with no PDF generation"
```

---

## Task 15: Barrel Export and pub.dev README

**Files:**
- Modify: `lib/flutter_pdf_builder.dart`
- Modify: `README.md`

- [ ] **Step 1: Write the barrel export**

`lib/flutter_pdf_builder.dart`:
```dart
library flutter_pdf_builder;

// Document model
export 'src/document/pdf_document.dart';
export 'src/document/pdf_page_config.dart';

// Types
export 'src/types/pdf_color.dart';
export 'src/types/pdf_edge_insets.dart';
export 'src/types/pdf_border.dart';
export 'src/types/pdf_text_style.dart';
export 'src/types/pdf_text_span.dart';
export 'src/types/pdf_alignment.dart';
export 'src/types/pdf_table_column.dart';
export 'src/types/pdf_table_row.dart';

// Widgets
export 'src/widgets/pdf_widget.dart';
export 'src/widgets/pdf_text.dart';
export 'src/widgets/pdf_rich_text.dart';
export 'src/widgets/pdf_sized_box.dart';
export 'src/widgets/pdf_divider.dart';
export 'src/widgets/pdf_padding.dart';
export 'src/widgets/pdf_row.dart';
export 'src/widgets/pdf_column.dart';
export 'src/widgets/pdf_list_view.dart';
export 'src/widgets/pdf_container.dart';
export 'src/widgets/pdf_card.dart';
export 'src/widgets/pdf_stack.dart';
export 'src/widgets/pdf_positioned.dart';
export 'src/widgets/pdf_image.dart';
export 'src/widgets/pdf_icon.dart';
export 'src/widgets/pdf_table.dart';

// Generator
export 'src/generator/pdf_generator.dart';

// Preview
export 'src/preview/pdf_preview_widget.dart';
```

- [ ] **Step 2: Run the full test suite**

```bash
flutter test
```
Expected: All tests pass with 0 failures.

- [ ] **Step 3: Run flutter analyze**

```bash
flutter analyze
```
Expected: No issues found.

- [ ] **Step 4: Final commit**

```bash
git add lib/flutter_pdf_builder.dart
git commit -m "feat: add barrel export — package public API complete"
```

---

## Self-Review Checklist

**Spec coverage:**
- [x] Zero state manager dependency — `PdfGeneratorScope` + static `PdfGenerator`, no Riverpod/BLoC
- [x] Flutter-inspired DSL — all 14 widget types implemented
- [x] Semantic pagination — measure-then-render-per-page in Task 11 + Task 12
- [x] Optional preview — `PdfPreviewWidget` in Task 14, caller provides generate button
- [x] Multi-language — html2canvas pipeline preserved
- [x] Callback API — `onSuccess`, `onError`, `onProgress` in `PdfGenerator.generate`
- [x] 30-second timeout replacing the blind 5-second delay
- [x] All supporting types — `PdfColor`, `PdfEdgeInsets`, `PdfBorder`, `PdfTextStyle`, `PdfTextSpan`, enums, `PdfTableColumn`, `PdfTableRow`
- [x] `PdfImage` — `.asset()`, `.memory()`, `.network()`
- [x] `PdfIcon` — Unicode codepoint + Material Icons CDN
- [x] `PdfTable` — headers, rows, alternating colors, highlight rows, border
- [x] Known limitations — documented in spec, to be added to pub.dev README
- [x] `pubspec.yaml` — only `webview_flutter`, `path_provider`, `http` as runtime deps

**No placeholders:** All code steps contain complete, runnable code.

**Type consistency:**
- `PdfEngine.generate()` parameters match what `PdfGenerator.generate()` passes
- `HtmlAssembler.assemble()` returns `Future<String>` — used correctly in `PdfGenerator` and `PdfPreviewWidget`
- `PdfWidget.resolve(AssetBundle, http.Client)` signature used consistently across all widgets
- `data-pdf-block` attribute used in both `HtmlAssembler` (Task 10) and the JS engine `querySelectorAll` (Task 11)
