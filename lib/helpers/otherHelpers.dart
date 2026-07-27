import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:pos_final/helpers/platform_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

// import 'package:call_log/call_log.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as pd;
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' show HTMLToPdf;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../locale/MyLocalizations.dart';
import '../domain/models/invoice.dart';
import '../domain/models/system.dart';
import '../core/theme/app_theme.dart';
import 'SizeConfig.dart';

class Helper {
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  Widget loadingIndicator(context) {
    return Center(
      child: Card(
        elevation: MySize.size10,
        child: Container(
          padding: EdgeInsets.all(MySize.size28!),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MySize.size8!),
          ),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  //format currency
  String formatCurrency(amount) {
    double convertAmount = double.parse(amount.toString());

    var amt = NumberFormat.currency(
      symbol: '',
      decimalDigits: Config.currencyPrecision,
    ).format(convertAmount);
    return amt;
  }

  double validateInput(String val) {
    try {
      double value = double.parse(val.toString());
      return value;
    } catch (e) {
      return 0.00;
    }
  }

  //format quantity
  String formatQuantity(amount) {
    double quantity = double.parse(amount.toString());
    var amt = NumberFormat.currency(
      symbol: '',
      decimalDigits: Config.quantityPrecision,
    ).format(quantity);
    return amt;
  }

  //argument model
  Map argument({
    int? sellId,
    int? locId,
    int? taxId,
    String? discountType,
    double? discountAmount,
    double? invoiceAmount,
    int? customerId,
    int? isQuotation,
  }) {
    Map args = {
      'sellId': sellId,
      'locationId': locId,
      'taxId': taxId,
      'discountType': discountType,
      'discountAmount': discountAmount,
      'invoiceAmount': invoiceAmount,
      'customerId': customerId,
      'is_quotation': isQuotation,
    };
    return args;
  }

  //check internet connectivity
  Future<bool> checkConnectivity() async {
    // On desktop, skip the plugin check — always attempt the request
    // and let the HTTP layer handle actual connectivity failures.
    if (isDesktop) return true;
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.other;
  }

  //get location name by location_id
  Future<String?> getLocationNameById(var id) async {
    String? locationName;
    var response = await System().get('location');
    response.forEach((element) {
      if (element['id'] == int.parse(id.toString())) {
        locationName = element['name'];
      }
    });
    return locationName;
  }

  //calculate inline tax and discount amount
  Future<Map<String, double>> calculateTaxAndDiscount({
    discountAmount,
    discountType,
    taxId,
    unitPrice,
  }) async {
    double disAmt = 0.0, tax = 0.00, taxAmt = 0.00;
    await System().get('tax').then((value) {
      value.forEach((element) {
        if (element['id'] == taxId) {
          tax = double.parse(element['amount'].toString()) * 1.0;
        }
      });
    });

    if (discountType == 'fixed') {
      disAmt = discountAmount;
      taxAmt = ((unitPrice - discountAmount) * tax / 100);
    } else {
      disAmt = (unitPrice * discountAmount / 100);
      taxAmt = ((unitPrice - (unitPrice * discountAmount / 100)) * tax / 100);
    }
    return {'discountAmount': disAmt, 'taxAmount': taxAmt};
  }

  //calculate price including tax
  Future<String> calculateTotal({
    unitPrice,
    discountType,
    discountAmount,
    taxId,
  }) async {
    double tax = 0.00;
    double subTotal = 0.00;
    double amount = 0.0;
    unitPrice = double.parse(unitPrice.toString());
    discountAmount = double.parse(discountAmount.toString());
    //set tax
    await System().get('tax').then((value) {
      value.forEach((element) {
        if (element['id'] == taxId) {
          tax = double.parse(element['amount'].toString()) * 1.0;
        }
      });
    });
    //calculate subTotal according to discount type
    if (discountType == 'fixed') {
      amount = unitPrice - discountAmount;
    } else {
      amount = unitPrice - (unitPrice * discountAmount / 100);
    }
    //calculate subtotal
    subTotal = (amount + (amount * tax / 100));
    return subTotal.toStringAsFixed(2);
  }

  Future<String> barcodeScan() async {
    if (isDesktop) {
      // On desktop, barcode input comes via HID keyboard stream — not camera.
      // Callers that need desktop barcode should use the text field directly.
      return '';
    }
    var result = await BarcodeScanner.scan();
    return result.rawContent.trimRight();
  }

  // Convert mm to PDF points (1mm = 72/25.4 points)
  static double _mm(double mm) => mm * 72.0 / 25.4;

  // Get page format based on configured paper size.
  // Thermal printers use continuous rolls, so pick a very tall logical page
  // height — this avoids MultiPage's TooManyPagesException when a single
  // indivisible child (e.g. a tall table) exceeds the page height.
  static pd.PdfPageFormat getPageFormat() {
    switch (Config.printPaperSize) {
      case '56mm':
        return pd.PdfPageFormat(_mm(56), _mm(2000), marginAll: _mm(2));
      case 'card':
        // CR80 standard card: 85.6mm x 54mm
        return pd.PdfPageFormat(_mm(85.6), _mm(54), marginAll: _mm(3));
      case '80mm':
      default:
        return pd.PdfPageFormat(_mm(80), _mm(2000), marginAll: _mm(3));
    }
  }

  // Cache the bundled Arabic-capable font so we only decode it once.
  static pd.Font? _arabicFontCache;
  static Future<pd.Font> _loadArabicFont() async {
    if (_arabicFontCache != null) return _arabicFontCache!;
    final data = await rootBundle.load('assets/fonts/cairo.ttf');
    _arabicFontCache = pd.Font.ttf(data);
    return _arabicFontCache!;
  }

  // Strip nodes htmltopdfwidgets can't handle: HTML/IE-conditional comments,
  // <script>, <style>, <link>, <meta>, and DOCTYPE. Without this, remote
  // invoice HTML containing things like <!--[if lt IE 9]>...<![endif]-->
  // throws "Unknown node type" from the parser.
  String _sanitizeHtmlForPdf(String html) {
    final patterns = <RegExp>[
      RegExp(r'<!--[\s\S]*?-->', multiLine: true),
      RegExp(r'<!\[endif\]-*>', caseSensitive: false),
      RegExp(r'<!doctype[^>]*>', caseSensitive: false),
      RegExp(r'<script\b[^>]*>[\s\S]*?</script>', caseSensitive: false),
      RegExp(r'<style\b[^>]*>[\s\S]*?</style>', caseSensitive: false),
      RegExp(r'<link\b[^>]*/?>', caseSensitive: false),
      RegExp(r'<meta\b[^>]*/?>', caseSensitive: false),
    ];
    var sanitized = html;
    for (final p in patterns) {
      sanitized = sanitized.replaceAll(p, '');
    }
    return sanitized;
  }

  //convert HTML to PDF bytes using pure-Dart htmltopdfwidgets (avoids native printing crash)
  Future<Uint8List> _htmlToPdfBytes(String html) async {
    final pd.PdfPageFormat pageFormat = getPageFormat();
    final arabicFont = await _loadArabicFont();
    final widgets = await HTMLToPdf().convert(
      _sanitizeHtmlForPdf(html),
      fontFallback: [arabicFont],
      fontResolver: (family, bold, italic) async => arabicFont,
    );
    final doc = pd.Document(
      theme: pd.ThemeData.withFont(
        base: arabicFont,
        bold: arabicFont,
        italic: arabicFont,
        boldItalic: arabicFont,
      ),
    );
    doc.addPage(
      pd.MultiPage(
        pageFormat: pageFormat,
        build: (pd.Context context) => widgets,
      ),
    );
    return doc.save();
  }

  //function for formatting invoice
  Future<void> printDocument(sellId, taxId, context, {invoice}) async {
    String invoice0 = (invoice != null)
        ? invoice
        : await InvoiceFormatter().generateInvoice(sellId, taxId, context);
    final pdfBytes = await _htmlToPdfBytes(invoice0);
    await Printing.layoutPdf(
      onLayout: (pd.PdfPageFormat format) async => pdfBytes,
    );
  }

  // //request permissions
  Future<Map<Permission, PermissionStatus>> requestAppPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.camera,
      // Permission.phone
    ].request();
    return statuses;
  }

  //job scheduler
  void jobScheduler() {
    if (Config().syncCallLog) {
      final cron = Cron();
      cron.schedule(
        Schedule.parse('*/${Config.callLogSyncDuration} * * * *'),
        () async {
          syncCallLogs();
        },
      );
    }
  }

  //post call_logs in api
  Future<void> syncCallLogs() async {
    if (await Permission.phone.status == PermissionStatus.granted) {
      if (Config().syncCallLog && await Helper().checkConnectivity()) {
        // ignore: unused_local_variable
        List recentLogs = [];
        //get last sync time
        var lastSync = await System().callLogLastSyncDateTime();
        //difference between time now and last sync
        int getLogBefore = (lastSync != null)
            ? DateTime.now().difference(DateTime.parse(lastSync.toString())).inMinutes
            : 1440;
        //set 'from' duration for call_log query
        // ignore: unused_local_variable
        int from = DateTime.now()
            .subtract(
              Duration(minutes: (getLogBefore > 1440) ? 1440 : getLogBefore),
            )
            .millisecondsSinceEpoch;
        try {
          // //fetch call_log
          // await CallLog.query(dateFrom: from).then((value) async {
          //   if (value.isNotEmpty) {
          //     value.forEach((element) {
          //       recentLogs.add(CallLogModel().createLog(element));
          //     });
          //     //     //save call_log in api
          //     await FollowUpApi()
          //         .syncCallLog({'call_logs': recentLogs}).then((value) async {
          //       if (value == true) {
          //         System().callLogLastSyncDateTime(true);
          //       }
          //     });
          //   }
          // });
        } catch (e) {}
      }
    }
  }

  //share invoice
  Future<void> savePdf(sellId, taxId, context, invoiceNo, {invoice}) async {
    String invoice0 = (invoice != null)
        ? invoice
        : await InvoiceFormatter().generateInvoice(sellId, taxId, context);
    var targetPath = await getTemporaryDirectory();
    var targetFileName = "invoice_no: ${Random().nextInt(100)}.pdf";
    final String path = targetPath.path + targetFileName;
    final pdfDocument = await _htmlToPdfBytes(invoice0);
    await File(path).writeAsBytes(pdfDocument);
    await Printing.sharePdf(bytes: pdfDocument, filename: targetFileName);
    //to get file path use generatedPdfFile.path
  }

  //fetch formatted business details
  Future<Map<String, dynamic>> getFormattedBusinessDetails() async {
    List business = await System().get('business');
    if (business.isEmpty) {
      return {
        'symbol': '',
        'name': '',
        'logo': Config().defaultBusinessImage,
        'currencyPrecision': Config.currencyPrecision,
        'quantityPrecision': Config.quantityPrecision,
        'taxLabel': '',
        'taxNumber': '',
      };
    }
    String? symbol = business[0]['currency']?['symbol'],
        name = business[0]['name'],
        logo = business[0]['logo'],
        taxLabel = business[0]['tax_label_1'],
        taxNumber = business[0]['tax_number_1'];
    int? currencyPrecision = business[0]['currency_precision'],
        quantityPrecision = business[0]['quantity_precision'];
    return {
      'symbol': symbol ?? '',
      'name': name ?? '',
      'logo': logo ?? Config().defaultBusinessImage,
      'currencyPrecision': currencyPrecision ?? Config.currencyPrecision,
      'quantityPrecision': quantityPrecision ?? Config.quantityPrecision,
      'taxLabel': (taxLabel != null) ? '$taxLabel : ' : '',
      'taxNumber': (taxNumber != null) ? taxNumber : '',
    };
  }

  //Fetch permission from database
  Future<bool> getPermission(String permissionFor) async {
    bool permission = false;
    await System().getPermission().then((value) {
      if (value[0] == 'all' || value.contains(permissionFor)) {
        permission = true;
      }
    });
    return permission;
  }

  //call widget
  Widget callDropdown(
    context,
    followUpDetails,
    List numbers, {
    required String type,
  }) {
    numbers.removeWhere((element) => element.toString() == 'null');
    return SizedBox(
      height: MySize.size36,
      child: PopupMenuButton<String>(
        icon: Icon(
          (type == 'call') ? MdiIcons.phone : MdiIcons.whatsapp,
          color: (type == 'call')
              ? themeData.colorScheme.primary
              : Colors.green,
        ),
        onSelected: (value) async {
          if (type == 'call') {
            await launchUrl(Uri.parse('tel:$value'));
          }

          if (type == 'whatsApp') {
            await launchUrl(
              Uri.parse("https://wa.me/$value"),
              mode: LaunchMode.externalApplication,
            );
          }
        },
        itemBuilder: (BuildContext context) {
          return numbers.map((item) {
            return PopupMenuItem<String>(
              value: item,
              child: Text('$item', style: TextStyle(color: Colors.black)),
            );
          }).toList();
        },
      ),
    );
  }

  //noData widget
  Column noDataWidget(context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: CachedNetworkImage(
            imageUrl: Config().noDataImage,
            errorWidget: (context, url, error) =>
                Lottie.asset('assets/lottie/empty.json'),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            AppLocalizations.of(context).translate('no_data'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.headlineSmall,
              fontWeight: 600,
              color: themeData.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
