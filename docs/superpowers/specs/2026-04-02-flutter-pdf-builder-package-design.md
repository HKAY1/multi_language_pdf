# Flutter PDF Builder — Package Design Spec
**Date:** 2026-04-02  
**Status:** Approved  

---

## Problem Statement

The existing `PdfGeneratorProvider` in the sachiv app solves a real problem: generating PDFs that correctly render multiple languages simultaneously. Native Flutter PDF libraries (pdf/printing) require per-language font embedding and fail on mixed-script documents. The WebView + html2canvas approach delegates text rendering to the browser engine, which handles Unicode and multi-language content natively.

However, the current service has three significant limitations:
1. Tightly coupled to Riverpod — unusable in apps with other state managers
2. Requires developers to write raw HTML templates — high barrier for Flutter developers
3. Pagination is image-based (geometric canvas slicing) — rows can be cut mid-element across page boundaries

This package extracts and generalises the service into a pub.dev-publishable package that solves all three problems.

---

## Goals

1. **Zero state manager dependency** — pure callback-based API, no Riverpod/BLoC/GetX coupling
2. **Flutter-inspired DSL** — developers build PDF layouts using Flutter-like widget classes; HTML is an internal implementation detail
3. **Semantic pagination** — measure actual rendered element heights in JS before splitting into pages; no mid-row cuts
4. **Optional preview** — a `PdfPreviewWidget` (WebView wrapper) the developer can embed anywhere; generate button is the developer's responsibility
5. **Multi-language support preserved** — html2canvas rendering pipeline is kept intact

## Non-Goals

- Hyperlinks / clickable URLs in the PDF (unsupported by the image-based pipeline; documented limitation)
- Selectable text in the PDF (same reason)
- Non-A4 page sizes in v1 (configurable in `PdfPageConfig` but only A4 Portrait/Landscape supported initially)

---

## Architecture

### Layer Diagram

```
Developer Code
    │  PdfDocument (DSL widget tree)
    ▼
PdfGenerator.generate(document, onSuccess, onError, onProgress)
    │
    ▼
PdfEngine (internal)
    │  Creates WebViewController + mounts invisible WebViewWidget
    │  via an OverlayEntry (0x0 size, off-screen) so JS executes reliably
    │  Loads bundled index.html
    │  Serialises PdfDocument → HTML string
    │  Injects HTML via runJavaScript
    │
    ▼
WebView (html2canvas + jsPDF)
    │  Pass 1: measure each child element height
    │  Pass 2: group children into A4 pages by accumulated height
    │  Pass 3: render each page group as separate canvas
    │  Pass 4: encode each canvas page into jsPDF → base64
    │
    ▼
Callback channel → Dart → write temp File → onSuccess(File)

───────────────────────────────────────────────────────────
Preview path (independent):

PdfPreviewWidget(document: doc)
    │  Creates its own WebViewController
    │  Serialises PdfDocument → HTML string
    │  Loads preview HTML (no PDF generation)
    │  Developer provides generate button
```

### Package Structure

```
flutter_pdf_builder/
├── lib/
│   ├── flutter_pdf_builder.dart          # barrel export
│   └── src/
│       ├── document/
│       │   ├── pdf_document.dart         # root document model
│       │   └── pdf_page_config.dart      # page size, orientation, margins
│       ├── widgets/
│       │   ├── pdf_widget.dart           # abstract base — toHtml() → String
│       │   ├── pdf_text.dart
│       │   ├── pdf_rich_text.dart
│       │   ├── pdf_row.dart
│       │   ├── pdf_column.dart
│       │   ├── pdf_container.dart
│       │   ├── pdf_card.dart
│       │   ├── pdf_padding.dart
│       │   ├── pdf_sized_box.dart
│       │   ├── pdf_divider.dart
│       │   ├── pdf_list_view.dart
│       │   ├── pdf_stack.dart
│       │   ├── pdf_positioned.dart       # used as children of PdfStack
│       │   ├── pdf_image.dart
│       │   ├── pdf_icon.dart
│       │   └── pdf_table.dart
│       ├── types/
│       │   ├── pdf_color.dart
│       │   ├── pdf_edge_insets.dart
│       │   ├── pdf_border.dart
│       │   ├── pdf_text_style.dart
│       │   ├── pdf_text_span.dart
│       │   ├── pdf_alignment.dart        # enum: start, center, end, spaceBetween, spaceAround
│       │   ├── pdf_table_column.dart
│       │   └── pdf_table_row.dart
│       ├── generator/
│       │   └── pdf_generator.dart        # static API
│       ├── preview/
│       │   └── pdf_preview_widget.dart   # StatefulWidget wrapping WebView
│       └── engine/
│           ├── pdf_engine.dart           # internal WebView lifecycle + JS bridge
│           └── html_assembler.dart       # wraps widget HTML in full page HTML shell
├── assets/
│   └── pdf_engine/
│       ├── index.html                    # updated engine with measure-then-render
│       └── js/
│           ├── html2canvas.min.js
│           └── jspdf.umd.min.js
└── pubspec.yaml
```

---

## Public API

### Document Model

```dart
final doc = PdfDocument(
  pageConfig: PdfPageConfig.a4Portrait(margin: PdfEdgeInsets.all(30)),
  children: [
    PdfText('Sales Report', fontSize: 24, bold: true),
    PdfSizedBox(height: 16),
    PdfDivider(),
    PdfTable(
      columns: [
        PdfTableColumn(label: 'Name', flex: 2),
        PdfTableColumn(label: 'Amount', flex: 1),
      ],
      rows: [
        PdfTableRow(cells: ['Alice', '₹500']),
        PdfTableRow(cells: ['Bob', '₹320']),
      ],
    ),
  ],
);
```

### Generation API

```dart
PdfGenerator.generate(
  document: doc,
  fileName: 'sales_report',           // optional, defaults to 'document'
  onSuccess: (File file) {
    Share.shareXFiles([XFile(file.path)]);
  },
  onError: (Object error) {
    showSnackBar('Failed: $error');
  },
  onProgress: (int page, int total) { // optional
    print('Rendered page $page of $total');
  },
);
```

### Preview Widget

```dart
Scaffold(
  body: Column(
    children: [
      Expanded(child: PdfPreviewWidget(document: doc)),
      ElevatedButton(
        onPressed: () => PdfGenerator.generate(document: doc, ...),
        child: Text('Generate PDF'),
      ),
    ],
  ),
);
```

---

## Widget Specifications

### PdfText
```dart
PdfText(
  'Hello world',
  fontSize: 16,
  bold: false,
  italic: false,
  underline: false,
  color: PdfColor.fromHex('#333333'),
  textAlign: PdfTextAlign.left,
  maxLines: null,               // null = unlimited
)
```
Serialises to: `<p style="font-size:16px; color:#333333; ...">Hello world</p>`

### PdfRichText
```dart
PdfRichText(spans: [
  PdfTextSpan('Total: ', bold: true),
  PdfTextSpan('₹1,200', color: PdfColor.fromHex('#2196F3'), bold: true, fontSize: 18),
])
```
Serialises to: `<p><span style="...">Total: </span><span style="...">₹1,200</span></p>`

### PdfRow / PdfColumn
```dart
PdfRow(
  children: [...],
  mainAxisAlignment: PdfMainAxisAlignment.spaceBetween,
  crossAxisAlignment: PdfCrossAxisAlignment.center,
  gap: 8,
)
```
Row → `display:flex; flex-direction:row`
Column → `display:flex; flex-direction:column`

### PdfContainer
```dart
PdfContainer(
  width: 200,
  height: null,                 // null = wrap content
  color: PdfColor.fromHex('#F5F5F5'),
  padding: PdfEdgeInsets.all(12),
  margin: PdfEdgeInsets.only(bottom: 8),
  border: PdfBorder(color: PdfColor.fromHex('#DDDDDD'), width: 1, radius: 8),
  child: PdfText('inside'),
)
```

### PdfCard
Thin wrapper over `PdfContainer` with a default box-shadow:
```dart
PdfCard(
  child: PdfText('Card content'),
  elevation: 2,                 // maps to box-shadow intensity
  color: PdfColor(255, 255, 255),
  borderRadius: 8,
  padding: PdfEdgeInsets.all(16),
)
```

### PdfImage
Three named constructors — all paths are resolved to base64 data URIs before injection:
```dart
PdfImage.asset('assets/logo.png', width: 100, height: 50)
PdfImage.memory(uint8ListBytes, width: 100, height: 50)
PdfImage.network('https://...', width: 100, height: 50)  // awaited at generation time
```
Serialises to: `<img src="data:image/png;base64,..." style="width:100px; height:50px;" />`

### PdfIcon
```dart
PdfIcon(Icons.check_circle, size: 24, color: PdfColor.fromHex('#4CAF50'))
```
Serialises to a `<span>` with the Unicode codepoint from `IconData.codePoint` and Material Symbols font loaded inline via base64 in the HTML shell.

### PdfTable
```dart
PdfTable(
  columns: [
    PdfTableColumn(label: 'Name', flex: 2, textAlign: PdfTextAlign.left),
    PdfTableColumn(label: 'Amount', flex: 1, textAlign: PdfTextAlign.right),
  ],
  rows: [
    PdfTableRow(cells: ['Alice', '₹500']),
    PdfTableRow(cells: ['Bob', '₹320'], highlight: true),
  ],
  headerStyle: PdfTextStyle(bold: true, color: PdfColor(255,255,255)),
  headerBackground: PdfColor.fromHex('#2196F3'),
  rowAlternateColor: PdfColor.fromHex('#F9F9F9'),
  border: PdfBorder(width: 1, color: PdfColor.fromHex('#DDDDDD')),
)
```

### PdfStack / PdfPositioned
```dart
PdfStack(children: [
  PdfPositioned(top: 0, left: 0, child: PdfImage.asset('assets/watermark.png')),
  PdfPositioned(top: 20, left: 20, child: PdfText('Content')),
])
```
Stack → `position:relative`. Each PdfPositioned child → `position:absolute`.

### PdfListView
Equivalent to a `PdfColumn` with uniform gap — provided for developer familiarity:
```dart
PdfListView(children: [...], gap: 8)
```

### PdfPadding / PdfSizedBox / PdfDivider
```dart
PdfPadding(padding: PdfEdgeInsets.symmetric(horizontal: 16), child: PdfText('x'))
PdfSizedBox(width: 200, height: 50)
PdfDivider(thickness: 1, color: PdfColor.fromHex('#EEEEEE'), indent: 16, endIndent: 16)
```

---

## Pagination — Measure-Then-Render-Per-Page

The updated JavaScript engine in `index.html` operates in three passes:

**Pass 1 — Measure**
Each direct child of `#content` is given a `data-pdf-block` attribute. After all children are injected, JS calls `getBoundingClientRect()` on each block to get its true rendered height (accounts for text wrapping, images, etc.).

**Pass 2 — Group into pages**
JS accumulates block heights. When adding the next block would exceed the usable page height (A4 height minus margins), it starts a new page group. Blocks are never split — a block that doesn't fit on the current page moves entirely to the next page.

**Pass 3 — Render per page**
For each page group: clone the blocks into a temporary off-screen container sized exactly to one A4 page, call `html2canvas` on it, add the resulting canvas as a page in jsPDF. The temporary container is removed after capture.

This eliminates geometric mid-row cuts. The smallest unsplittable unit is one direct child of `#content`. For the DSL, each top-level widget in `PdfDocument.children` is one block.

**`onProgress` callback** fires after each page group is captured, reporting `(currentPage, totalPages)`.

---

## Supporting Types

```dart
// Colors
PdfColor(int r, int g, int b, {double a = 1.0})
PdfColor.fromHex(String hex)
PdfColor.transparent

// Spacing
PdfEdgeInsets.all(double value)
PdfEdgeInsets.symmetric({double horizontal, double vertical})
PdfEdgeInsets.only({double left, double top, double right, double bottom})

// Border
PdfBorder({PdfColor color, double width, double radius})

// Text style (used in PdfTable headers)
PdfTextStyle({bool bold, bool italic, double fontSize, PdfColor color})

// Alignment enums
enum PdfMainAxisAlignment { start, center, end, spaceBetween, spaceAround }
enum PdfCrossAxisAlignment { start, center, end, stretch }
enum PdfTextAlign { left, center, right, justify }
```

---

## Internal: HTML Assembler

`HtmlAssembler.assemble(PdfDocument doc) → String` builds the full HTML page string:

```html
<html>
<head>
  <meta charset="utf-8"/>
  <style>
    /* A4 width, box model, base font */
    /* Material Icons font embedded as base64 */
  </style>
  <script src="js/html2canvas.min.js"></script>
  <script src="js/jspdf.umd.min.js"></script>
</head>
<body>
  <div id="content" style="width:794px; padding:[PdfPageConfig.margin values as top/right/bottom/left px]; box-sizing:border-box;">
    <!-- each PdfWidget.toHtml() output wrapped in data-pdf-block div -->
    <div data-pdf-block="true">[widget html]</div>
    ...
  </div>
  <script>/* measure-then-render engine */</script>
</body>
</html>
```

---

## Error Handling

- `onError` is always called instead of throwing, so developers don't need try/catch
- Empty document (`children` is empty) → `onError('Document has no content')`
- Network image fetch failure → that image renders as a broken-image placeholder, generation continues
- JS error inside the engine → caught and sent back via `Error` JS channel → `onError`
- Generation timeout (30 seconds) → `onError('PDF generation timed out')` — replaces the current blind 5-second delay
- `onSuccess` and `onError` are guaranteed to be called exactly once

---

## Known Limitations (to document on pub.dev)

1. **No hyperlinks** — HTML `<a>` tags are rasterised to pixels; URLs are not clickable in the output PDF
2. **No selectable text** — PDF content is image-based; text cannot be selected or searched
3. **Requires WebView** — adds `webview_flutter` as a dependency; not suitable for Flutter Web or environments without WebView support
4. **Minimum unsplittable unit is one top-level child** — a single very tall widget (e.g., a massive `PdfTable`) will still be cut if it exceeds one full page height. Developers should split very large tables across multiple `PdfDocument.children` entries to control pagination.
5. **Network images require internet at generation time**

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.0.0
  path_provider: ^2.0.0
  http: ^1.0.0             # for PdfImage.network fetch

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

No state management dependency of any kind.
