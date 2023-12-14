import 'dart:convert';
import 'dart:io';

import 'package:fiscal_printer/common/axon_client.dart';
import 'package:fiscal_printer/common/axon_model.dart';

class AxonSf20HttpClient extends BaseAxonClient {
  AxonSf20HttpClient(super.config);

  /// 客显显示
  /// [ln1] 第一行
  /// [ln2] 第二行
  @override
  Future<Result> dispWrite(String ln1, String ln2) async {
    final config = getConfig();
    final url =
        Uri.parse('http://${config.host}/_io?cmd=1&ln1=${ln1}&ln2=${ln2}');
    return await _send(url);
  }

  /// 发送键盘代码
  @override
  Future<Result> keybWrite(String code) async {
    final config = getConfig();
    final url = Uri.http(config.host, '_io', {'cmd': '2', 'code': code});
    return await _send(url);
  }

  /// 发送功能键
  @override
  Future<Result> operWrite(String code, String idx) async {
    final config = getConfig();
    final url =
        Uri.http(config.host, '_io', {'cmd': '3', 'code': code, 'idx': idx});
    return await _send(url);
  }

  /// 发送 SF20 协议命令
  @override
  Future<Result> protoCmd(int js, String pkt) async {
    final config = getConfig();
    final url = Uri.http(
        config.host, '_io', {'cmd': '4', 'js': js.toString(), 'pkt': pkt});
    return await _send(url);
  }

  ///加载多个 SF20 协议命令，以便后续打印。
  @override
  Future<Result> sendTicketCmd(String cmd) async {
    final config = getConfig();
    final url = Uri.http(config.host, '_fileio', {'cmd': '3'});
    return await _send(url, method: 'POST', cmd: cmd);
  }

  /// 获取有关税务登记状态的信息
  @override
  Future<Result> status() async {
    final config = getConfig();
    final url = Uri.http(config.host, '_io', {'cmd': '0'});
    return await _send(url);
  }

  /// 执行之前用 SEND_TICKET_CMD 加载的命令序列
  @override
  Future<Result> ticketCmd(int js) async {
    final config = getConfig();
    final url = Uri.http(config.host, '_io', {'cmd': '5', 'js': js.toString()});
    return await _send(url);
  }

  /// Send CMD
  Future<Result> _send(
    Uri url, {
    String method = 'GET',
    String? cmd,
  }) async {
    final Result result = Result(
      ok: true,
    );
    var headers = <String, Object>{'Content-Type': 'text/plain'};
    if (cmd != null) headers['Content-Length'] = cmd.length;
    final http = HttpClient();
    try {
      final request = await http.openUrl(method, url);
      headers.forEach((key, value) {
        request.headers.set(key, value, preserveHeaderCase: true);
      });
      if (cmd != null) request.write(cmd);
      final response = await request.close();
      final data = await response.transform(utf8.decoder).join();
      result.body = data;
      result.original = Original(
        req: {
          'headers': headers,
          'url': url,
          'data': cmd,
        },
        res: {
          'statusCode': response.statusCode,
          'body': data,
        },
      );
      return result;
    } catch (e) {
      return Result(
        ok: false,
        body: e,
        original: Original(req: headers, res: null),
      );
    } finally {
      http.close();
    }
  }
}
