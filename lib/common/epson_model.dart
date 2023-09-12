part 'epson_enum.dart';

/// models
/// create by marks 2023/05/30
class Config {
  String host;
  num timeout;
  String deviceId;

  Config({
    required this.host,
    required this.timeout,
    required this.deviceId,
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
  OpenDrawer(this.operator);
}

class Receipt {
  String? orderNo;
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
  Message? refundMessage;
  Receipt({
    this.orderNo,
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
    this.refundMessage,
  });
}

class Report {
  ReportType? type;
  String? operator;
  num? timeout;
  OpenDrawer? openDrawer;
  Report({
    this.type,
    this.operator,
    this.timeout,
    this.openDrawer,
  });
}

class Cancel {
  String? orderNo;
  CancelType type;
  String zRepNum;
  String docNum;
  String date;
  String fiscalNum;
  String operator;

  Cancel({
    required this.type,
    required this.zRepNum,
    required this.docNum,
    required this.date,
    required this.fiscalNum,
    required this.operator,
    this.orderNo,
  });
}

// export type NonFiscal = {
//     operator?: string,
//     normal?: Normal,
//     barCode?: BarCode,
//     qrCode?: QrCode,
//     graphicCoupon?: GraphicCoupon,
// }

// export type Invoice = {
//     operator?: string,
//     docType?: string,
//     docNum?: string,
// } | Receipt

class Command {
  CommandCode code;
  Map<String, String>? data;

  Command(this.code, this.data);
}

class Sale {
  ItemType? type;
  List<Operation>? operations;
  String? operator;
  String? description;
  num? quantity;
  num? unitPrice;
  String? department;
  String? justification;
  Sale({
    this.type,
    this.operations,
    this.operator,
    this.description,
    this.quantity,
    this.unitPrice,
    this.department,
    this.justification,
  });
}

class Lottery {
  String? code;
  String? operator;
  Lottery({
    this.code,
    this.operator,
  });
}

class Message {
  /// represents the text to be printed or the customer ID. The maximum lengths are as follows:
  ///
  /// Message type 4 = Max 38 (or 37 with invoices)
  /// Message type 7 = Max 46 (although native protocol limit is 64)
  /// Message type 8 = Not applicable. Attribute can be omitted
  /// All other message types = Max 46
  String? message;

  /// defines the row type to be printed:
  /// 1 = Additional header. This type must be placed before the beginFiscalReceipt sub-element
  /// 2 = Trailer (after NUMERO CONFEZIONI and before NUMERO CASSA)
  /// 3 = Additional trailer (promo lines after NUMERO CASSA and before barcode or QR code)
  /// 4 = Additional description (in the body of the commercial document or direct invoice)
  /// 7 = Customer Id. Sets CustomerId field in www/json_files/rec.json file(The font has no relevance so the attribute can be omitted)
  /// 8 = Print or erase all EFT-POS transaction lines
  MessageType? messageType;

  /// indicates the line number:
  ///
  /// Range 1 to 9 for additional header (type 1)
  /// Range 1 to 99 for trailer and additional trailer descriptions (types 2 and 3)
  /// No meaning for additional row, Customer Id and EFT-POS transaction lines (types 4, 7 and 8)
  /// The attribute can be omitted
  num? index;

  /// attribute can be omitted when messageType is either 4, 7 or 8
  num? font;

  /// attribute is only relevant when messageType is 8:
  ///
  /// 0 = Print EFT-POS transaction lines
  /// 1 = Cancel EFT-POS transaction lines
  num? clearEFTPOSBuffer;

  String? operator;

  Message({
    this.message,
    this.messageType,
    this.index,
    this.font,
    this.clearEFTPOSBuffer,
    this.operator,
  });
}

class Refund {
  ItemType? type;
  String? optType;
  Operation? operation;
  String? operator;
  num? quantity;
  num? unitPrice;
  num? amount;
  String? description;
  String? department;
  String? justification;
  Refund({
    this.type,
    this.optType,
    this.operation,
    this.operator,
    this.quantity,
    this.unitPrice,
    this.amount,
    this.description,
    this.department,
    this.justification,
  });
}

class Subtotal {
  ItemType? type;
  SubtotalOpt? option;
  List<Operation>? operations;
  String? operator;

  Subtotal({
    this.type,
    this.option,
    this.operations,
    this.operator,
  });
}

class Payment {
  PaymentType? paymentType;
  String? index;
  String? operator;
  String? description;
  num? payment;
  String? justification;
  Payment({
    this.paymentType,
    this.index,
    this.operator,
    this.description,
    this.payment,
    this.justification,
  });
}

class Operation {
  OperationType? type;
  String? operator;
  num? amount;
  String? description;
  String? department;
  String? justification;
  Operation({
    this.type,
    this.operator,
    this.amount,
    this.description,
    this.department,
    this.justification,
  });
}

// export type Message = {
//     type: MessageType,
//     index?: string,
//     data?: string,
//     operator?: string,
// }

class Normal {
  String? font;
  String? data;
  String? operator;
  Normal({
    this.font,
    this.data,
    this.operator,
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
  String? code;
  String? operator;
  PersonTaxCode({
    this.code,
    this.operator,
  });
}

class Logo {
  String? location;
  String? index;
  String? option;
  String? format;
  String? value;
  String? operator;
  Logo({
    this.location,
    this.index,
    this.option,
    this.format,
    this.value,
    this.operator,
  });
}

class BarCode {
  String? position;
  num? width;
  num? height;
  String? hriPosition;
  String? hriFont;
  String? type;
  String? data;
  String? operator;

  BarCode({
    this.position,
    this.width,
    this.height,
    this.hriPosition,
    this.hriFont,
    this.type,
    this.data,
    this.operator,
  });
}

class QrCode {
  String? alignment;
  num? size;
  num? errorCorrection;
  String? type;
  String? data;
  String? operator;

  QrCode({
    this.alignment,
    this.size,
    this.errorCorrection,
    this.type,
    this.data,
    this.operator,
  });
}
