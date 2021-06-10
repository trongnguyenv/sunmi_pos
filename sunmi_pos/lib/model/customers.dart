class Customers {
  int id;
  String code;
  String name;
  String mobile;
  int salonId;
  int salonBranchId;

  Customers(
      {this.id,
      this.code,
      this.name,
      this.mobile,
      this.salonBranchId,
      this.salonId});

  factory Customers.fromJson(Map<String, dynamic> parsedJson) {
    return Customers(
      id: parsedJson['id'],
      code: parsedJson['code'] as String,
      name: parsedJson['name'] as String,
      mobile: parsedJson['mobile'] as String,
      salonBranchId: parsedJson['salonBranchId'],
      salonId: parsedJson['salonId'],
    );
  }
}
