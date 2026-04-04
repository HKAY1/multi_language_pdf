## 0.1.0

* Initial release.
* Flutter-inspired DSL for composing PDFs (`PdfText`, `PdfRichText`, `PdfRow`, `PdfColumn`, `PdfContainer`, `PdfCard`, `PdfStack`, `PdfPositioned`, `PdfPadding`, `PdfListView`, `PdfSizedBox`, `PdfDivider`, `PdfImage`, `PdfIcon`, `PdfTable`).
* Multi-language support — renders any Unicode script (Latin, Devanagari, Cyrillic, CJK, Arabic, and more) natively via WebView.
* Semantic pagination — measures actual rendered element heights before splitting pages; no mid-element cuts.
* Zero state-manager dependency — pure callback API (`onSuccess`, `onError`, `onProgress`).
* `PdfPreviewWidget` — embeddable WebView preview; developer provides the generate button.
* `PdfImage.asset()`, `PdfImage.memory()`, `PdfImage.network()` — all resolved to base64 data URIs before injection.
* `PdfIcon` — renders Material icons via Unicode codepoint and Material Icons font.
* 30-second generation timeout replacing blind delays.
* `PdfGeneratorScope` + `PdfGenerator.generate()` static API.
