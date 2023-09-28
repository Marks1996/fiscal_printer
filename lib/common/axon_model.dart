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

  toJson() => {
        'ok': ok,
        'body': body,
        'original': original?.toJson(),
      };
}

class Original {
  dynamic res;
  dynamic req;
  Original({
    this.res,
    this.req,
  });

  toJson() => {
        'res': res,
        'req': req,
      };
}
