import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class InvoiceGenerator {
  final String jsonData;

  InvoiceGenerator({required this.jsonData});

  Future<File> generateInvoice() async {
    try {
      // Parse JSON data
      final Map<String, dynamic> invoiceData = json.decode(jsonData);

      // Create a PDF document
      final pdf = pw.Document();

      // Add invoice page to the PDF
      pdf.addPage(
        _createInvoicePage(invoiceData),
      );

      // Save the PDF file
      final output = await getTemporaryDirectory();
      final file =
          File('${output.path}/invoice_${invoiceData['invoiceId']}.pdf');
      await file.writeAsBytes(await pdf.save());

      print('Invoice generated and saved at: ${file.path}');
      return file;
    } catch (e) {
      print('Error generating invoice: $e');
      throw e;
    }
  }

  pw.Page _createInvoicePage(Map<String, dynamic> data) {
    // Format date for display
    final orderDate = DateTime.parse(data['orderDate']);
    final formattedDate = DateFormat('dd/MM/yyyy').format(orderDate);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with company info and logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CartVeg',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Kanpur, Uttar Pradesh'),
                    pw.Text('GSTIN: 09ABCDE1234F1Z5'),
                    pw.Text('Email: support@cartveg.com'),
                    pw.Text('Phone: +91 512 123 4567'),
                  ],
                ),
                pw.Container(
                  height: 80,
                  width: 80,
                  child: pw.Center(
                    child: pw.Text('LOGO', style: pw.TextStyle(fontSize: 20)),
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Invoice details
            pw.Container(
              color: PdfColors.grey200,
              padding: const pw.EdgeInsets.all(10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVOICE',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice No: ${data['invoiceId']}'),
                      pw.Text('Order No: ${data['orderId']}'),
                      pw.Text('Date: $formattedDate'),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Customer & Shipping info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text(data['userDetails']['name']),
                      pw.Text(
                          '${data['billingAddress']['flatno']}, ${data['billingAddress']['street']}'),
                      pw.Text(
                          '${data['billingAddress']['city']}, ${data['billingAddress']['state']} - ${data['billingAddress']['pincode']}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Phone: ${data['userDetails']['phone']}'),
                      pw.Text('Email: ${data['userDetails']['email']}'),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('SHIP TO:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text(data['userDetails']['name']),
                      pw.Text(
                          '${data['shippingAddress']['flatno']}, ${data['shippingAddress']['street']}'),
                      pw.Text(
                          '${data['shippingAddress']['city']}, ${data['shippingAddress']['state']} - ${data['shippingAddress']['pincode']}'),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Order details table
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                // Table header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _tableHeader('S.No.'),
                    _tableHeader('Item'),
                    _tableHeader('Qty'),
                    _tableHeader('Price'),
                    _tableHeader('Total'),
                  ],
                ),
                // Table items
                for (int i = 0; i < data['items'].length; i++)
                  pw.TableRow(
                    children: [
                      _tableCell('${i + 1}'),
                      _tableCell(data['items'][i]['name']),
                      _tableCell('${data['items'][i]['quantity']}'),
                      _tableCell(
                          'Rs${data['items'][i]['price'].toStringAsFixed(2)}'),
                      _tableCell(
                          'Rs${(data['items'][i]['quantity'] * data['items'][i]['price']).toStringAsFixed(2)}'),
                    ],
                  ),
              ],
            ),

            pw.SizedBox(height: 10),

            // Summary
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 150,
                        child: pw.Text('Subtotal'),
                        padding: const pw.EdgeInsets.all(5),
                      ),
                      pw.Container(
                        width: 100,
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                            'Rs${data['totalAmount'].toStringAsFixed(2)}'),
                        padding: const pw.EdgeInsets.all(5),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 150,
                        child: pw.Text('Delivery Charges'),
                        padding: const pw.EdgeInsets.all(5),
                      ),
                      pw.Container(
                        width: 100,
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text('Rs0.00'),
                        padding: const pw.EdgeInsets.all(5),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 150,
                        color: PdfColors.grey300,
                        child: pw.Text('Total Amount',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        padding: const pw.EdgeInsets.all(5),
                      ),
                      pw.Container(
                        width: 100,
                        alignment: pw.Alignment.centerRight,
                        color: PdfColors.grey300,
                        child: pw.Text(
                            'Rs.${data['totalAmount'].toStringAsFixed(2)}',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        padding: const pw.EdgeInsets.all(5),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Payment information
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Payment Information:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Payment Method: ${data['paymentMode']}'),
                  pw.Text(
                      'Payment Status: ${_capitalizeFirstLetter(data['paymentStatus'])}'),
                ],
              ),
            ),

            pw.Spacer(),

            // Footer
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text('Thank you for shopping with CartVeg!'),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      'For any queries, please contact us at support@cartveg.com or call +91 512 123 4567'),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      'This is a computer-generated invoice and does not require a signature.'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  pw.Widget _tableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _tableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(text),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}

// PDF Viewer Screen
class PDFViewerScreen extends StatefulWidget {
  final File pdfFile;
  final String invoiceId;

  const PDFViewerScreen({
    Key? key,
    required this.pdfFile,
    required this.invoiceId,
  }) : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${widget.invoiceId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.shareXFiles([XFile(widget.pdfFile.path)],
                  text: 'Invoice #${widget.invoiceId}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              // Copy file to downloads folder or another permanent location
              final downloadDir = await getExternalStorageDirectory();
              final targetPath =
                  '${downloadDir?.path}/invoice_${widget.invoiceId}.pdf';
              final targetFile = await widget.pdfFile.copy(targetPath);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloaded to ${targetFile.path}')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfFile.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                _isLoading = false;
              });
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
            onError: (error) {
              print(error.toString());
            },
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 50),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
