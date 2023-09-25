import 'dart:convert';

import 'package:fiscal_printer/common/epson_model.dart';
import 'package:fiscal_printer/common/http.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

import '../common/espon_client.dart';

class EpsonXmlHttpClient extends BaseEpsonClient {
  EpsonXmlHttpClient(super.config);

  static const _xmlRoot = 's:Envelope';
  static const _xmlBody = 's:Body';
  static const _xmlResRoot = 'soapenv:Envelope';
  static const _xmlResBody = 'soapenv:Body';
  static const _xmlResponse = 'response';

  static final Map<CommandCode, Function> _commandCode = {
    CommandCode.OPEN_DRAWER: (XmlBuilder xmlBuilder, Command command) {
      xmlBuilder.element('openDrawer', attributes: {
        'operator': command.data?['operator'] ?? '1',
      });
    },
    CommandCode.QUERY_PRINTER_STATUS: (XmlBuilder xmlBuilder, Command command) {
      xmlBuilder.element('queryPrinterStatus', attributes: {
        'operator': command.data?['operator'] ?? '1',
        'statusType': command.data?['statusType'] ?? '0',
      });
    },
    CommandCode.REBOOT_WEB_SERVER: (XmlBuilder xmlBuilder, Command command) {
      xmlBuilder.element('rebootWebServer', attributes: {
        'operator': command.data?['operator'] ?? '1',
      });
    },
    CommandCode.RESET_PRINTER: (XmlBuilder xmlBuilder, Command command) {
      xmlBuilder.element('resetPrinter',
          attributes: {'operator': command.data?['operator'] ?? '1'});
    },
    CommandCode.GET_NATIVE_CODE_FUNCTION:
        (XmlBuilder xmlBuilder, Command command) {
      xmlBuilder.element('directIO', attributes: {
        'command': command.data?['command'] ?? '0000',
        'data': command.data?['operator'] ?? '01',
        'timeout': command.data?['timeout'] ?? '6000',
        'comment': command.data?['comment'] ?? '',
      });
    },
    CommandCode.DISPLAY_TEXT: (XmlBuilder xmlBuilder, Command command) {
      xmlBuilder.element('displayText', attributes: {
        'operator': command.data?['operator'] ?? '1',
        'data': command.data?['text'] ?? '',
      });
    },
    CommandCode.PRINT_CONTENT_BY_NUMBERS:
        (XmlBuilder xmlBuilder, Command command) {
      xmlBuilder.element('printContentByNumbers', attributes: {
        'operator': command.data?['operator'] ?? '1',
        'dataType': command.data?['dataType'] ?? DataType.COMMERCIAL_DOCS.name,
        'day': command.data?['day'] ?? '',
        'month': command.data?['month'] ?? '',
        'year': command.data?['year'] ?? '',
        'fromNumber': command.data?['fromNumber'] ?? '',
        'toNumber': command.data?['toNumber'] ?? '',
      });
    }
  };

  XmlDocumentFragment _convertReceiptToXmlDoc(Receipt receipt) {
    /// init
    final xmlBuilder = XmlBuilder();
    xmlBuilder.element('printerFiscalReceipt', nest: () {
      /// refund message
      if (receipt.refundMessage != null) {
        final message = receipt.refundMessage!.message ?? '',
            messageType = MessageType.ADDITIONAL_DESC.value;
        final attributes = {
          'message': message,
          'messageType': '$messageType',
          'operator': receipt.refundMessage?.operator ?? '',
        };
        attributes.removeWhere((key, value) => value.isEmpty);
        xmlBuilder.element('printRecMessage', attributes: attributes);
      }

      /// begin
      xmlBuilder.element('beginFiscalReceipt',
          attributes: {'operator': receipt.operator ?? '1'});

      /// orderNo
      if (receipt.orderNo != null) {
        final attributes = {
          'message': 'N.:${receipt.orderNo ?? ''}',
          'messageType': MessageType.ADDITIONAL_DESC.value.toString(),
          'operator': receipt.operator ?? '',
        };
        xmlBuilder.element('printRecMessage', attributes: attributes);
      }

      /// sales
      if (receipt.sales != null && receipt.sales!.isNotEmpty) {
        for (final sale in receipt.sales!) {
          /// sale or return
          if (sale.type == ItemType.HOLD) {
            /// item adjustment
            if (sale.operations != null && sale.operations!.isNotEmpty) {
              for (final operation in sale.operations!) {
                xmlBuilder.element('printRecItemAdjustment', attributes: {
                  'operator': operation.operator ?? '1',
                  'description': operation.description ?? '',
                  'department': operation.department ?? '1',
                  'justification': operation.justification ?? '1',
                  'amount': operation.amount?.toString() ?? '0',
                  'adjustmentType': (() {
                    switch (operation.type?.index) {
                      case 0:
                        return '0';
                      case 1:
                        return '3';
                      case 4:
                        return '5';
                      case 5:
                        return '8';
                      case 8:
                        return '10';
                      case 9:
                        return '11';
                      case 10:
                        return '12';
                      default:
                        return '0';
                    }
                  })(),
                });
              }
            }

            /// item
            xmlBuilder.element('printRecItem', attributes: {
              'operator': sale.operator ?? '1',
              'description': sale.description ?? '',
              'quantity': sale.quantity?.toString() ?? '0',
              'unitPrice': sale.unitPrice?.toString() ?? '0',
              'department': sale.department ?? '1',
              'justification': sale.justification ?? '1'
            });
          } else if (sale.type == ItemType.CANCEL) {
            /// void item adjustment
            if (sale.operations != null && sale.operations!.isNotEmpty) {
              for (final operation in sale.operations!) {
                xmlBuilder.element('printRecItemAdjustmentVoid',
                    attributes: {'operator': operation.operator ?? '1'});
              }
            }

            /// void item
            xmlBuilder.element('printRecItemVoid', attributes: {
              'operator': sale.operator ?? '1',
              'description': sale.description ?? '',
              'quantity': sale.quantity?.toString() ?? '0',
              'unitPrice': sale.unitPrice?.toString() ?? '0',
              'department': sale.department ?? '1',
              'justification': sale.justification ?? '1'
            });
          }
        }
      }

      /// refunds
      if (receipt.refunds != null && receipt.refunds!.isNotEmpty) {
        for (final refund in receipt.refunds!) {
          if (refund.type == ItemType.HOLD) {
            if (refund.operation != null) {
              xmlBuilder.element('printRecRefund', attributes: {
                'operator': refund.operator ?? '1',
                'description': refund.description ?? '',
                'operationType': (() {
                  switch (refund.type?.index) {
                    case 8:
                      return '10';
                    case 9:
                      return '11';
                    case 10:
                      return '12';
                    default:
                      return '10';
                  }
                })(),
                'amount': refund.amount?.toString() ?? '0',
                'department': refund.department ?? '1',
                'justification': refund.justification ?? '1'
              });
            } else {
              xmlBuilder.element('printRecRefund', attributes: {
                'operator': refund.operator ?? '1',
                'description': refund.description ?? '',
                'quantity': refund.quantity?.toString() ?? '1',
                'unitPrice': refund.unitPrice?.toString() ?? '0',
                'department': refund.department ?? '1',
                'justification': refund.justification ?? '1'
              });
            }
          } else if (refund.type == ItemType.CANCEL) {
            xmlBuilder.element('printRecRefundVoid',
                attributes: {'operator': refund.operation?.operator ?? '1'});
          }
        }
      }

      /// personalTaxCode
      if (receipt.personalTaxCode != null) {
        final message = receipt.personalTaxCode!.message ?? '',
            messageType = receipt.personalTaxCode!.messageType?.value ??
                MessageType.CUSTOMER_ID.value,
            index = receipt.personalTaxCode!.index ?? 1;
        xmlBuilder.element('printRecMessage', attributes: {
          'message': message,
          'messageType': '$messageType',
          'index': '$index',
          'operator': receipt.personalTaxCode?.operator ?? '1',
        });
      }

      /// subtotals
      if (receipt.subtotals != null && receipt.subtotals!.isNotEmpty) {
        for (final subtotal in receipt.subtotals!) {
          if (subtotal.type == ItemType.HOLD) {
            if (subtotal.operations != null &&
                subtotal.operations!.isNotEmpty) {
              for (final operation in subtotal.operations!) {
                xmlBuilder.element('printRecSubtotalAdjustment', attributes: {
                  'operator': operation.operator ?? '1',
                  'description': operation.description ?? '',
                  'amount': operation.amount?.toString() ?? '0',
                  'justification': operation.justification ?? '1',
                  'adjustmentType': (() {
                    switch (operation.type?.index) {
                      case 2:
                        return '1';
                      case 3:
                        return '2';
                      case 6:
                        return '6';
                      case 7:
                        return '7';
                      default:
                        return '1';
                    }
                  })(),
                });
              }
            }
            xmlBuilder.element('printRecSubtotal', attributes: {
              'operator': subtotal.operator ?? '1',
              'option': subtotal.option?.index.toString() ?? '',
            });
          } else if (subtotal.type == ItemType.CANCEL) {
            if (subtotal.operations != null &&
                subtotal.operations!.isNotEmpty) {
              for (final operation in subtotal.operations!) {
                xmlBuilder.element('printRecSubtotalAdjustVoid',
                    attributes: {'operator': operation.operator ?? '1'});
              }
            }
          }
        }
      }

      /// lottery
      if (receipt.lottery != null) {
        xmlBuilder.element('printRecLotteryID', attributes: {
          'operator': receipt.lottery!.operator ?? '1',
          'code': receipt.lottery!.code ?? ''
        });
      }
      // payments
      if (receipt.payments != null && receipt.payments!.isNotEmpty) {
        for (final payment in receipt.payments!) {
          xmlBuilder.element('printRecTotal', attributes: {
            'operator': payment.operator ?? '1',
            'description': payment.description ?? '',
            'payment': payment.payment?.toString() ?? '0',
            'paymentType': payment.paymentType?.index.toString() ?? '0',
            'index': payment.index ?? '1',
            'justification': payment.justification ?? '1'
          });
        }
      }
      // barCode
      if (receipt.barCode != null) {
        xmlBuilder.element('printBarCode', attributes: {
          'operator': receipt.barCode!.operator ?? '1',
          'position': receipt.barCode!.position ?? '900',
          'width': receipt.barCode!.width?.toString() ?? '1',
          'height': receipt.barCode!.height?.toString() ?? '1',
          'hRIPosition': receipt.barCode!.hriPosition ?? '0',
          'hRIFont': receipt.barCode!.hriFont ?? 'A',
          'codeType': receipt.barCode!.type ?? 'CODE128',
          'code': receipt.barCode!.data ?? ''
        });
      }

      /// qrCode
      if (receipt.qrCode != null) {
        xmlBuilder.element('printBarCode', attributes: {
          'operator': receipt.qrCode!.operator ?? '1',
          'qRCodeAlignment': receipt.qrCode!.alignment ?? '0',
          'qRCodeSize': receipt.qrCode!.size?.toString() ?? '1',
          'qRCodeErrorCorrection':
              receipt.qrCode!.errorCorrection?.toString() ?? '0',
          'codeType': receipt.qrCode!.type ?? 'CODE128',
          'code': receipt.qrCode!.data ?? ''
        });
      }

      /// graphicCoupon
      if (receipt.graphicCoupon != null) {
        xmlBuilder.element(
          'printGraphicCoupon',
          attributes: {
            'operator': receipt.graphicCoupon!.operator ?? '1',
            'graphicFormat': receipt.graphicCoupon!.format ?? 'B'
          },
        );
        xmlBuilder.text(receipt.graphicCoupon!.value ?? '');
      }

      /// end
      xmlBuilder.element('endFiscalReceipt',
          attributes: {'operator': receipt.operator ?? '1'});

      /// openDrawer
      if (receipt.openDrawer != null) {
        xmlBuilder.element('openDrawer',
            attributes: {'operator': receipt.openDrawer!.operator ?? '1'});
      }
    });
    return xmlBuilder.buildFragment();
  }

  /// convert `Report` to the object that printer server supports.
  /// @param report
  /// @returns
  XmlDocumentFragment _convertReportToXmlDoc(Report report) {
    final xmlBuilder = XmlBuilder();
    xmlBuilder.element('printerFiscalReport', nest: () {
      if (report.type == ReportType.DAILY_FINANCIAL_REPORT) {
        xmlBuilder.element('printXReport',
            attributes: {'operator': report.operator ?? '1'});
      } else if (report.type == ReportType.DAILY_FISCAL_CLOUSE) {
        xmlBuilder.element('printZReport', attributes: {
          'operator': report.operator ?? '1',
          'timeout': report.timeout?.toString() ?? '6000'
        });
      } else if (report.type == ReportType.ALL) {
        xmlBuilder.element('printXZReport', attributes: {
          'operator': report.operator ?? '1',
          'timeout': report.timeout?.toString() ?? '12000'
        });
      }
    });
    return xmlBuilder.buildFragment();
  }

  /// convert `Command` to the object that printer server supports.
  /// @param commands
  /// @returns
  XmlDocumentFragment _convertCommandToXmlDoc(List<Command> commands) {
    final xmlBuilder = XmlBuilder();
    xmlBuilder.element(
        (commands.length > 1 ? 'printerCommands' : 'printerCommand'), nest: () {
      for (Command command in commands) {
        if (_commandCode[command.code] != null) {
          _commandCode[command.code]!(xmlBuilder, command);
        }
      }
    });
    return xmlBuilder.buildFragment();
  }

  /// Request Message Format:
  /// <?xml version="1.0" encoding="utf-8"?>
  /// <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
  ///      <s:Body>
  ///          ...
  ///      </s:Body>
  /// </s:Envelope>
  /// [xmlDoc]
  /// [returns]
  String parseRequest(XmlDocumentFragment xmlDoc) {
    final xmlBuilder = XmlBuilder();
    xmlBuilder.declaration(encoding: "utf-8");
    xmlBuilder.element(EpsonXmlHttpClient._xmlRoot,
        attributes: {'xmlns:s': 'http://schemas.xmlsoap.org/soap/envelope/'},
        nest: () {
      xmlBuilder.element(EpsonXmlHttpClient._xmlBody, nest: xmlDoc);
    });
    return xmlBuilder.buildDocument().toXmlString(pretty: true);
  }

  /// send to the printer server
  /// [xmlDoc]
  /// [returns]
  Future<Response> send(XmlDocumentFragment xmlDoc) async {
    /// build the printer server url based on config
    final config = getConfig();

    var url = 'http://${config.host}/cgi-bin/fpmate.cgi';
    // var url = '${config.host}';
    var prefix = '?';
    if (config.deviceId != null) {
      url += '${prefix}devid=${config.deviceId}';
      prefix = '&';
    }
    if (config.timeout != null && config.timeout > 0) {
      url += '${prefix}timeout=${config.timeout}';
    }

    /// build xml string
    final xmlStr = parseRequest(xmlDoc);

    /// send
    final headers = {
      'Content-Type': 'text/xml;charset=utf-8',
    };

    final res = await HttpUtils().post(url, xmlStr, headers: headers);

    // add header
    final resXmlStr = res;
    final response = parseResponse(resXmlStr);
    response.original = Original(
      req: xmlStr,
      res: resXmlStr,
    );
    return response;
  }

  /// convert `Cancel` to the object that printer server supports.
  /// [cancel]
  /// @returns
  XmlDocumentFragment _convertCancelToXmlDoc(Cancel cancel) {
    final xmlBuilder = XmlBuilder();
    xmlBuilder.element('printerFiscalReceipt', nest: () {
      xmlBuilder.element('printRecMessage', attributes: {
        'operator': cancel.operator,
        'messageType': '4',
        'message':
            '${cancel.type.name} ${cancel.zRepNum} ${cancel.docNum} ${cancel.date} ${cancel.fiscalNum}'
      });
    });
    return xmlBuilder.buildFragment();
  }

  /// Response Message Format:
  /// <?xml version="1.0" encoding="utf-8"?>
  /// <soapenv:Envelope
  ///     xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  ///     <soapenv:Body>
  ///         <response success="true" code="" status="xxx">
  ///         </response>
  ///     </soapenv:Body>
  /// </soapenv:Envelope>
  /// [xmlStr]
  Response parseResponse(String xmlStr) {
    // create xml parser
    Map? response;
    // explicitArray: Always put child nodes in an array if true; otherwise an array is created only if there is more than one.
    // mergeAttrs: Merge attributes and child elements as properties of the parent, instead of keying attributes off a child attribute object.
    final parser = Xml2Json();
    // parse to object
    parser.parse(xmlStr);
    var xmlObj = parser.toParkerWithAttrs();
    var xmlJson = jsonDecode(xmlObj);
    if (xmlJson != null &&
        xmlJson[EpsonXmlHttpClient._xmlResRoot] != null &&
        xmlJson[EpsonXmlHttpClient._xmlResRoot]
                [EpsonXmlHttpClient._xmlResBody] !=
            null) {
      // get response data
      response = xmlJson[EpsonXmlHttpClient._xmlResRoot]
          [EpsonXmlHttpClient._xmlResBody][EpsonXmlHttpClient._xmlResponse];
    }
    return Response(
      ok: (response != null && (response['_success'] == 'true')) ? true : false,
      body: response,
    );
  }

  /// send Command to fiscal printer
  @override
  Future<Response> executeCommand(List<Command>? commands) {
    final xmlDoc = _convertCommandToXmlDoc(commands ?? []);
    return send(xmlDoc);
  }

  /// print a commercial refund/void document
  @override
  Future<Response> printCancel(Cancel cancel) {
    final xmlDoc = _convertCancelToXmlDoc(cancel);
    return send(xmlDoc);
  }

  /// commercial document
  @override
  Future<Response> printFiscalReceipt(Receipt receipt) {
    final xmlDoc = _convertReceiptToXmlDoc(receipt);
    return send(xmlDoc);
  }

  /// daily closure (X and Z reports)
  @override
  Future<Response> printFiscalReport(Report report) {
    final xmlDoc = _convertReportToXmlDoc(report);
    return send(xmlDoc);
  }
}
