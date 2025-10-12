import 'dart:io';
import 'dart:typed_data';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:omspos/screen/booking/model/booking_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:intl/intl.dart';

double myCellHeight = 20;

Future<Uint8List> generateBookingPdf({
  required BookingModel bookingData,
  required String companyName,
  required String companyPhone,
  required String companyPan,
  required String agentName,
}) async {
  final invoice = BookingInvoice(
    bookingData: bookingData,
    baseColor: PdfColors.blueAccent,
    accentColor: PdfColors.blueGrey900,
    companyName: companyName,
    companyPhone: companyPhone,
    companyPan: companyPan,
    agentName: agentName,
    fileName: 'Booking_${bookingData.bookingId}',
  );

  return await invoice.buildPdf(PdfPageFormat.a4);
}

class BookingInvoice {
  BookingInvoice({
    required this.bookingData,
    required this.baseColor,
    required this.accentColor,
    required this.companyName,
    required this.companyPhone,
    required this.companyPan,
    required this.agentName,
    required this.fileName,
  });

  final BookingModel bookingData;
  final PdfColor baseColor;
  final PdfColor accentColor;
  final String companyName;
  final String companyPhone;
  final String companyPan;
  final String agentName;
  final String fileName;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    final doc = Document();

    doc.addPage(
      MultiPage(
        footer: _buildFooter,
        build: (context) => [
          _buildHeader(context),
          SizedBox(height: 20),
          _buildBookingSummary(context),
          SizedBox(height: 15),
          _buildPropertyDetails(context),
          SizedBox(height: 15),
          _buildTenantDetails(context),
          SizedBox(height: 15),
          _buildFinancialDetails(context),
          SizedBox(height: 15),
          _buildTimelineDetails(context),
          SizedBox(height: 20),
          _buildFooterNotes(context),
        ],
      ),
    );

    final bytes = await doc.save();

    // Save and open the file (optional)
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$fileName.pdf');
      await file.writeAsBytes(bytes, flush: true);
      OpenFilex.open('$path/$fileName.pdf');
    } catch (e) {
      print('Error saving PDF: $e');
    }

    return bytes;
  }

  Widget _buildFooter(Context context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Copyright ©. All Rights Reserved",
            style: TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Context context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                companyName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: baseColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Phone: $companyPhone • PAN: $companyPan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.grey700,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.all(12),
          child: Center(
            child: Text(
              'BOOKING CONFIRMATION',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: baseColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummary(Context context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final statusText = bookingData.status.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PdfColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BOOKING SUMMARY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: baseColor,
            ),
          ),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              _buildTableRow('Booking ID', bookingData.bookingId),
              _buildTableRow('Booking Status', statusText, isHighlighted: true),
              _buildTableRow('Property Title', bookingData.title),
              _buildTableRow('Room Number', bookingData.roomNumber),
              _buildTableRow('Address', bookingData.address),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetails(Context context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PdfColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROPERTY DETAILS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: baseColor,
            ),
          ),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              _buildTableRow('Property ID', bookingData.propertyId),
              _buildTableRow('Property Type', bookingData.propertyType),
              _buildTableRow('Furnishing Status', bookingData.furnishingStatus),
              _buildTableRow('Area (sqft)', bookingData.areaSqft.toString()),
              _buildTableRow('Description', bookingData.description),
              _buildTableRow('Coordinates',
                  '${bookingData.latitude.toStringAsFixed(6)}, ${bookingData.longitude.toStringAsFixed(6)}'),
            ],
          ),
          SizedBox(height: 8),
          if (bookingData.attributes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attributes:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  bookingData.attributes.join(', '),
                  style: TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTenantDetails(Context context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PdfColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TENANT DETAILS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: baseColor,
            ),
          ),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              _buildTableRow('Tenant ID', bookingData.tenantId),
              _buildTableRow('Profession', bookingData.profession),
              _buildTableRow(
                  'Number of People', bookingData.peoples.toString()),
              _buildTableRow('Landlord ID', bookingData.landlordId),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialDetails(Context context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final totalAmount = bookingData.monthlyRent + bookingData.securityDeposit;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PdfColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINANCIAL DETAILS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: baseColor,
            ),
          ),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              _buildTableRow('Monthly Rent',
                  currencyFormat.format(bookingData.monthlyRent)),
              _buildTableRow('Security Deposit',
                  currencyFormat.format(bookingData.securityDeposit)),
              _buildTableRow('Room Rent Amount',
                  currencyFormat.format(bookingData.rentAmount)),
              TableRow(
                decoration: BoxDecoration(color: baseColor),
                children: [
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      currencyFormat.format(totalAmount),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDetails(Context context) {
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm a');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PdfColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIMELINE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: baseColor,
            ),
          ),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: PdfColors.grey200, width: 0.5),
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              _buildTableRow(
                  'Booking Date', dateFormat.format(bookingData.bookingDate)),
              _buildTableRow(
                  'Move-in Date', dateFormat.format(bookingData.moveInDate)),
              if (bookingData.moveOutDate != null)
                _buildTableRow('Move-out Date',
                    dateFormat.format(bookingData.moveOutDate!)),
              _buildTableRow(
                  'Created Date', dateFormat.format(bookingData.createdAt)),
              _buildTableRow(
                  'Last Updated', dateFormat.format(bookingData.updatedAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNotes(Context context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Important Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: baseColor,
                ),
              ),
              SizedBox(height: 8),
              Text('• Please bring this document when moving in'),
              Text(
                  '• Contact the landlord for any queries regarding the property'),
              Text('• Keep this document safe for future reference'),
              Text('• All payments should be made through proper channels'),
              Text(
                  '• Security deposit will be refunded as per agreement terms'),
            ],
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated By: $agentName',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Printed On: ${NepaliDateTime.now().format("yyyy-MM-dd hh:mm a")}',
                  style: TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 20),
                Text('_________________________'),
                Text('Authorized Signature'),
                Text(
                  'Agent: $agentName',
                  style: TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value,
      {bool isHighlighted = false}) {
    return TableRow(
      decoration: isHighlighted ? BoxDecoration(color: baseColor) : null,
      children: [
        Padding(
          padding: EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: isHighlighted ? baseColor : PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
