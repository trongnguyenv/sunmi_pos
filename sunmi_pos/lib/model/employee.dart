import 'package:flutter/cupertino.dart';

class Employee {
  final int id;
  final String name;

  const Employee(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => hashValues(id, name);
  // int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }

  factory Employee.fromJson(Map<String, dynamic> parsedJson) {
    return Employee(parsedJson['id'], parsedJson['name'] as String);
  }
}
