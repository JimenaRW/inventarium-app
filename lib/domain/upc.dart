class Upc {
  String code;

  Upc({required this.code});

  //Lo jsonifico porque puede venir tanto el UPC como un QR.
  factory Upc.fromJson(Map<String, dynamic> json) {
    return Upc(code: json['code']);
  }
}
