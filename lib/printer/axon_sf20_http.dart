import 'dart:io';

import 'package:fiscal_printer/common/axon_client.dart';
import 'package:fiscal_printer/common/axon_model.dart';
import 'package:dio/dio.dart' hide Response;

class AxonSf20HttpClient extends BaseAxonClient {
  AxonSf20HttpClient(super.config);

  /// 客显显示
  /// [ln1] 第一行
  /// [ln2] 第二行
  @override
  Future<Response> dispWrite(String ln1, String ln2) async {
    final config = getConfig();
    final url =
        Uri.parse('http://${config.host}/_io?cmd=1&ln1=${ln1}&ln2=${ln2}');
    return await _send(url);
  }

  /// 发送键盘代码
  @override
  Future<Response> keybWrite(String code) async {
    final config = getConfig();
    final url = Uri.http(config.host, '_io', {'cmd': '2', 'code': code});
    return await _send(url);
  }

  /// 发送功能键
  @override
  Future<Response> operWrite(String code, String idx) async {
    final config = getConfig();
    final url =
        Uri.http(config.host, '_io', {'cmd': '3', 'code': code, 'idx': idx});
    return await _send(url);
  }

  /// 发送 SF20 协议命令
  @override
  Future<Response> protoCmd(int js, String pkt) async {
    final config = getConfig();
    final url = Uri.http(
        config.host, '_io', {'cmd': '4', 'js': js.toString(), 'pkt': pkt});
    return await _send(url);
  }

  ///加载多个 SF20 协议命令，以便后续打印。
  @override
  Future<Response> snedTicketCmd(String cmd) async {
    final config = getConfig();
    final url = Uri.http(config.host, '_fileio', {'cmd': '3'});
    return await _send(url, method: 'POST', cmd: cmd);
  }

  /// 获取有关税务登记状态的信息
  @override
  Future<Response> status() async {
    final config = getConfig();
    final url = Uri.http(config.host, '_io', {'cmd': '0'});
    return await _send(url);
  }

  /// 执行之前用 SEND_TICKET_CMD 加载的命令序列
  @override
  Future<Response> ticketCmd(int js) async {
    final config = getConfig();
    final url = Uri.http(config.host, '_io', {'cmd': '5', 'js': js.toString()});
    return await _send(url);
  }

  /// Send CMD
  Future<Response> _send(
    Uri url, {
    String method = 'GET',
    String? cmd,
  }) async {
    try {
      final Response response = Response(
        ok: true,
      );
      final headers = {
        'Content-Type': 'text/plain',
      };
      final options = BaseOptions()..headers.addAll(headers);
      final http = Dio(options);

      if (method == "POST") {
        final res = await http.post(
          url.toString(),
          data: cmd,
          options: Options()
            ..headers?.addAll({'content-length': '${cmd!.length}'}),
        );
        response.body = '${res.statusCode}:${res.statusMessage}';
        response.original = Original(
          req: res.requestOptions.toString(),
          res: res.data,
        );
        return response;
      } else {
        final res = await http.get(url.toString());
        response.body = res.data;
        response.original = Original(
          req: url,
          res: res.data,
        );
        return response;
      }
    } catch (e) {
      return Response(
        ok: false,
        body: e,
        original: Original(req: url, res: null),
      );
    }
  }
}
