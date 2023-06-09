part of 'custom_model.dart';

enum ItemType {
  HOLD,
  CANCEL,
}

enum EnableType {
  DISABLE,
  ABLE,
}

enum ReportType {
  DAILY_FINANCIAL_REPORT,
  DAILY_FISCAL_CLOUSE,
  ALL,
}

enum CancelType {
  REFUND,
  VOID,
}

enum AdjustmentType {
  SURCHARGE_DEPARTMENT(2),
  DISCOUNT_DEPARTMENT(3);

  final int value;
  const AdjustmentType(this.value);
}

enum SubtotalOpt {
  PRINT_DISPLAY,
  PRINT,
  DISPLAY,
}

enum PaymentType {
  CASH('1'),
  CHEQUE('1'),
  CREDIT_OR_CREDIT_CARD('3'),
  TICKET('5'),
  MULTI_TICKET,
  NOT_PAID,
  PAYMENT_DISCOUNT;

  final String? code;
  const PaymentType([this.code]);
}

enum CommandCode {
  OPEN_DRAWER,
  QUERY_PRINTER_STATUS,
  RESET_PRINTER,
  GET_NATIVE_CODE_FUNCTION,
  GET_INFO,
  DISPLAY_TEXT
}
