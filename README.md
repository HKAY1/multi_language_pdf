# multi_language_pdf

A Flutter package for generating multi-language PDFs using a Flutter-inspired widget DSL. Renders content through a hidden WebView (html2canvas + jsPDF), so the browser engine handles all Unicode scripts natively — no per-language font embedding required.

---

## Why this package?

Native Flutter PDF libraries (like `pdf`/`printing`) require you to embed a separate font file for every script you want to render. A document mixing English, Hindi, Russian, Japanese, and Chinese needs five different fonts, manual glyph mapping, and complex layout code.

`multi_language_pdf` sidesteps this entirely: it serialises your widget tree to HTML, renders it in a hidden WebView, and captures each page with `html2canvas`. The browser handles every Unicode script — your code stays the same regardless of language.

| | Native Flutter PDF | multi_language_pdf |
|---|---|---|
| Multi-language in one document | Manual font embedding per script | Works out of the box |
| Layout API | Low-level drawing primitives | Flutter-like widget DSL |
| State manager required | Depends on implementation | None — pure callbacks |
| Pagination | Manual | Automatic (semantic, no mid-row cuts) |
| Preview widget | Not included | `PdfPreviewWidget` included |

---

## Features

- **Flutter-inspired DSL** — compose PDFs with `PdfText`, `PdfRow`, `PdfColumn`, `PdfTable`, `PdfCard`, `PdfStack`, `PdfImage`, `PdfIcon`, and more
- **Zero state manager dependency** — pure callback API (`onSuccess`, `onError`, `onProgress`), no Riverpod/BLoC/GetX
- **Semantic pagination** — JS engine measures actual rendered element heights before splitting pages; no mid-element cuts
- **Multi-language** — the browser engine renders Latin, Devanagari, Cyrillic, CJK, Arabic, and every other Unicode script in the same document
- **Three image sources** — `PdfImage.asset()`, `PdfImage.memory()`, `PdfImage.network()`
- **Optional preview** — embed `PdfPreviewWidget` anywhere; you provide the generate button
- **30-second timeout** — replaces blind delays; fires `onError` cleanly if generation stalls

---

## Installation

```yaml
dependencies:
  multi_language_pdf: ^0.1.0
```

---

## Quick start

### 1. Wrap your screen with `PdfGeneratorScope`

`PdfGeneratorScope` mounts a hidden 1×1 WebView. It must be inside `MaterialApp` (not above it — it needs a `Directionality` ancestor).

```dart
MaterialApp(
  home: PdfGeneratorScope(
    child: MyHomeScreen(),
  ),
)
```

### 2. Build a document

```dart
final doc = PdfDocument(
  pageConfig: PdfPageConfig.a4Portrait(
    margin: PdfEdgeInsets.all(30),
  ),
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

### 3. Generate

```dart
PdfGenerator.generate(
  document: doc,
  fileName: 'sales_report',
  onSuccess: (File file) {
    Share.shareXFiles([XFile(file.path)]);
  },
  onError: (Object error) {
    showSnackBar('Failed: $error');
  },
  onProgress: (int page, int total) {
    print('Rendered page $page of $total');
  },
);
```

### 4. Preview (optional)

```dart
Column(
  children: [
    Expanded(child: PdfPreviewWidget(document: doc)),
    ElevatedButton(
      onPressed: () => PdfGenerator.generate(document: doc, ...),
      child: Text('Export PDF'),
    ),
  ],
)
```

---

## Widget Reference

### Layout

#### `PdfDocument`

Root of every PDF. Holds a list of top-level widgets and a page configuration.

```dart
PdfDocument({
  required List<PdfWidget> children,
  PdfPageConfig? pageConfig,   // defaults to A4 portrait, 30px margin
})
```

Each direct child is one "block" — the smallest unit the pagination engine will not split across pages. For very tall content (e.g. a huge table), split it into multiple children to control page breaks.

#### `PdfPageConfig`

```dart
PdfPageConfig.a4Portrait(margin: PdfEdgeInsets.all(30))
PdfPageConfig.a4Landscape(margin: PdfEdgeInsets.all(30))

// Or manual:
PdfPageConfig(
  orientation: PdfPageOrientation.portrait,  // or .landscape
  margin: PdfEdgeInsets.symmetric(horizontal: 40, vertical: 30),
)
```

#### `PdfRow`

Horizontal flex container.

```dart
PdfRow(
  children: [...],
  mainAxisAlignment: PdfMainAxisAlignment.spaceBetween,
  crossAxisAlignment: PdfCrossAxisAlignment.center,
  gap: 8,
)
```

#### `PdfColumn`

Vertical flex container. Default `crossAxisAlignment` is `stretch`.

```dart
PdfColumn(
  children: [...],
  mainAxisAlignment: PdfMainAxisAlignment.start,
  crossAxisAlignment: PdfCrossAxisAlignment.stretch,
  gap: 4,
)
```

#### `PdfStack` / `PdfPositioned`

Absolute-positioned layers. All children of `PdfStack` must be `PdfPositioned`.

```dart
PdfStack(children: [
  PdfPositioned(top: 0, left: 0, child: PdfImage.asset('assets/watermark.png')),
  PdfPositioned(top: 20, left: 20, child: PdfText('Content')),
])
```

#### `PdfContainer`

General-purpose box with optional size, background, padding, margin, and border.

```dart
PdfContainer(
  width: 200,
  height: null,               // null = wrap content
  color: PdfColor.fromHex('#F5F5F5'),
  padding: PdfEdgeInsets.all(12),
  margin: PdfEdgeInsets.only(bottom: 8),
  border: PdfBorder(color: PdfColor.fromHex('#DDDDDD'), width: 1, radius: 8),
  child: PdfText('inside'),
)
```

#### `PdfCard`

Thin wrapper over `PdfContainer` with a default drop shadow.

```dart
PdfCard(
  child: PdfText('Card content'),
  elevation: 2,               // maps to box-shadow intensity
  color: PdfColor(255, 255, 255),
  borderRadius: 8,
  padding: PdfEdgeInsets.all(16),
)
```

#### `PdfPadding`

Wraps a single child with padding.

```dart
PdfPadding(
  padding: PdfEdgeInsets.symmetric(horizontal: 16),
  child: PdfText('padded'),
)
```

#### `PdfListView`

Column with a uniform gap. Provided for developer familiarity.

```dart
PdfListView(
  children: [...],
  gap: 8,
)
```

#### `PdfSizedBox`

Fixed-size spacer or constrained box.

```dart
PdfSizedBox(height: 16)
PdfSizedBox(width: 100, height: 50)
```

#### `PdfDivider`

Horizontal rule.

```dart
PdfDivider(
  thickness: 1,
  color: PdfColor.fromHex('#EEEEEE'),
  indent: 16,
  endIndent: 16,
)
```

---

### Text

#### `PdfText`

Single-style paragraph.

```dart
PdfText(
  'Hello world',
  fontSize: 16,
  bold: false,
  italic: false,
  underline: false,
  color: PdfColor.fromHex('#333333'),
  textAlign: PdfTextAlign.left,
  maxLines: null,           // null = unlimited
)
```

#### `PdfRichText`

Multiple inline styles in one paragraph.

```dart
PdfRichText(spans: [
  PdfTextSpan('Total: ', bold: true),
  PdfTextSpan('₹1,200', color: PdfColor.fromHex('#2196F3'), bold: true, fontSize: 18),
])
```

`PdfTextSpan` parameters: `text`, `fontSize`, `bold`, `italic`, `underline`, `color`.

---

### Media

#### `PdfImage`

Three named constructors — all sources are resolved to base64 data URIs before injection.

```dart
PdfImage.asset('assets/logo.png', width: 100, height: 50)
PdfImage.memory(uint8ListBytes, width: 100, height: 50)
PdfImage.network('https://example.com/image.png', width: 100, height: 50)
```

Network images are fetched at generation time. A failed fetch renders as a broken image placeholder — generation continues.

#### `PdfIcon`

Renders a Material icon using its Unicode codepoint and the Material Icons font.

```dart
PdfIcon(Icons.check_circle, size: 24, color: PdfColor.fromHex('#4CAF50'))
```

Any `IconData` from the Flutter `Icons` class is supported.

---

### Table

#### `PdfTable`

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
  headerStyle: PdfTextStyle(bold: true, color: PdfColor(255, 255, 255)),
  headerBackground: PdfColor.fromHex('#2196F3'),
  rowAlternateColor: PdfColor.fromHex('#F9F9F9'),
  border: PdfBorder(width: 1, color: PdfColor.fromHex('#DDDDDD')),
)
```

---

## Supporting Types

### `PdfColor`

```dart
PdfColor(int r, int g, int b, {double a = 1.0})
PdfColor.fromHex('#2196F3')
PdfColor.transparent
```

### `PdfEdgeInsets`

```dart
PdfEdgeInsets.all(double value)
PdfEdgeInsets.symmetric({double horizontal = 0, double vertical = 0})
PdfEdgeInsets.only({double left, double top, double right, double bottom})
PdfEdgeInsets.zero
```

### `PdfBorder`

```dart
PdfBorder({
  required PdfColor color,
  double width = 1,
  double radius = 0,
})
```

### `PdfTextStyle`

Used in `PdfTable.headerStyle`.

```dart
PdfTextStyle({bool bold, bool italic, double? fontSize, PdfColor? color})
```

### Alignment enums

```dart
// PdfRow / PdfColumn main axis
enum PdfMainAxisAlignment { start, center, end, spaceBetween, spaceAround }

// PdfRow / PdfColumn cross axis
enum PdfCrossAxisAlignment { start, center, end, stretch }

// PdfText / PdfTableColumn
enum PdfTextAlign { left, center, right, justify }
```

---

## Generation API

### `PdfGeneratorScope`

Mount once, anywhere inside `MaterialApp`. Keeps a hidden `WebViewWidget` alive for the lifetime of the scope.

```dart
// Wrap your screen — not MaterialApp itself
MaterialApp(
  home: PdfGeneratorScope(child: MyScreen()),
)
```

### `PdfGenerator.generate()`

```dart
PdfGenerator.generate({
  required PdfDocument document,
  String fileName = 'document',          // output: <fileName>.pdf in temp dir
  required void Function(File) onSuccess,
  required void Function(Object) onError,
  void Function(int page, int total)? onProgress,
});
```

- Exactly one of `onSuccess` or `onError` is called — never both, never more than once.
- `onProgress` fires after each page is rendered with `(currentPage, totalPages)`.
- Empty document → `onError('Document has no content.')` immediately.
- 30-second hard timeout → `onError('PDF generation timed out after 30 seconds.')`.

---

## Preview API

### `PdfPreviewWidget`

Renders the same HTML that will be used for generation. No PDF is produced.

```dart
PdfPreviewWidget(
  document: doc,
  loadingWidget: CircularProgressIndicator(),  // optional, shown while rendering
)
```

The widget re-renders automatically when `document` changes. The generate button is your responsibility.

---

## Multi-language example

```dart
PdfDocument(
  children: [
    PdfText('English: Hello World', fontSize: 16),
    PdfText('Hindi: नमस्ते दुनिया', fontSize: 16),
    PdfText('Russian: Привет мир', fontSize: 16),
    PdfText('Japanese: こんにちは世界', fontSize: 16),
    PdfText('Chinese: 你好世界', fontSize: 16),
  ],
)
```

No configuration needed — the browser engine renders all scripts correctly.

---

## Error handling

Every error goes to `onError` — no exceptions are thrown at the caller.

| Situation | Behaviour |
|---|---|
| `children` is empty | `onError('Document has no content.')` |
| Network image fails to load | Broken-image placeholder; generation continues |
| JavaScript error in the engine | Caught and forwarded to `onError` |
| Generation exceeds 30 seconds | `onError('PDF generation timed out after 30 seconds.')` |
| `PdfGeneratorScope` not in tree | `AssertionError` in debug mode |

---

## Known limitations

1. **No hyperlinks** — HTML `<a>` tags are rasterised; URLs are not clickable in the PDF.
2. **No selectable text** — PDF content is image-based; text cannot be selected or searched.
3. **Requires WebView** — adds `webview_flutter` as a dependency. Not suitable for Flutter Web or environments without WebView support.
4. **Minimum unsplittable unit is one top-level child** — a single very tall widget (e.g. a massive `PdfTable`) may still be cut if it exceeds one full page height. Split large tables across multiple `PdfDocument.children` entries to control pagination.
5. **Network images require internet at generation time.**

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `webview_flutter` | `4.13.1` | WebView rendering engine |
| `path_provider` | `^2.1.5` | Write PDF to temp directory |
| `http` | `^1.6.0` | Fetch network images |

No state management dependency of any kind.

---

## Support My Work

If you find this package useful, consider supporting me with a coffee. Your support helps me maintain and improve this package! ☕️

<div style="align:center">
  <a href="https://buymeacoffee.com/harsh001" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;">
  </a>
</div>

---

## License

MIT — see [LICENSE](LICENSE.txt).
