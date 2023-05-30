import 'custom_model.dart';

abstract class BaseCustomClient {
  final Config config;

  BaseCustomClient(this.config);

  Config getConfig() {
    return config;
  }

  Future<Response> printFiscalReceipt(Receipt receipt);

  Future<Response> printFiscalReport(Report report);

  Future<Response> printCancel(Cancel cancel);

  Future<Response> executeCommand(List<Command> commands);
}
