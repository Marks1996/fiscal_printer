import 'dart:convert';

import 'package:fiscal_printer/common/axon_client.dart';
import 'package:fiscal_printer/common/axon_model.dart';
import 'package:http/http.dart' as http;

class AxonSf20HttpClient extends BaseAxonClient {
  AxonSf20HttpClient(super.config);

  /// 客显显示
  /// [ln1] 第一行
  /// [ln2] 第二行
  @override
  Future<Response> dispWrite(String ln1, String ln2) async {
    return await _send('_io', params: {
      'cmd': 1,
      'ln1': ln1,
      'ln2': ln2,
    });
  }

  /// 发送键盘代码
  @override
  Future<Response> keybWrite(String code) async {
    return await _send('_io', params: {'cmd': 2, 'code': code});
  }

  /// 发送功能键
  @override
  Future<Response> operWrite(String code, String idx) async {
    return await _send('_io', params: {'cmd': 3, 'code': code, 'idx': idx});
  }

  /// 发送 SF20 协议命令
  @override
  Future<Response> protoCmd(int js, String pkt) async {
    return await _send('_io', params: {'cmd': 4, 'js': js, 'pkt': pkt});
  }

  ///加载多个 SF20 协议命令，以便后续打印。
  @override
  Future<Response> snedTicketCmd(String cmd) async {
    return await _send(
      '_fileio',
      params: {
        'cmd': 3,
      },
      method: 'POST',
      cmd: cmd,
    );
  }

  /// 获取有关税务登记状态的信息
  @override
  Future<Response> status() async {
    return await _send('_io', params: {'cmd': 0});
  }

  /// 执行之前用 SEND_TICKET_CMD 加载的命令序列
  @override
  Future<Response> ticketCmd(int js) async {
    return await _send('_io', params: {'cmd': 5, 'js': js});
  }

  /// Send CMD
  Future<Response> _send(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? params,
    String? cmd,
  }) async {
    // build the printer server url based on config
    final config = getConfig();
    final url = Uri.http(config.host, path, params);

    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      final res = method == "POS"
          ? await http.post(url, body: cmd, headers: headers)
          : await http.get(url, headers: headers);
      final data = res.body;
      final resData = jsonDecode(data);
      final Response response = Response();
      response.original = Original(
        req: [params, cmd],
        res: resData,
      );
      return response;
    } catch (e) {
      return Response(
        ok: false,
        body: e,
        original: Original(req: [params, cmd], res: null),
      );
    }
  }
}
