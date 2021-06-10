import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../connect/connection_api.dart';
import '../model/model.dart';

final FlutterSecureStorage storage = new FlutterSecureStorage();
var accessToken;
dynamic userMap;

class UserRepository {
  var urlLogin = con.urlLogin;

  final Dio _dio = Dio();

  Future<bool> hasToken() async {
    var value = await storage.read(key: 'token');
    if (value != null) {
      accessToken = value;
      userMap = parseJwt(value);
      return true;
    } else
      return false;
  }

  Future<void> persistToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<void> deleteToken() async {
    await Future.delayed(Duration(milliseconds: 500));
    storage.delete(key: 'token');
    storage.deleteAll();
  }

  Future<String> login(String username, String password) async {
    Response response = await _dio
        .post(urlLogin, data: {"username": username, "password": password});

    return response.data["token"];
  }

  Future<String> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> persistData(String key, String value) async {
    await storage.write(key: key, value: value);
    return;
  }
}

Future<User> getUserDetail() async {
  final http.Response getUser = await http.get(
      Uri.parse(con.urlApi + "Users/${userMap['userId']}"),
      headers: <String, String>{'Authorization': 'Bearer $accessToken'});

  if (getUser.statusCode == 200) {
    final users = json.decode(getUser.body)['data'];
    return User.fromJson(users);
  } else
    throw Exception('Không thể kết nối tới server. Thử lại !');
}

// --- Decode token ---
Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw Exception('Mã xác thực không hợp lệ');

  final payload = _decodeBase64(parts[1]);
  final payloadMap = json.decode(payload);
  if (payloadMap is! Map<String, dynamic>) throw Exception('Invalid payload');
  return payloadMap;
}

String _decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');
  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string!');
  }

  return utf8.decode(base64Url.decode(output));
}
