class Config {
  String? host;
  Config({
    this.host,
  });
}

class Response {
  bool? ok;
  dynamic body;
  Original? original;
  Response({
    this.ok,
    this.body,
    this.original,
  });
}

class Original {
  dynamic res;
  dynamic req;
  Original({
    this.res,
    this.req,
  });
}
