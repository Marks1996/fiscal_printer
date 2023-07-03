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
  dynamic request;

  Response({
    required this.ok,
    this.body,
    this.original,
    this.request,
  });

  Map<String, dynamic> toJson() => {
        'ok': ok,
        'body': body,
        'original': original?.toJson(),
        'request': request,
      };
}

class Original {
  dynamic req;
  dynamic res;

  Original({
    required this.req,
    required this.res,
  });

  Map<String, dynamic> toJson() => {
        'req': req,
        'res': res,
      };
}

class OpenDrawer {
  String? operator;

  OpenDrawer({this.operator});

  toJson() => {
        'operator': operator,
      };
}

class Sale {
  ItemType type;
  List<Operation>? operations;
  String? description;
  int quantity;
  num unitPrice;
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
  toJson() => {
        'type': type,
        'operations': operations?.map((e) => e.toJson()).toList(),
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'department': department,
        'idVat': idVat,
      };
}

class CommonSale {
  String? description;
  int quantity;
  num unitPrice;
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

  toJson() => {
        'code': code,
      };
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

  toJson() => {
        'message': message,
        'messageType': messageType,
        'font': font,
      };
}

class DisplayText {
  String data;

  DisplayText({required this.data});

  toJson() => {'data': data};
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
  toJson() => {
        'type': type,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'department': department,
        'idVat': idVat,
      };
}

class Subtotal {
  ItemType type;
  List<Operation>? operations;

  Subtotal({
    required this.type,
    this.operations,
  });

  /// toJson method
  toJson() => {
        'type': type,
        'operations': operations?.map((e) => e.toJson()),
      };
}

class Payment {
  PaymentType? paymentType;
  String? description;
  num? payment;
  int? paymentQty;

  Payment({
    this.paymentType,
    this.description,
    this.payment,
    this.paymentQty,
  });

  toJson() => {
        'paymentType': paymentType?.name,
        'description': description,
        'payment': payment,
        'paymentQty': paymentQty,
      };
}

class Operation {
  AdjustmentType adjustmentType;
  num amount;
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

  toJson() => {
        'adjustmentType': adjustmentType.name,
        'amount': amount,
        'description': description,
        'department': department,
        'idVat': idVat,
        'quantity': quantity,
      };
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
  toJson() => {
        'format': format,
        'value': value,
        'operator': operator,
      };
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

  BarCode({
    required this.data,
    this.position,
    this.width,
    this.height,
    this.hriPosition,
    this.hriFont,
    this.type,
    this.operator,
  });
  toJson() => {
        'data': data,
        'position': position,
        'width': width,
        'height': height,
        'hriPosition': hriPosition,
        'hriFont': hriFont,
        'type': type,
        'operator': operator,
      };
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

  toJson() => {
        'data': data,
        'alignment': alignment,
        'size': size,
        'errorCorrection': errorCorrection,
        'type': type,
        'operator': operator,
      };
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

  /// toJson method
  Map toJson() => {
        'operator': operator,
        'sales': sales?.map((e) => e.toJson()),
        'lottery': lottery?.toJson(),
        'refunds': refunds?.map((e) => e.toJson()),
        'subtotals': subtotals?.map((e) => e.toJson()),
        'payments': payments?.map((e) => e.toJson()),
        'barCode': barCode?.toJson(),
        'qrCode': qrCode?.toJson(),
        'graphicCoupon': graphicCoupon?.toJson(),
        'openDrawer': openDrawer?.toJson(),
        'personalTaxCode': personalTaxCode?.toJson(),
        'beginDisplayText': beginDisplayText?.toJson(),
        'endDisplayText': endDisplayText?.toJson(),
      };
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
