class Config {
  String? host;
  Config({
    this.host,
  });
}

class Result {
  bool? ok;
  dynamic body;
  Original? original;
  Result({
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
