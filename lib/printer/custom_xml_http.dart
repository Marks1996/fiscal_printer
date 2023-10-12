import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

import '../common/custom_model.dart';
import '../common/custom_client.dart';

class CustomXmlHttpClient extends BaseCustomClient {
  CustomXmlHttpClient(super.config);

  static const _xmlResponse = 'response';
  static const _infoXmlResponse = 'infoResp';
  static const _xmlHeader = 'version="1.0" encoding="utf-8" standalone="true"';

  static final Map<CommandCode, Function> _commandCode = {
    CommandCode.OPEN_DRAWER: (XmlBuilder printerCommand, Command command) {
      printerCommand.element('openDrawer');
    },
    CommandCode.QUERY_PRINTER_STATUS:
        (XmlBuilder printerCommand, Command command) {
      printerCommand.element('queryPrinterStatus');
    },
    CommandCode.RESET_PRINTER: (XmlBuilder printerCommand, Command command) {
      printerCommand.element('resetPrinter', attributes: {
        'operator': command.data?['operator']?.toString() ?? '1',
      });
    },
    CommandCode.GET_NATIVE_CODE_FUNCTION:
        (XmlBuilder printerCommand, Command command) {
      printerCommand.element('directIO', attributes: {
        'command': command.data?['command'] ?? '0000',
        'data': command.data?['operator'] ?? '01',
      });
    },
    CommandCode.GET_INFO: (XmlBuilder printerCommand, Command command) {
      printerCommand.element('getInfo');
    },
    CommandCode.DISPLAY_TEXT: (XmlBuilder printerCommand, Command command) {
      printerCommand.element('displayText', attributes: {
        'data': command.data?['text'] ?? '',
      });
    },
  };

  /// Request Message Format:
  /// <?xml version: '1.0', encoding: 'utf-8', standalone: 'yes'?>
  /// <printerCommand>
  ///  <queryPrinterStatus></queryPrinterStatus>
  /// </printerCommand>
  /// [xmlDoc]
  /// [returns]
  String _parseRequest(XmlDocument xmlDoc) {
    final reqXmlStr = xmlDoc.toXmlString(pretty: true);
    return reqXmlStr;
  }

  /// Response Message Format:
  /// success = "true" | "false"; status = if error return "error code", else return '0';
  ///
  /// <?xml version="1.0" encoding="utf-8"?>
  ///   <response success="" status="">
  ///      <addInfo>
  ///          ...
  ///      </addInfo>
  ///   </response>
  /// [xmlStr]
  /// [isGetInfo] if exce
  Response parseResponse(String xmlStr, [bool isGetInfo = false]) {
    // create xml parser
    final parser = Xml2Json();
    // parse to object
    parser.parse(xmlStr);
    final jsonStr = parser.toParkerWithAttrs();
    final xmlObj = jsonDecode(jsonStr);
    Map? response;
    if (xmlObj != null && xmlObj.isNotEmpty) {
      // get response data
      response = xmlObj[isGetInfo
          ? CustomXmlHttpClient._infoXmlResponse
          : CustomXmlHttpClient._xmlResponse];
    }
    return Response(
      ok: response != null && response['_success'] == 'true',
      body: response,
    );
  }

  /// send to the printer server
  /// [xmlDoc]
  /// [returns]
  Future<Response> send(XmlDocument xmlDoc, [bool isGetInfo = false]) async {
    // build the printer server url based on config
    final config = getConfig();
    final url = Uri.http(config.host, 'xml/printer.htm');
    // 'http://${config.host}/xml/printer.htm';
    // build xml string
    final xmlStr = _parseRequest(xmlDoc);
    // send
    final authorization =
        'Basic ${base64.encode(utf8.encode('${config.fiscalId ?? ''}:${config.fiscalId ?? ''}'))}';
    final headers = {
      'Content-Type': 'text/xml;charset=utf-8',
      'authorization': authorization,
    };
    final http = HttpClient();
    try {
      final request = await http.postUrl(url);
      headers.forEach((key, value) {
        request.headers.set(key, value, preserveHeaderCase: true);
      });
      request.write(xmlStr);
      final response = await request.close();
      final data = await response.transform(utf8.decoder).join();

      // final data = res.data;
      final resXmlStr = data;
      final result = parseResponse(data, isGetInfo);
      result.original = Original(
        req: {
          'headers': headers,
          'url': url,
          'data': xmlStr,
        },
        res: {
          'statusCode': response.statusCode,
          'body': resXmlStr,
        },
      );
      return result;
    } catch (e) {
      return Response(
        ok: false,
        body: e,
        original: Original(req: xmlStr, res: null),
      );
    } finally {
      http.close();
    }
  }

  /// convert [Command] to the object that printer server supports.
  /// [commands]
  /// [returns]
  XmlDocument _convertCommandToXmlDoc(List<Command> commands) {
    final xmlBuilder = XmlBuilder();
    xmlBuilder.processing('xml', CustomXmlHttpClient._xmlHeader);
    xmlBuilder.element(
        commands.length > 1 ? 'printerCommands' : 'printerCommand', nest: () {
      for (final command in commands) {
        if (CustomXmlHttpClient._commandCode.containsKey(command.code)) {
          CustomXmlHttpClient._commandCode[command.code]!(xmlBuilder, command);
        }
      }
    });
    return xmlBuilder.buildDocument();
  }

  /// convert [Cancel] to the object that printer server supports.
  /// @param cancel
  /// @returns
  XmlDocument _convertCancelToXmlDoc(Cancel cancel) {
    final xmlBuilder = XmlBuilder();
    xmlBuilder.processing('xml', CustomXmlHttpClient._xmlHeader);

    var commonLabel = <String, String>{
      'docRefZ': cancel.docRefZ,
      'docRefNumber': cancel.docRefNumber,
      'docDate': cancel.docDate,
      'checkOnly': '0',
    };

    if (cancel.printPreview != null) {
      commonLabel['printPreview'] = cancel.printPreview!.name;
    }
    if (cancel.fiscalSerial != null) {
      commonLabel['fiscalSerial'] = cancel.fiscalSerial!;
    }
    if (cancel.codLottery != null) {
      commonLabel['codLottery'] = cancel.codLottery!;
    }
    xmlBuilder.element('printerFiscalReceipt', nest: () {
      /// orderNo
      if (cancel.orderNo != null) {
        final attributes = {
          'data': cancel.orderNo ?? '',
        };
        xmlBuilder.element('displayText', attributes: attributes);
      }
      // Return feasibility check
      if (cancel.checkOnly == EnableType.ABLE) {
        xmlBuilder.element('beginRtDocAnnulment', attributes: commonLabel);
      } else {
        // Execution of return document
        xmlBuilder.element('beginRtDocRefund', attributes: commonLabel);
        if (cancel.cancelRecItems != null &&
            cancel.cancelRecItems!.isNotEmpty) {
          for (var recItem in cancel.cancelRecItems!) {
            xmlBuilder.element('printRecItem',
                attributes: {
                  'description': recItem.description ?? '',
                  'quantity': recItem.quantity.toString(),
                  'unitPrice': recItem.unitPrice.toInt().toString(),
                  'department': recItem.department?.toString() ?? '1',
                },
                isSelfClosing: false);
          }
        }
      }
      // end
      xmlBuilder.element('endFiscalReceiptCut', isSelfClosing: false);
    });
    return xmlBuilder.buildDocument();
  }

  /// convert `Fiscal.Report` to the object that printer server supports.
  /// [report]
  /// [returns]
  XmlDocument _convertReportToXmlDoc(Report report) {
    final xmlBuilder = XmlBuilder();
    xmlBuilder.processing('xml', CustomXmlHttpClient._xmlHeader);
    xmlBuilder.element('printerFiscalReport', nest: () {
      if (report.type == ReportType.DAILY_FINANCIAL_REPORT) {
        xmlBuilder.element('printXReport', attributes: {
          'operator': report.operator?.toString() ?? '1',
        });
      } else if (report.type == ReportType.DAILY_FISCAL_CLOUSE) {
        xmlBuilder.element('printZReport', attributes: {
          'operator': report.operator?.toString() ?? '1',
          'timeout': report.timeout?.toString() ?? '6000',
        });
      } else if (report.type == ReportType.ALL) {
        xmlBuilder.element('printXZReport', attributes: {
          'operator': report.operator?.toString() ?? '1',
          'timeout': report.timeout?.toString() ?? '12000',
        });
      }
    });
    return xmlBuilder.buildDocument();
  }

  /// convert [Receipt] to the object that xml2js builder and cgi server supports.
  /// [receipt]
  /// [returns]
  XmlDocument _convertReceiptToXmlDoc(Receipt receipt) {
    // init
    final xmlBuilder = XmlBuilder();
    xmlBuilder.processing('xml', CustomXmlHttpClient._xmlHeader);

    xmlBuilder.element('printerFiscalReceipt', nest: () {
      // begin
      xmlBuilder.element('beginFiscalReceipt');

      if (receipt.beginDisplayText != null) {
        xmlBuilder.element('displayText',
            attributes: {'data': receipt.beginDisplayText?.data ?? ''});
      }
      // lottery
      if (receipt.lottery != null && receipt.lottery!.code.isNotEmpty) {
        xmlBuilder.element('setLotteryCode',
            attributes: {'code': receipt.lottery!.code});
      }
      // sales item
      if (receipt.sales != null && receipt.sales!.isNotEmpty) {
        /// orderNo
        if (receipt.orderNo != null) {
          final attributes = {
            'message': 'N.:${receipt.orderNo ?? ''}',
            'messageType': '4',
            'font': '1',
          };
          xmlBuilder.element('printRecMessage', attributes: attributes);
        }
        for (final Sale sale in receipt.sales!) {
          final commonSale = <String, String>{
            'description': sale.description ?? '',
            'quantity': sale.quantity.toString(),
            'unitPrice': sale.unitPrice.toInt().toString(),
            'department': sale.department?.toString() ?? '1',
          };
          if (sale.idVat != null) {
            commonSale['idVat'] = sale.idVat?.toString() ?? '22';
          }
          // sale or return
          if (sale.type == ItemType.HOLD) {
            // item
            xmlBuilder.element('printRecItem', attributes: commonSale);
            // item adjustment
            if (sale.operations != null && sale.operations!.isNotEmpty) {
              for (final operation in sale.operations!) {
                final recItemAdjustment = <String, String>{
                  'description': operation.description ?? '',
                  'department': operation.department?.toString() ?? '1',
                  'amount': operation.amount.toInt().toString(),
                  // only values 2 or 3 are allowed
                  'adjustmentType':
                      [2, 3].contains(operation.adjustmentType.value)
                          ? operation.adjustmentType.value.toString()
                          : '3',
                };
                if (operation.idVat != null) {
                  recItemAdjustment['idVat'] =
                      operation.idVat?.toString() ?? '22';
                }

                xmlBuilder.element('printRecItemAdjustment',
                    attributes: recItemAdjustment);
              }
            }
          } else if (sale.type == ItemType.CANCEL) {
            // void item
            xmlBuilder.element('printRecItemVoid', attributes: commonSale);
            // void item adjustment
            // if (sale.operations && sale.operations.length > 0) {
            //     for (const operation of sale.operations) {
            //         printerFiscalReceipt.ele('printRecItemAdjustmentVoid');
            //     }
            // }
          }
        }
      }
      // refunds
      if (receipt.refunds != null && receipt.refunds!.isNotEmpty) {
        for (Refund refund in receipt.refunds!) {
          if (refund.type == ItemType.HOLD) {
            final recRefund = <String, String>{
              'description': refund.description ?? '',
              'quantity': refund.quantity.toString(),
              'unitPrice': refund.unitPrice.toInt().toString(),
              'department': refund.department?.toString() ?? '1',
            };
            if (refund.idVat != null) {
              (recRefund['idVat'] = refund.idVat?.toString() ?? '22');
            }
            xmlBuilder.element('printRecRefund', attributes: recRefund);
          } else if (refund.type == ItemType.CANCEL) {
            xmlBuilder.element('printRecRefundVoid');
          }
        }
      }
      // personalTaxCode
      if (receipt.personalTaxCode != null) {
        final message = receipt.personalTaxCode?.message ?? '',
            messageType = receipt.personalTaxCode?.messageType ?? '3',
            font = receipt.personalTaxCode?.font ?? 'B';
        xmlBuilder.element('printRecMessage', attributes: {
          'message': message,
          'messageType': messageType,
          'font': font
        });
      }
      // subtotals
      if (receipt.subtotals != null && receipt.subtotals!.isNotEmpty) {
        for (final subtotal in receipt.subtotals!) {
          if (subtotal.type == ItemType.HOLD) {
            if (subtotal.operations != null &&
                subtotal.operations!.isNotEmpty) {
              for (final operation in subtotal.operations!) {
                final recSubtotalAdjustment = <String, String>{
                  'description': operation.description ?? '',
                  'amount': operation.amount.toInt().toString(),
                  'adjustmentType':
                      [2, 3].contains(operation.adjustmentType.value)
                          ? operation.adjustmentType.value.toString()
                          : '3'
                };
                if (operation.idVat != null) {
                  recSubtotalAdjustment['idVat'] =
                      operation.idVat?.toString() ?? '22';
                }
                xmlBuilder.element('printRecSubtotalAdjustment',
                    attributes: recSubtotalAdjustment);
              }
            }
            xmlBuilder.element('printRecSubtotal');
          } else if (subtotal.type == ItemType.CANCEL) {
            if (subtotal.operations != null &&
                subtotal.operations!.isNotEmpty) {
              for (final operation in subtotal.operations!) {
                xmlBuilder.element('printRecSubtotalAdjustVoid');
              }
            }
          }
        }
      }
      // payments
      if (receipt.payments != null && receipt.payments!.isNotEmpty) {
        for (final payment in receipt.payments!) {
          xmlBuilder.element('printRecTotal', attributes: {
            'description': payment.description ?? '',
            'payment': payment.payment?.toInt().toString() ?? '0',
            'paymentType': payment.paymentType?.code ?? '0',
          });
        }
      }

      // barCode
      if (receipt.barCode != null) {
        xmlBuilder.element('printBarCode', attributes: {
          'operator': receipt.barCode?.operator ?? '1',
          'position': receipt.barCode?.position ?? '900',
          'width': receipt.barCode?.width?.toString() ?? '1',
          'height': receipt.barCode?.height?.toString() ?? '1',
          'hRIPosition': receipt.barCode!.hriPosition ?? '0',
          'hRIFont': receipt.barCode?.hriFont ?? 'A',
          'codeType': receipt.barCode?.type ?? 'CODE128',
          'code': receipt.barCode?.data ?? ''
        });
      }
      // qrCode
      if (receipt.qrCode != null) {
        xmlBuilder.element('printBarCode', attributes: {
          'operator': receipt.qrCode?.operator ?? '1',
          'qRCodeAlignment': receipt.qrCode?.alignment ?? '0',
          'qRCodeSize': receipt.qrCode?.size?.toString() ?? '1',
          'qRCodeErrorCorrection':
              receipt.qrCode?.errorCorrection?.toString() ?? '0',
          'codeType': receipt.qrCode?.type ?? 'CODE128',
          'code': receipt.qrCode?.data ?? ''
        });
      }
      // graphicCoupon
      if (receipt.graphicCoupon != null) {
        xmlBuilder.element(
          'printGraphicCoupon',
          attributes: {
            'operator': receipt.graphicCoupon?.operator ?? '1',
            'graphicFormat': receipt.graphicCoupon?.format ?? 'B'
          },
          nest: receipt.graphicCoupon?.value ?? '',
        );
      }
      if (receipt.endDisplayText != null) {
        xmlBuilder.element('displayText',
            attributes: {'data': receipt.endDisplayText?.data ?? ''});
      }
      // end
      xmlBuilder.element('endFiscalReceiptCut');
    });
    return xmlBuilder.buildDocument();
  }

  /// send Command to fiscal printer
  @override
  Future<Response> executeCommand(List<Command> commands) async {
    final xmlDoc = _convertCommandToXmlDoc(commands);
    final isGetInfo =
        commands.isNotEmpty && commands[0].code == CommandCode.GET_INFO;
    return send(xmlDoc, isGetInfo);
  }

  /// print a commercial refund/void document
  @override
  Future<Response> printCancel(Cancel cancel) {
    final xmlDoc = _convertCancelToXmlDoc(cancel);
    return send(xmlDoc);
  }

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
