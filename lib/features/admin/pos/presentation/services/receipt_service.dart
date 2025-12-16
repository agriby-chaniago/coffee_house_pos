import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:coffee_house_pos/features/customer/orders/data/models/order_model.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  static String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  static Future<void> printReceipt(
    Order order, {
    String? storeName,
    String? storeAddress,
    String? storePhone,
  }) async {
    final pdf = pw.Document();

    // Custom 50mm width thermal receipt paper
    const mmToPoints = 2.834645669;
    const customFormat = PdfPageFormat(
      50 * mmToPoints, // 50mm width
      double.infinity, // unlimited height (roll paper)
      marginAll: 2 * mmToPoints, // 2mm margin
    );

    pdf.addPage(
      pw.Page(
        pageFormat: customFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.SizedBox(height: 6),

              // Store header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      storeName?.toUpperCase() ?? 'COFFEE HOUSE',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      width: 80,
                      height: 0.5,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.normal,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),

              // Order info
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Order', order.orderNumber, bold: true),
                  _buildInfoRow('Date',
                      DateFormat('dd/MM/yy HH:mm').format(order.createdAt)),
                  _buildInfoRow('Cashier', order.cashierName),
                  if (order.customerName != null)
                    _buildInfoRow('Cust', order.customerName!),
                ],
              ),

              pw.SizedBox(height: 6),

              // Divider
              pw.Container(height: 0.5, color: PdfColors.black),

              pw.SizedBox(height: 4),

              // Items list
              ...order.items.map((item) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Product name and total
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 4),
                        pw.Text(
                          formatCurrency(item.itemTotal),
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 1),
                    // Quantity and size
                    pw.Text(
                      '${item.quantity}x ${item.selectedSize} @ ${formatCurrency(item.basePrice)}',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColor.fromInt(0xFF666666),
                      ),
                    ),
                    // Add-ons
                    if (item.addOns.isNotEmpty)
                      ...item.addOns.map((addon) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4, top: 1),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  '+ ${addon.name}',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),
                              ),
                              pw.Text(
                                formatCurrency(addon.additionalPrice),
                                style: const pw.TextStyle(fontSize: 7),
                              ),
                            ],
                          ),
                        );
                      }),
                    pw.SizedBox(height: 4),
                  ],
                );
              }),

              pw.SizedBox(height: 4),

              // Divider
              pw.Container(height: 0.5, color: PdfColors.black),

              pw.SizedBox(height: 4),

              // Summary
              _buildSummaryRow('Subtotal', formatCurrency(order.subtotal)),
              _buildSummaryRow('PPN 11%', formatCurrency(order.taxAmount)),

              pw.SizedBox(height: 4),
              pw.Container(height: 0.5, color: PdfColors.black),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    formatCurrency(order.total),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Container(height: 0.5, color: PdfColors.black),
              pw.SizedBox(height: 4),

              _buildSummaryRow(
                'Payment',
                (order.paymentMethod ?? 'cash').toUpperCase(),
              ),

              pw.SizedBox(height: 6),
              pw.Container(height: 1, color: PdfColors.black),
              pw.SizedBox(height: 6),

              // Footer
              pw.Center(
                child: pw.Text(
                  'THANK YOU',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              pw.SizedBox(height: 6),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildInfoRow(String label, String value,
      {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Flexible(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.right,
              overflow: pw.TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 7),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 7),
          ),
        ],
      ),
    );
  }

  static Future<void> shareReceipt(
    Order order, {
    String? storeName,
    String? storeAddress,
    String? storePhone,
  }) async {
    final pdf = pw.Document();

    // Custom 50mm width thermal receipt paper
    const mmToPoints = 2.834645669;
    const customFormat = PdfPageFormat(
      50 * mmToPoints, // 50mm width
      double.infinity, // unlimited height (roll paper)
      marginAll: 2 * mmToPoints, // 2mm margin
    );

    pdf.addPage(
      pw.Page(
        pageFormat: customFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.SizedBox(height: 6),

              // Store header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      storeName?.toUpperCase() ?? 'COFFEE HOUSE',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      width: 80,
                      height: 0.5,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.normal,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),

              // Order info
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Order', order.orderNumber, bold: true),
                  _buildInfoRow('Date',
                      DateFormat('dd/MM/yy HH:mm').format(order.createdAt)),
                  _buildInfoRow('Cashier', order.cashierName),
                  if (order.customerName != null)
                    _buildInfoRow('Cust', order.customerName!),
                ],
              ),

              pw.SizedBox(height: 6),

              // Divider
              pw.Container(height: 0.5, color: PdfColors.black),

              pw.SizedBox(height: 4),

              // Items list
              ...order.items.map((item) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Product name and total
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 4),
                        pw.Text(
                          formatCurrency(item.itemTotal),
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 1),
                    // Quantity and size
                    pw.Text(
                      '${item.quantity}x ${item.selectedSize} @ ${formatCurrency(item.basePrice)}',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColor.fromInt(0xFF666666),
                      ),
                    ),
                    // Add-ons
                    if (item.addOns.isNotEmpty)
                      ...item.addOns.map((addon) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4, top: 1),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  '+ ${addon.name}',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),
                              ),
                              pw.Text(
                                formatCurrency(addon.additionalPrice),
                                style: const pw.TextStyle(fontSize: 7),
                              ),
                            ],
                          ),
                        );
                      }),
                    pw.SizedBox(height: 4),
                  ],
                );
              }),

              pw.SizedBox(height: 4),

              // Divider
              pw.Container(height: 0.5, color: PdfColors.black),

              pw.SizedBox(height: 4),

              // Summary
              _buildSummaryRow('Subtotal', formatCurrency(order.subtotal)),
              _buildSummaryRow('PPN 11%', formatCurrency(order.taxAmount)),

              pw.SizedBox(height: 4),
              pw.Container(height: 0.5, color: PdfColors.black),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    formatCurrency(order.total),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Container(height: 0.5, color: PdfColors.black),
              pw.SizedBox(height: 4),

              _buildSummaryRow(
                'Payment',
                (order.paymentMethod ?? 'cash').toUpperCase(),
              ),

              pw.SizedBox(height: 6),
              pw.Container(height: 1, color: PdfColors.black),
              pw.SizedBox(height: 6),

              // Footer
              pw.Center(
                child: pw.Text(
                  'THANK YOU',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              pw.SizedBox(height: 6),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'receipt-${order.orderNumber}.pdf',
    );
  }
}
