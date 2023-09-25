import 'dart:convert';
import 'dart:io';

class HttpUtils {
  final client = HttpClient();
  HttpUtils() {
    // 忽略 SSL 证书验证
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    client.connectionTimeout = Duration(seconds: 30);
    client.idleTimeout = Duration(seconds: 30);
  }

  Future<String> get(String url) async {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    return responseBody;
  }

  Future<String> post(
    String url,
    String? body, {
    Map<String, String>? headers,
  }) async {
    final request = await client.postUrl(Uri.parse(url));
    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });
    if (body != null) request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    return responseBody;
  }

  // 添加其他常见的 HTTP 请求方法（例如：PUT、DELETE、PATCH等）
}
