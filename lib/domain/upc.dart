class Upc {
  String code;

  Upc({required this.code});

  factory Upc.fromJson(Map<String, dynamic> json) {
    return Upc(code: json['code']);
  }
}
