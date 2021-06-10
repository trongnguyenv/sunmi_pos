class Connection {
  var url = '';

  String urlLogin = "https://secure.easysalon.vn/api/create-token";

  String urlApi = "https://api-staging.easysalon.vn/";
  // String urlApi = "https://api.easysalon.vn/";

  String urlCustomer() {
    url = urlApi + "customers?keyword=";
    return url;
  }

  String urlCreateCustomer() {
    url = urlApi + "Customers";
    return url;
  }

  String urlEmployee() {
    url = urlApi + "Staffs?order=id&orderType=DESC";
    return url;
  }

  String urlServiceCategories() {
    url = urlApi + "ServiceCategorys?orderBy=name&orderType=asc";
    return url;
  }

  String urlProductCategories() {
    url = urlApi + "ProductCategorys?orderBy=name&orderType=asc";
    return url;
  }

  String urlWarehouses() {
    url = urlApi + "Warehouses?rowPerPage=1000&order=id&orderType=DESC";
    return url;
  }

  String urlPackageCategories() {
    url = urlApi + "PackageCategories?orderBy=name&orderType=asc";
    return url;
  }

  String urlPosInvoice() {
    url = urlApi + "PosInvoices";
    return url;
  }
}

Connection con = Connection();
