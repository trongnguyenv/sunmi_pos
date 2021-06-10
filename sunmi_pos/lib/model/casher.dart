// ====== DỊCH VỤ ======
class ServiceCategory {
  int categoryId;
  String categoryName;
  List<Service> services;

  ServiceCategory({this.categoryId, this.categoryName, this.services});

  ServiceCategory.fromJson(Map<String, dynamic> json) {
    categoryId = json['id'];
    categoryName = json['name'];
    if (json['service'] != null) {
      services = new List<Service>();
      json['service'].forEach((v) {
        services.add(new Service.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> serviceCategory = new Map<String, dynamic>();
    serviceCategory['id'] = this.categoryId;
    serviceCategory['name'] = this.categoryName;
    if (this.services != null) {
      serviceCategory['service'] =
          this.services.map((v) => v.toJson()).toList();
    }

    return serviceCategory;
  }
}

class Service {
  int serviceId;
  int serviceCategoryId;
  String serviceName;
  double servicePrice;
  bool selected = false;

  Service({
    this.serviceId,
    this.serviceCategoryId,
    this.serviceName,
    this.servicePrice,
    this.selected,
  });

  Service.fromJson(Map<String, dynamic> json) {
    serviceId = json['id'];
    serviceCategoryId = json['serviceCategoryId'];
    serviceName = json['name'];
    servicePrice = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> service = new Map<String, dynamic>();
    service['id'] = this.serviceId;
    service['serviceCategoryId'] = this.serviceCategoryId;
    service['name'] = this.serviceName;
    service['price'] = this.servicePrice;
    return service;
  }
}

// ====== SẢN PHẨM ======
class ProductCategory {
  int productCategoryId;
  String productCategoryName;
  List warehouse;

  ProductCategory({
    this.productCategoryId,
    this.productCategoryName,
    this.warehouse,
  });

  ProductCategory.fromJson(Map<String, dynamic> json) {
    productCategoryId = json['id'];
    productCategoryName = json['name'];
    warehouse = json['product'];
  }
}

class Warehouses {
  int productId;
  int productCategoryId;
  String productName;
  double productPrice;

  Warehouses({
    this.productId,
    this.productCategoryId,
    this.productName,
    this.productPrice,
  });

  factory Warehouses.fromJson(Map<String, dynamic> json) => Warehouses(
      productId: json['product']['id'],
      productCategoryId: json['product']['productCategoryId'],
      productName: json['product']['name'],
      productPrice: json['product']['price']);
}

// ====== GÓI DỊCH VỤ ======
class PackageCategory {
  int packageId;
  String packageName;
  List<Package> packages;

  PackageCategory({this.packageId, this.packageName, this.packages});

  PackageCategory.fromJson(Map<String, dynamic> json) {
    packageId = json['id'];
    packageName = json['name'];
    if (json['packages'] != null) {
      packages = new List<Package>();
      json['packages'].forEach((v) {
        packages.add(new Package.fromJson(v));
      });
    }
  }
}

class Package {
  int packageId;
  int packageCategoryId;
  String packageName;
  double packagePrice;

  Package({
    this.packageId,
    this.packageCategoryId,
    this.packageName,
    this.packagePrice,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
      packageId: json['id'],
      packageCategoryId: json['packageCategoryId'],
      packageName: json['name'],
      packagePrice: json['price']);
}
