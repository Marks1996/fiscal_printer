import 'rch_model.dart';

abstract class BaseRchClient {
  final Config config;

  BaseRchClient(this.config);

  getConfig() => config;

  Future<Result> executeCommand(List<String> commands);
}
