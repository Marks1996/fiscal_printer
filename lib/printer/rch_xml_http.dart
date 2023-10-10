import 'dart:convert';
import 'dart:io';
import 'package:fiscal_printer/common/rch_client.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

import '../common/rch_model.dart';

class RchXmlHttpClient extends BaseRchClient {
  static final xmlRoot = 'Service';
  static final xmlBody = 'cmd';
  static final xmlReq = 'Request';

  RchXmlHttpClient(super.config);

  /// send Command to fiscal printer
  /// commands
  @override
  Future<Result> executeCommand(List<String> commands) {
    final xmlDoc = _convertCommandToXmlDoc(commands);
    return send(xmlDoc);
  }

  // *********************
  // Emitter
  // *********************

  /// send to the printer server
  Future<Result> send(XmlDocument xmlDoc) async {
    // build the printer server url based on config
    final config = getConfig();
    final url = Uri.http(config.host, 'service.cgi');
    // 'http://${config.host}/service.cgi';
    // build xml string
    final xmlStr = _parseRequest(xmlDoc);

    /// send
    final headers = {
      'Content-Type': 'application/xml',
      'Content-Length': xmlStr.length,
    };

    try {
      final http = HttpClient();
      final request = await http.postUrl(url);
      headers.forEach((key, value) {
        request.headers.set(key, value, preserveHeaderCase: true);
      });
      request.write(xmlStr);
      final response = await request.close();
      final data = await response.transform(utf8.decoder).join();
      // add header
      final resXmlStr = data;

      final result = await _parseResponse(resXmlStr);
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
      return Result(
        ok: false,
        body: e,
        original: Original(
          req: xmlStr,
          res: null,
        ),
      );
    }
  }

  // *********************
  // Parsers
  // *********************

  ///  Request Message Format:
  ///  <?xml version="1.0" encoding="utf-8"?>
  ///  <Service>
  ///       <cmd>
  ///           ...
  ///       </cmd>
  ///  </Service>
  String _parseRequest(XmlDocument xmlDoc) {
    final reqXmlStr = xmlDoc.toXmlString(pretty: true);
    return reqXmlStr;
  }

  ///  Response Message Format:
  ///   <?xml version="1.0" encoding="utf-8"?>
  ///   <Service>
  ///        <Request>
  ///            <errorCode>0</errorCode>
  ///               <printerError>0</printerError>
  ///               <paperEnd>0</paperEnd>
  ///               <coverOpen>0</coverOpen>
  ///               <lastCmd>2</lastCmd>
  ///               <busy>0</busy>
  ///        </Request>
  ///   </Service>
  Future<Result> _parseResponse(String xmlStr) async {
    // create xml parser
    Map? response;
    // explicitArray: Always put child nodes in an array if true; otherwise an array is created only if there is more than one.
    // mergeAttrs: Merge attributes and child elements as properties of the parent, instead of keying attributes off a child attribute object.
    final parser = Xml2Json();
    // parse to object
    parser.parse(xmlStr);
    var xmlObj = parser.toParkerWithAttrs();
    var xmlJson = jsonDecode(xmlObj);

    if (xmlJson != null) {
      // get response data
      response = xmlJson[xmlRoot];
    }
    return Result(
      ok: response != null &&
          response[xmlReq] != null &&
          response[xmlReq]['errorCode'] == '0',
      body: response ?? {},
    );
  }

  /// *********************
  /// Converters
  /// *********************

  ///  convert `commands` to the object that printer server supports.
  ///  commands
  XmlDocument _convertCommandToXmlDoc(List<String> commands) {
    final xmlBuilder = XmlBuilder();
    xmlBuilder.processing('xml', 'version="1.0" encoding="utf-8"');
    xmlBuilder.element(xmlRoot, nest: () {
      for (final command in commands) {
        xmlBuilder.element(xmlBody, nest: () {
          xmlBuilder.text(command);
        });
      }
    });
    return xmlBuilder.buildDocument();
  }
}
