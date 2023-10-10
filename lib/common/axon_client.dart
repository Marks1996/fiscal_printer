import 'axon_model.dart';

abstract class BaseAxonClient {
  final Config config;

  BaseAxonClient(this.config);

  getConfig() => config;

  /// 获取登录状态信息
  Future<Result> status();

  /// 客显显示
  Future<Result> dispWrite(String ln1, String ln2);

  /// 发送键盘命令
  Future<Result> keybWrite(String code);
  Future<Result> operWrite(String code, String idx);
  Future<Result> protoCmd(int js, String pkt);
  Future<Result> snedTicketCmd(String cmd);
  Future<Result> ticketCmd(int js);
}
