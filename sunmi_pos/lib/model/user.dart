class User {
  int id;
  String name;
  int salonId;
  Salon salon;

  User({this.id, this.name, this.salonId, this.salon});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        salonId: json["salonId"],
        salon: Salon.fromJson(json["salon"]),
      );
}

class Salon {
  int salonId;
  String address;
  String email;
  String mobile;
  String name;

  Salon({this.salonId, this.address, this.email, this.mobile, this.name});

  factory Salon.fromJson(Map<String, dynamic> json) => Salon(
        salonId: json['salonId'],
        address: json['address'],
        email: json['email'],
        mobile: json['mobile'],
        name: json['name'],
      );
}
