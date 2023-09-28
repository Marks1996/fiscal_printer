import 'axon_model.dart';

abstract class BaseAxonClient {
  final Config config;

  BaseAxonClient(this.config);

  getConfig() => config;

  /// 获取登录状态信息
  Future<Response> status();

  /// 客显显示
  Future<Response> dispWrite(String ln1, String ln2);

  /// 发送键盘命令
  Future<Response> keybWrite(String code);
  Future<Response> operWrite(String code, String idx);
  Future<Response> protoCmd(int js, String pkt);
  Future<Response> snedTicketCmd(String cmd);
  Future<Response> ticketCmd(int js);
}
