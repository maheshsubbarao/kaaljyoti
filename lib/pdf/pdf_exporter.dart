library;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'pw.dart' as pw;
import 'package:printing/printing.dart';

import '../core/astro/ayanamsa.dart';
import '../core/constants.dart';
import '../core/date_format.dart';
import '../modules/common.dart';
import '../widgetsystem/astro_module.dart';
import '../widgetsystem/registry.dart';

enum PdfPaper { a4, letter }

typedef PdfBlock = ({String widgetId, Map<String, dynamic> config});

class PdfExportOptions {
  const PdfExportOptions({
    required this.blocks,
    this.paper = PdfPaper.a4,
    this.coverPage = true,
    this.brandingFooter,
  });

  final List<PdfBlock> blocks;
  final PdfPaper paper;
  final bool coverPage;
  final String? brandingFooter;
}

@visibleForTesting
String pdfScriptSample(ModuleContext ctx, PdfExportOptions options) => [
      ctx.l10n.languageEndonym,
      ctx.kundli.name,
      ctx.kundli.placeName,
      options.brandingFooter ?? '',
    ].join();

class PdfExporter {
  final pdfInkSoft = PdfColor.fromInt(0xFF757575);
  final pdfMaroon = PdfColor.fromInt(0xFF7B1F1F);
  final pdfInk = PdfColor.fromInt(0xFF000000);

  Future<pw.ThemeData> pdfTheme({required String scriptSample, dynamic ctx, dynamic options}) async {
    return pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );
  }

  Future<pw.Font?> kjPdfDisplay() async {
    try {
      final data = await rootBundle.load('assets/fonts/Marcellus-Regular.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> exportAndShare(
    ModuleContext ctx,
    PdfExportOptions options,
  ) async {
    final doc = await buildDocument(ctx, options);
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: '${ctx.kundli.name.replaceAll(RegExp(r'\s+'), '_')}_kundli.pdf',
    );
  }

  Future<void> printDialog(
    ModuleContext ctx,
    PdfExportOptions options,
  ) async {
    await Printing.layoutPdf(
      onLayout: (_) async => (await buildDocument(ctx, options)).save(),
    );
  }

  @visibleForTesting
  Future<pw.Document> buildDocument(
      ModuleContext ctx, PdfExportOptions options) async {
    final theme = await pdfTheme(scriptSample: pdfScriptSample(ctx, options));
    pw.Font? display;
    try {
      display = await kjPdfDisplay();
    } catch (_) {}
    final emblem = pw.MemoryImage(
        (await rootBundle.load('assets/emblem.png')).buffer.asUint8List());

    final doc = pw.Document(
      title: ctx.l10n.pdfDocTitle(ctx.kundli.name),
      producer: 'Kaal Jyoti',
      theme: theme,
    );
    final format =
        options.paper == PdfPaper.a4 ? PdfPageFormat.a4 : PdfPageFormat.letter;
    final birthFmt = DateFormat('${KJDate.pref.datePattern} \u00b7 HH:mm');

    if (options.coverPage) {
      doc.addPage(
        pw.Page(
          pageFormat: format,
          build: (_) => pw.Container(
            color: const PdfColor.fromInt(0xFFFCFAF4),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(emblem, width: 72, height: 72),
                  pw.SizedBox(height: 16),
                  pw.Text('KAAL JYOTI',
                      style: pw.TextStyle(
                          fontSize: 11, letterSpacing: 4, color: pdfInkSoft)),
                  pw.SizedBox(height: 24),
                  pw.Text(ctx.kundli.name,
                      style: pw.TextStyle(
                          font: display, fontSize: 32, color: pdfInk)),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    birthFmt.format(ctx.kundli.toBirthData().localDateTime),
                    style: pw.TextStyle(fontSize: 12, color: pdfInkSoft),
                  ),
                  pw.Text(ctx.kundli.placeName,
                      style: pw.TextStyle(fontSize: 12, color: pdfInkSoft)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '${Ayanamsa.byId(ctx.snapshot.ayanamsaId).name} ayanamsa',
                    style: pw.TextStyle(fontSize: 9, color: pdfInkSoft),
                  ),
                  if (options.brandingFooter != null) ...[
                    pw.SizedBox(height: 48),
                    pw.Text(options.brandingFooter!,
                        style: pw.TextStyle(fontSize: 10, color: pdfMaroon)),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    final blocks = <pw.Widget>[
      for (final block in options.blocks)
        if (moduleRegistry.containsKey(block.widgetId))
          ...moduleRegistry[block.widgetId]!
              .pdfView(ctx.withConfig(block.config)),
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        maxPages: 80,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    options.brandingFooter ?? '$kCopyrightLine \u00b7 $kWebsite',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                  pw.Text('${context.pageNumber} / ${context.pagesCount}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
              if (context.pageNumber == context.pagesCount)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 3),
                  child: pw.Text('KaalJyoti',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ),
            ],
          ),
        ),
        build: (_) => blocks,
      ),
    );

    return doc;
  }
}