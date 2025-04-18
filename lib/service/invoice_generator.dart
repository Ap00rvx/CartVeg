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
      final Map<String, dynamic> invoiceData;
      try {
        invoiceData = json.decode(jsonData) as Map<String, dynamic>;
      } catch (e) {
        throw FormatException('Invalid JSON format: $e');
      }

      _validateInvoiceData(invoiceData);

      final pdf = pw.Document();
      pdf.addPage(_createInvoicePage(invoiceData));

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/invoice_${invoiceData['invoiceId'] ?? 'unknown'}.pdf');
      await file.writeAsBytes(await pdf.save());

      print('Invoice generated and saved at: ${file.path}');
      return file;
    } catch (e) {
      print('Error generating invoice: $e');
      rethrow;
    }
  }

  void _validateInvoiceData(Map<String, dynamic> data) {
    final requiredFields = ['invoiceId', 'orderId', 'orderDate', 'items', 'totalAmount'];
    for (var field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        throw Exception('Missing or null required field: $field');
      }
    }
  }

  double _calculateItemsSubtotal(List<dynamic> items) {
    return items.fold(0.0, (sum, item) {
      final quantity = (item['quantity'] ?? 0).toDouble();
      final price = (item['price'] ?? 0.0).toDouble();
      return sum + (quantity * price);
    });
  }

  pw.Page _createInvoicePage(Map<String, dynamic> data) {
    String formattedDate;
    try {
      final orderDate = DateTime.parse(data['orderDate'] as String);
      formattedDate = DateFormat('dd/MM/yyyy').format(orderDate);
    } catch (e) {
      formattedDate = 'Invalid Date';
    }

    final itemsSubtotal = _calculateItemsSubtotal(data['items'] ?? []);
    final totalAmount = (data['totalAmount'] ?? 0.0).toDouble();
    final deliveryCharges = totalAmount - itemsSubtotal;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CartVeg',
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Kanpur, Uttar Pradesh'),
                    pw.Text('GSTIN: 09ABCDE1234F1Z5'),
                    pw.Text('Email: Cartveg.dev@gmail.com'),
                    pw.Text('Phone: +91 870 722 1578'),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            pw.Container(
              color: PdfColors.grey200,
              padding: const pw.EdgeInsets.all(10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVOICE',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice No: ${data['invoiceId'] ?? 'N/A'}'),
                      pw.Text('Order No: ${data['orderId'] ?? 'N/A'}'),
                      pw.Text('Date: $formattedDate'),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

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
                      pw.Text(data['userDetails']?['name'] ?? 'Unknown'),
                      pw.Text(_getAddressString(data['billingAddress'])),
                      pw.SizedBox(height: 5),
                      pw.Text('Phone: ${data['userDetails']?['phone'] ?? 'N/A'}'),
                      pw.Text('Email: ${data['userDetails']?['email'] ?? 'N/A'}'),
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
                      pw.Text(data['userDetails']?['name'] ?? 'Unknown'),
                      pw.Text(_getAddressString(data['shippingAddress'])),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

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
                ..._buildItemRows(data['items'] ?? []),
              ],
            ),

            pw.SizedBox(height: 10),

            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _summaryRow('Subtotal', itemsSubtotal),
                  _summaryRow('Delivery Charges', deliveryCharges),
                  _summaryRow('Total Amount', totalAmount, isTotal: true),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Payment Information:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Payment Method: ${data['paymentMode'] ?? 'N/A'}'),
                  pw.Text('Payment Status: ${_capitalizeFirstLetter(data['paymentStatus'] ?? 'unknown')}'),
                ],
              ),
            ),

            pw.Spacer(),

            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text('Thank you for shopping with CartVeg!'),
                  pw.SizedBox(height: 5),
                  pw.Text('For any queries, please contact us at support@cartveg.com or call +91 512 123 4567'),
                  pw.SizedBox(height: 5),
                  pw.Text('This is a computer-generated invoice and does not require a signature.'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getAddressString(Map<String, dynamic>? address) {
    if (address == null) return 'N/A';
    return '${address['flatno'] ?? ''}, ${address['street'] ?? ''}\n'
           '${address['city'] ?? ''}, ${address['state'] ?? ''} - ${address['pincode'] ?? ''}';
  }

  List<pw.TableRow> _buildItemRows(List<dynamic> items) {
    return items.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value as Map<String, dynamic>;
      final quantity = (item['quantity'] ?? 0).toDouble();
      final price = (item['price'] ?? 0.0).toDouble();
      return pw.TableRow(
        children: [
          _tableCell('${i + 1}'),
          _tableCell(item['name'] ?? 'Unknown Item'),
          _tableCell(quantity.toString()),
          _tableCell('Rs${price.toStringAsFixed(2)}'),
          _tableCell('Rs${(quantity * price).toStringAsFixed(2)}'),
        ],
      );
    }).toList();
  }

  pw.Widget _summaryRow(String label, double amount, {bool isTotal = false}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 150,
          color: isTotal ? PdfColors.grey300 : null,
          child: pw.Text(label,
              style: pw.TextStyle(
                  fontWeight: isTotal ? pw.FontWeight.bold : null)),
          padding: const pw.EdgeInsets.all(5),
        ),
        pw.Container(
          width: 100,
          alignment: pw.Alignment.centerRight,
          color: isTotal ? PdfColors.grey300 : null,
          child: pw.Text('Rs${amount.toStringAsFixed(2)}',
              style: pw.TextStyle(
                  fontWeight: isTotal ? pw.FontWeight.bold : null)),
          padding: const pw.EdgeInsets.all(5),
        ),
      ],
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
            onPressed: () async {
              try {
                await Share.shareXFiles([XFile(widget.pdfFile.path)],
                    text: 'Invoice #${widget.invoiceId}');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error sharing invoice: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                final downloadDir = await getExternalStorageDirectory();
                final targetPath =
                    '${downloadDir?.path}/invoice_${widget.invoiceId}.pdf';
                final targetFile = await widget.pdfFile.copy(targetPath);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloaded to ${targetFile.path}')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error downloading invoice: $e')),
                );
              }
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
              print('PDF view error: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading PDF: $error')),
              );
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
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