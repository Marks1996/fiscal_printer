import 'epson_model.dart';

/// interface
/// create by marks 2023/05/30
abstract class BaseEpsonClient {
  final Config config;

  BaseEpsonClient(this.config);

  getConfig() => config;

  Future<Response> printFiscalReceipt(Receipt receipt);

  Future<Response> printFiscalReport(Report report);

  Future<Response> printCancel(Cancel cancel);

  // abstract printNonFiscal(nonfiscal: NonFiscal): Promise<Response>;

  // abstract printInvoice(invoice: Invoice): Promise<Response>;

  Future<Response> executeCommand(List<Command>? commands);
}
