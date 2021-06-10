import 'package:easy_salon/model/employee.dart';

class Basket {
  int productId;
  String productName;
  double price;
  int quantity;
  double basketDiscount;
  String basketValue;
  double itemDiscountPrice;
  List<Employee> employee;

  Basket(
      {this.productId,
      this.productName,
      this.price,
      this.quantity,
      this.basketDiscount,
      this.basketValue,
      this.itemDiscountPrice,
      this.employee});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> basket = new Map<String, dynamic>();
    basket['productId'] = this.productId;
    basket['quantity'] = this.quantity;
    return basket;
  }

  double get afterDiscountValue {
    var amount = price * quantity;
    if (basketDiscount != null) {
      if (basketValue == '%') {
        amount -=
            (double.tryParse(basketDiscount.toString()) ?? 0) / 100 * amount;
      } else {
        amount -= double.tryParse(basketDiscount.toString()) ?? 0;
      }
    }
    return amount;
  }
}

class BasketSevices {
  int serviceId;
  int quantity;
  double discountValue;
  String discountUnit;
  List<Employee> posInvoiceCommissions;

  BasketSevices(
      {this.serviceId,
      this.quantity,
      this.discountValue,
      this.discountUnit,
      this.posInvoiceCommissions});
}

class BasketProducts {
  int productId;
  int quantity;
  double discountValue;
  String discountUnit;
  List<Employee> posInvoiceCommissions;

  BasketProducts(
      {this.productId,
      this.quantity,
      this.discountValue,
      this.discountUnit,
      this.posInvoiceCommissions});
}

class BasketPackages {
  int packageId;
  int quantity;
  double discountValue;
  String discountUnit;
  List<Employee> posInvoiceCommissions;

  BasketPackages(
      {this.packageId,
      this.quantity,
      this.discountValue,
      this.discountUnit,
      this.posInvoiceCommissions});
}
