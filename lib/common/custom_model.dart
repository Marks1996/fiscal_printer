part 'custom_enum.dart';

class Config {
  String host;
  String? fiscalId;

  Config({
    required this.host,
    this.fiscalId,
  });
}

class Response {
  bool ok;
  dynamic body;
  Original? original;

  Response({
    required this.ok,
    this.body,
    this.original,
  });
}

class Original {
  dynamic req;
  dynamic res;

  Original({
    required this.req,
    required this.res,
  });
}

class OpenDrawer {
  String? operator;

  OpenDrawer({this.operator});
}

class Sale {
  ItemType type;
  List<Operation>? operations;
  String? description;
  int quantity;
  double unitPrice;
  int? department;
  int? idVat;

  Sale({
    required this.type,
    this.operations,
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.department,
    this.idVat,
  });
}

class CommonSale {
  String? description;
  int quantity;
  double unitPrice;
  int? department;
  int? idVat;

  CommonSale({
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.department,
    this.idVat,
  });
}

class Lottery {
  String code;

  Lottery({required this.code});
}

class Message {
  /// Line of text to be printed (maximum 42 characters).
  /// The maximum lengths are set based on the "font" attribute.
  /// Additional characters are truncated.
  String message;

  /// Type of line to print:
  ///
  /// 1 = additional descriptive line (sales body)
  /// 2 = additional line in payments
  /// 3 = line issued after payment
  /// 4 = courtesy line
  String messageType;

  /// Font type:
  /// 1 = normal
  /// 2 = bold
  /// 3 = 42 characters long
  /// 4 = double height
  /// 5 = double width
  /// 6 = italics
  /// 7 = length 42, double height
  /// 8 = length 42, bold
  /// 9 = length 42, bold, double height
  /// C = normal, used for printing the customer in the tax invoice
  /// P = normal, used to print the return receipt number in a credit note
  /// B = normal, used for printing the customer ID (Scontrino Parlante)
  String font;

  Message({
    required this.message,
    required this.messageType,
    required this.font,
  });
}

class DisplayText {
  String data;

  DisplayText({required this.data});
}

class Refund {
  ItemType type;
  String? description;
  int quantity;
  double unitPrice;
  int? department;
  int? idVat;

  Refund({
    required this.type,
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.department,
    this.idVat,
  });
}

class Subtotal {
  ItemType type;
  List<Operation>? operations;

  Subtotal({
    required this.type,
    this.operations,
  });
}

class Payment {
  PaymentType? paymentType;
  String? description;
  double? payment;
  int? paymentQty;

  Payment({
    this.paymentType,
    this.description,
    this.payment,
    this.paymentQty,
  });
}

class Operation {
  AdjustmentType adjustmentType;
  double amount;
  String? description;
  int? department;
  int? idVat;
  int? quantity;

  Operation({
    required this.adjustmentType,
    required this.amount,
    this.description,
    this.department,
    this.idVat,
    this.quantity,
  });
}

class GraphicCoupon {
  String? format;
  String? value;
  String? operator;

  GraphicCoupon({
    this.format,
    this.value,
    this.operator,
  });
}

class PersonTaxCode {
  String code;

  PersonTaxCode({required this.code});
}

class BarCode {
  String? position;
  int? width;
  int? height;
  String? hriPosition;
  String? hriFont;
  String? type;
  String data;
  String? operator;

  BarCode(
      {required this.data,
      this.position,
      this.width,
      this.height,
      this.hriPosition,
      this.hriFont,
      this.type,
      this.operator});
}

class QrCode {
  String? alignment;
  int? size;
  int? errorCorrection;
  String? type;
  String data;
  String? operator;

  QrCode(
      {required this.data,
      this.alignment,
      this.size,
      this.errorCorrection,
      this.type,
      this.operator});
}

class Receipt {
  String? operator;
  List<Sale>? sales;
  Lottery? lottery;
  List<Refund>? refunds;
  List<Subtotal>? subtotals;
  List<Payment>? payments;
  BarCode? barCode;
  QrCode? qrCode;
  GraphicCoupon? graphicCoupon;
  OpenDrawer? openDrawer;
  Message? personalTaxCode;
  DisplayText? beginDisplayText;
  DisplayText? endDisplayText;

  Receipt({
    this.operator,
    this.sales,
    this.lottery,
    this.refunds,
    this.subtotals,
    this.payments,
    this.barCode,
    this.qrCode,
    this.graphicCoupon,
    this.openDrawer,
    this.personalTaxCode,
    this.beginDisplayText,
    this.endDisplayText,
  });
}

class Report {
  ReportType type;
  String? operator;
  int? timeout;
  OpenDrawer? openDrawer;

  Report({
    required this.type,
    this.operator,
    this.timeout,
    this.openDrawer,
  });
}

class Cancel {
  String docRefZ;
  String docRefNumber;
  String docDate;
  EnableType? printPreview;
  String? fiscalSerial;
  EnableType? checkOnly;
  String? codLottery;
  List<CommonSale>? cancelRecItems;

  Cancel({
    required this.docRefZ,
    required this.docRefNumber,
    required this.docDate,
    this.printPreview,
    this.fiscalSerial,
    this.checkOnly,
    this.codLottery,
    this.cancelRecItems,
  });
}

class Command {
  CommandCode code;
  Map<String, dynamic>? data;

  Command({
    required this.code,
    this.data,
  });
}
