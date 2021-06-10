import 'dart:convert';
import 'package:http/http.dart' as http;
import '../connect/connection_api.dart';
import '../repositories/repository.dart';
import '../model/model.dart';

class CasherRepository {}

/*==== Fetch Service Category ==== */
Future<List<ServiceCategory>> fetchServiceCategory() async {
  final response = await http.get(Uri.parse(con.urlServiceCategories()),
      headers: <String, String>{
        'Authorization': 'Bearer ${await UserRepository().getToken()}'
      });

  if (response.statusCode == 200) {
    List serviceCategory = jsonDecode(response.body)['data'];
    return serviceCategory.map((e) => ServiceCategory.fromJson(e)).toList();
  } else {
    throw Exception('Không thể kết nối tới server!');
  }
}

/*==== Fetch Product Category ==== */
Future<List<ProductCategory>> fetchProductCategory() async {
  List listWarehouse = await fetchWarehouses();

  final response = await http.get(Uri.parse(con.urlProductCategories()),
      headers: <String, String>{
        'Authorization': 'Bearer ${await UserRepository().getToken()}'
      });

  if (response.statusCode == 200) {
    /* Get data done ! */
    List productCategory = jsonDecode(response.body)['data'];

    /* Check ID */
    for (var i = 0; i < productCategory.length; i++) {
      for (var j = 0; j < listWarehouse.length; j++) {
        if (listWarehouse[j].productCategoryId == productCategory[i]['id'])
          productCategory[i]['product'].add(listWarehouse[j]);
      }
    }

    return productCategory.map((e) => ProductCategory.fromJson(e)).toList();
  } else {
    throw Exception('Không thể kết nối tới server!');
  }
}

/*==== Fetch Warehouses For Product[] ==== */
Future<List<Warehouses>> fetchWarehouses() async {
  final response = await http.get(Uri.parse(con.urlWarehouses()),
      headers: <String, String>{
        'Authorization': 'Bearer ${await UserRepository().getToken()}'
      });

  if (response.statusCode == 200) {
    List warehouses = jsonDecode(response.body)['data'];
    return warehouses.map((e) => Warehouses.fromJson(e)).toList();
  } else {
    throw Exception('Không thể kết nối tới server!');
  }
}

/*==== Fetch Package Category ==== */
Future<List<PackageCategory>> fetchPackageCategory() async {
  final response = await http.get(Uri.parse(con.urlPackageCategories()),
      headers: <String, String>{
        'Authorization': 'Bearer ${await UserRepository().getToken()}'
      });

  if (response.statusCode == 200) {
    List packageCategory = jsonDecode(response.body)['data'];
    return packageCategory.map((e) => PackageCategory.fromJson(e)).toList();
  } else {
    throw Exception('Không thể kết nối tới server!');
  }
}

Future checkoutData(dynamic data) async {
  final postData = await http.post(Uri.parse(con.urlPosInvoice()),
      body: json.encode(data),
      headers: <String, String>{
        'Authorization': 'Bearer ${await UserRepository().getToken()}',
        'Content-Type': 'application/json'
      });

  if (postData.statusCode == 200)
    return postData.statusCode;
  if(postData.statusCode == 500)
    return postData.statusCode;
  else
    throw Exception('Không thể kết nối tới server. Thử lại !');
}
