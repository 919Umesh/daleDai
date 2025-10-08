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
          _buildBookingDetails(context),
          SizedBox(height: 30),
          _buildPaymentDetails(context),
          SizedBox(height: 30),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          child: Text("Copyright ©. All Rights Reserved"),
        ),
        Text(
          '${context.pageNumber}/${context.pagesCount}',
          style: const TextStyle(
            fontSize: 12,
            color: PdfColors.black,
          ),
        ),
      ],
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
                  color: PdfColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Phone: $companyPhone",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "PAN: $companyPan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PdfColors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Divider(),
        Center(
          child: Text(
            'BOOKING DETAILS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget _buildBookingDetails(Context context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final statusText =
        bookingData.status.toString().split('.').last.toUpperCase();

    return Table(
      border: TableBorder.all(width: 1),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          children: [
            Padding(
                padding: EdgeInsets.all(5),
                child: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(5), child: Text(statusText)),
          ],
        ),
        TableRow(
          children: [
            Padding(
                padding: EdgeInsets.all(5),
                child: Text('Booking Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(
                padding: EdgeInsets.all(5),
                child: Text(dateFormat.format(bookingData.bookingDate))),
          ],
        ),
        TableRow(
          children: [
            Padding(
                padding: EdgeInsets.all(5),
                child: Text('Move In Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(
                padding: EdgeInsets.all(5),
                child: Text(dateFormat.format(bookingData.moveInDate))),
          ],
        ),
        if (bookingData.moveOutDate != null)
          TableRow(
            children: [
              Padding(
                  padding: EdgeInsets.all(5),
                  child: Text('Move Out Date',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(dateFormat.format(bookingData.moveOutDate!))),
            ],
          ),
        TableRow(
          children: [
            Padding(
                padding: EdgeInsets.all(5),
                child: Text('Room ID',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(
                padding: EdgeInsets.all(5), child: Text(bookingData.roomId)),
          ],
        ),
        TableRow(
          children: [
            Padding(
                padding: EdgeInsets.all(5),
                child: Text('Tenant ID',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(
                padding: EdgeInsets.all(5), child: Text(bookingData.tenantId)),
          ],
        ),
        TableRow(
          children: [
            Padding(
                padding: EdgeInsets.all(5),
                child: Text('Landlord ID',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(
                padding: EdgeInsets.all(5),
                child: Text(bookingData.landlordId)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(Context context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT DETAILS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 10),
        Table(
          border: TableBorder.all(width: 1),
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              children: [
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Monthly Rent',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.all(5),
                    child:
                        Text(currencyFormat.format(bookingData.monthlyRent))),
              ],
            ),
            TableRow(
              children: [
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Security Deposit',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                        currencyFormat.format(bookingData.securityDeposit))),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: PdfColors.grey200),
              children: [
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Text('Total Amount',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                        currencyFormat.format(bookingData.monthlyRent +
                            bookingData.securityDeposit),
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterNotes(Context context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(height: 10),
        Text(
          'Notes:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text('1. Please bring this document when moving in.'),
        Text('2. Contact the landlord for any queries.'),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Printed Date: ${NepaliDateTime.now().format("yyyy-MM-dd")}'),
                Text('Printed By: $agentName'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 30),
                Text('_________________________'),
                Text('Signature'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
