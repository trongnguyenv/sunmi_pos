import 'dart:convert';
import 'package:http/http.dart' as http;
import '../connect/connection_api.dart';
import '../model/model.dart';
import '../repositories/repository.dart';

class CustomerRepository {
  static Future<List<Customers>> getUserSuggestions(String query) async {
    final response = await http.get(Uri.parse(con.urlCustomer() + query),
        headers: <String, String>{
          'Authorization': 'Bearer ${await UserRepository().getToken()}'
        });

    if (response.statusCode == 200) {
      final List customers = json.decode(response.body)['data'];

      return customers
          .map((json) => Customers.fromJson(json))
          .where((customer) {
        final nameUpper = customer.name.toUpperCase();
        final codeUpper = customer.code.toUpperCase();
        final mobileCus = customer.mobile;
        final queryUpper = query.toUpperCase();
        if (customer.mobile != null) {
          return nameUpper.contains(queryUpper) ||
              codeUpper.contains(queryUpper) ||
              mobileCus.contains(query);
        }
        return nameUpper.contains(queryUpper) || codeUpper.contains(queryUpper);
      }).toList();
    } else {
      throw Exception();
    }
  }
}

Future<List<Employee>> fetchListEmployees() async {
  final response = await http.get(Uri.parse(con.urlEmployee()),
      headers: <String, String>{
        'Authorization': 'Bearer ${await UserRepository().getToken()}'
      });

  if (response.statusCode == 200) {
    List employees = jsonDecode(response.body)['data'];
    return employees.map((e) => Employee.fromJson(e)).toList();
  } else {
    throw Exception('Không thể kết nối tới server!');
  }
}

Future<Customers> createCustomer(dynamic data) async {
  final postData = await http.post(Uri.parse(con.urlCreateCustomer()),
      body: json.encode(data),
      headers: <String, String>{
        'Authorization': 'Bearer ${await UserRepository().getToken()}',
        'Content-Type': 'application/json'
      });
  try {
    if (postData.statusCode == 201) {
      final _customer = jsonDecode(postData.body)['data'];
      return Customers.fromJson(_customer);
    }
  } catch (e) {
    return null;
  }
  return null;
}

Future<List<Customers>> getCustomerNew(String keyword) async {
  final response = await http.get(Uri.parse(con.urlCustomer() + keyword),
      headers: <String, String>{
        'Authorization': 'Bearer ${await UserRepository().getToken()}'
      });

  if (response.statusCode == 200) {
    List employees = jsonDecode(response.body)['data'];
    return employees.map((e) => Customers.fromJson(e)).toList();
  } else {
    throw Exception('Không thể kết nối tới server!');
  }
}
