import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

/// ExportService
/// Handles exporting notes to PDF and Markdown formats
class ExportService {
  /// Export note to PDF
  Future<void> exportToPdf(Note note, BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Extract plain text from rich text JSON
      String plainText = _extractPlainText(note.content);

      // Create PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title
                pw.Text(
                  note.displayTitle,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                // Date
                pw.Text(
                  'Created: ${_formatDate(note.createdAt)}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
                pw.SizedBox(height: 20),
                // Content
                pw.Text(
                  plainText.isEmpty ? 'No content' : plainText,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            );
          },
        ),
      );

      // Show print/share dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '${note.displayTitle}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting to PDF: $e')),
        );
      }
    }
  }

  /// Export note to Markdown
  Future<void> exportToMarkdown(Note note, BuildContext context) async {
    try {
      // Convert to Markdown
      String markdown = _convertToMarkdown(note);

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${note.displayTitle}.md');
      await file.writeAsString(markdown);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: note.displayTitle,
        text: 'Exported from AnchorNotes',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting to Markdown: $e')),
        );
      }
    }
  }

  /// Export note as plain text
  Future<void> exportAsText(Note note, BuildContext context) async {
    try {
      // Extract plain text
      String plainText = _extractPlainText(note.content);
      String fullText = '${note.displayTitle}\n\n$plainText';

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${note.displayTitle}.txt');
      await file.writeAsString(fullText);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: note.displayTitle,
        text: 'Exported from AnchorNotes',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting as text: $e')),
        );
      }
    }
  }

  /// Convert note to Markdown format
  String _convertToMarkdown(Note note) {
    final buffer = StringBuffer();

    // Title
    buffer.writeln('# ${note.displayTitle}');
    buffer.writeln();

    // Metadata
    buffer.writeln('**Created:** ${_formatDate(note.createdAt)}');
    buffer.writeln('**Last Modified:** ${_formatDate(note.updatedAt)}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    // Content
    String content = _extractPlainText(note.content);
    if (content.isEmpty) {
      buffer.writeln('*No content*');
    } else {
      buffer.writeln(content);
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('*Exported from AnchorNotes*');

    return buffer.toString();
  }

  /// Extract plain text from rich text JSON or return plain text
  String _extractPlainText(String content) {
    if (content.trim().isEmpty) return '';

    // Check if content is JSON (rich text format)
    if (content.startsWith('[') && content.contains('"insert"')) {
      try {
        final dynamic decoded = jsonDecode(content);
        if (decoded is List) {
          final buffer = StringBuffer();
          for (final op in decoded) {
            if (op is Map && op.containsKey('insert')) {
              buffer.write(op['insert'].toString());
            }
          }
          return buffer.toString().trim();
        }
      } catch (e) {
        // If JSON parsing fails, return as-is
        return content;
      }
    }

    // Plain text content
    return content;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
