class PdfExporter {
  final pdfInkSoft = PdfColor.fromInt(0xFF757575);
  final pdfMaroon = PdfColor.fromInt(0xFF7B1F1F);
  final pdfInk = PdfColor.fromInt(0xFF000000);

  // FIX: Added missing theme loader
  Future<pw.ThemeData> pdfTheme({required String scriptSample, dynamic ctx, dynamic options}) async {
    return pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );
  }

  // FIX: Added missing display font loader
  Future<pw.Font?> kjPdfDisplay() async {
    try {
      final data = await rootBundle.load('assets/fonts/Marcellus-Regular.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return null;
    }
  }