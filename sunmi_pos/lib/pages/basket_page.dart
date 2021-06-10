import 'package:easy_salon/repositories/casher_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pages.dart';
import '../model/model.dart';
import '../contains/contains.dart';
import '../widgets/dialog_total_invoice.dart';
import '../widgets/choose_customer.dart';
import '../widgets/employee_discount.dart';

import 'package:flutter/services.dart';
import 'package:sunmi_thermal_printer/sunmi_thermal_printer.dart';

class BasketPage extends StatefulWidget {
  final Customers customer;
  final Salon salon;
  final List<Basket> baskets;
  final List<BasketSevices> basketService;
  final List<BasketProducts> basketProduct;
  final List<BasketPackages> basketPackage;

  BasketPage(
      {Key key,
      this.customer,
      this.salon,
      this.baskets,
      this.basketService,
      this.basketProduct,
      this.basketPackage})
      : super(key: key);

  @override
  State<BasketPage> createState() => _BasketPageState(
      customer: customer,
      salon: salon,
      baskets: baskets,
      basketService: basketService,
      basketProduct: basketProduct,
      basketPackage: basketPackage);
}

class _BasketPageState extends State<BasketPage> {
  _BasketPageState(
      {this.customer,
      this.salon,
      this.baskets,
      this.basketService,
      this.basketProduct,
      this.basketPackage});

  Customers customer;
  final Salon salon;
  List<Basket> baskets;

  List<BasketSevices> basketService;
  List<BasketProducts> basketProduct;
  List<BasketPackages> basketPackage;

  dynamic posInvoiceCheckout;

  dynamic posInvoiceItems = [];
  dynamic listEmployeeId = [];

  double discount = 0.0;
  double discountValue = 0;
  double totalDiscount;
  String discountUnit = "MONEY";

  String _platformVersion = 'Unknown';
  SunmiThermalPrinter _printer;

  String _discountUnitItem = "MONEY";
  double _discountValueItem = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    totalDiscount = totalAmount;

    // Get Platform Version
    initPlatformState();
  }

  String get customerName {
    return customer.name.toUpperCase();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await SunmiThermalPrinter.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text('CHI TIẾT HÓA ĐƠN', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => Navigator.pop(context, customer)),
          elevation: 4.0),
      body: Container(
        child: FutureBuilder(
          builder: (context, snapshot) {
            return ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: baskets.length,
              itemBuilder: (_, index) => Card(
                child: Center(
                  child: ListTile(
                    title: Text(baskets[index].productName.toUpperCase(),
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(formatNumber(baskets[index].price),
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => {
                              Future.delayed(const Duration(milliseconds: 500)),
                              removeFromCart(index)
                            })),
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 500));
                      getItemProduct(index);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeDiscount(
                            baskets[index].productName.toUpperCase(),
                            baskets[index].price,
                            baskets[index].basketValue,
                            baskets[index].basketDiscount,
                            baskets[index].employee,
                          ),
                        ),
                      ).then(
                        (value) =>
                            {if (value != null) checkItemInList(index, value)},
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildTotalContainer(),
    );
  }

  Widget _buildTotalContainer() {
    return Container(
      height: 220.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: <Widget>[
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                    padding: EdgeInsets.symmetric(horizontal: 35.0),
                    child: Text(customer != null ? '$customerName' : "KHÁCH LẺ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold)),
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CustomerPage(salon: salon)))
                          .then((value) => setState(() {
                                if (value != null) {
                                  customer = Customers(
                                      id: value.id,
                                      name: value.name,
                                      mobile: value.mobile,
                                      salonBranchId: value.salonBranchId,
                                      salonId: value.salonId);
                                  customerName;
                                }
                              }));
                    }),
                RaisedButton(
                    padding: EdgeInsets.symmetric(horizontal: 35.0),
                    child: Text("GIẢM GIÁ",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold)),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () => {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TipCalculatorPage(
                                  discountValue: discountValue,
                                  discountUnit: discountUnit,
                                  discountPrice: discount,
                                  costPrice: totalAmount,
                                );
                              }).then((value) {
                            if (value != null) {
                              setState(() {
                                discountValue = value[0];
                                discountUnit = value[1];
                                discount = value[2];
                                totalDiscount = value[3];
                              });
                            }
                          })
                        })
              ]),
          Divider(height: 12.0),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Thành tiền",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "${formatNumber(totalAmount)} ₫",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(
            height: 12.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Giảm giá",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "${formatNumber(discount)} ₫",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(
            height: 12.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Tạm tính",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "${formatNumber(totalDiscount)} ₫",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(
            height: 12.0,
          ),
          GestureDetector(
            onTap: () => checkout(),
            child: Container(
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(35.0),
              ),
              child: isLoading
                  ? Center(
                      child: Row(
                        children: [
                          SizedBox(width: 85),
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              backgroundColor: Colors.blue,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 20),
                          Text('THANH TOÁN',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        "THANH TOÁN",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  void checkout() async {
    setState(() => isLoading = true);
    await new Future.delayed(const Duration(seconds: 2));

    if (basketService.length == 0 &&
        basketProduct.length == 0 &&
        basketPackage.length == 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text('Không có dịch vụ được chọn để thanh toán !'),
            backgroundColor: Colors.red));
    } else {
      // ====== [SERVICE] ======
      if (basketService.length != null) {
        for (int i = 0; i < basketService.length; i++) {
          if (basketService[i].posInvoiceCommissions != null) {
            for (int j = 0;
                j < basketService[i].posInvoiceCommissions.length;
                j++) {
              listEmployeeId.add(
                  {'staffId': basketService[i].posInvoiceCommissions[j].id});
            }
          }
          posInvoiceItems.add({
            'serviceId': basketService[i].serviceId,
            'quantity': 1,
            'discountUnit': basketService[i].discountUnit,
            'discountValue': basketService[i].discountValue,
            if (listEmployeeId.length > 0)
              'posInvoiceCommissions': listEmployeeId
          });
          listEmployeeId = [];
        }
      }

      // ====== [PRODUCT] ======
      if (basketProduct.length != null) {
        for (int i = 0; i < basketProduct.length; i++) {
          if (basketProduct[i].posInvoiceCommissions != null) {
            for (int j = 0;
                j < basketProduct[i].posInvoiceCommissions.length;
                j++) {
              listEmployeeId.add(
                  {'staffId': basketProduct[i].posInvoiceCommissions[j].id});
            }
          }
          posInvoiceItems.add({
            'productId': basketProduct[i].productId,
            'quantity': 1,
            'discountUnit': basketProduct[i].discountUnit,
            'discountValue': basketProduct[i].discountValue,
            if (listEmployeeId.length > 0)
              'posInvoiceCommissions': listEmployeeId
          });
          listEmployeeId = [];
        }
      }

      // ====== [PACKAGE] ======
      if (basketPackage.length != null) {
        for (int i = 0; i < basketPackage.length; i++) {
          if (basketPackage[i].posInvoiceCommissions != null) {
            for (int j = 0;
                j < basketPackage[i].posInvoiceCommissions.length;
                j++) {
              listEmployeeId.add(
                  {'staffId': basketPackage[i].posInvoiceCommissions[j].id});
            }
          }
          posInvoiceItems.add({
            'packageId': basketPackage[i].packageId,
            'quantity': 1,
            'discountUnit': basketPackage[i].discountUnit,
            'discountValue': basketPackage[i].discountValue,
            if (listEmployeeId.length > 0)
              'posInvoiceCommissions': listEmployeeId
          });
          listEmployeeId = [];
        }
      }

      // ====== [POST DATA TO SERVER] ======
      posInvoiceCheckout = {
        'customerId': customer != null ? customer.id : null,
        'discountUnit': discountUnit ?? "",
        'discountValue': discountValue ?? 0,
        'posInvoiceItems': posInvoiceItems,
      };

      if (posInvoiceItems.length != 0) {
        final checkCode = await checkoutData(posInvoiceCheckout);
        if (checkCode == 200) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content: Text('Đã thanh toán thành công !'),
                  backgroundColor: Colors.green),
            );
          // PRINT
          await _loadPrintData();
          _printer.exec();

          await new Future.delayed(const Duration(seconds: 3));
          RestartApp.restartApp(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content: Text('Lỗi kết nối server !'),
                  backgroundColor: Colors.red),
            );
        }
        setState(() => isLoading = false);
      }
    }
  }

  double get totalAmount {
    return baskets.fold(0.0, (double currentTotal, Basket nextProduct) {
      if (nextProduct.itemDiscountPrice == 0.0 ||
          nextProduct.itemDiscountPrice == null)
        setState(() {
          nextProduct.itemDiscountPrice = nextProduct.price;
        });
      return currentTotal + nextProduct.itemDiscountPrice;
    });
  }

  void getItemProduct(int index) {
    var _index = baskets[index].productId;
    int itemService =
        basketService.indexWhere((item) => item.serviceId == _index);
    if (itemService != -1) {
      _discountUnitItem = basketService[itemService].discountUnit;
      _discountValueItem = basketService[itemService].discountValue;
    }

    int itemProduct =
        basketProduct.indexWhere((item) => item.productId == _index);
    if (itemProduct != -1) {
      _discountUnitItem = basketProduct[itemProduct].discountUnit;
      _discountValueItem = basketProduct[itemProduct].discountValue;
    }

    int itemPackage =
        basketPackage.indexWhere((item) => item.packageId == _index);
    if (itemPackage != -1) {
      _discountUnitItem = basketPackage[itemPackage].discountUnit;
      _discountValueItem = basketPackage[itemPackage].discountValue;
    }
  }

  void removeFromCart(int index) {
    var _itemId = baskets[index].productId;
    baskets.removeAt(index);

    int inService =
        basketService.indexWhere((item) => item.serviceId == _itemId);
    if (inService != -1) basketService.removeAt(inService);

    int inProduct =
        basketProduct.indexWhere((item) => item.productId == _itemId);
    if (inProduct != -1) basketProduct.removeAt(inProduct);

    int inPackage =
        basketPackage.indexWhere((item) => item.packageId == _itemId);
    if (inPackage != -1) basketPackage.removeAt(inPackage);

    totalDiscount = totalAmount;

    setState(() {
      if (discountValue == 0)
        totalDiscount = totalAmount;
      else {
        if (discountValue < totalAmount) {
          if (discountUnit == "MONEY") {
            discount = discountValue;
            totalDiscount = totalAmount - discountValue;
          }
          if (discountUnit == "PERCENT") {
            discount = totalAmount * (discountValue / 100);
            totalDiscount = totalAmount - discount;
          }
        }
      }
    });

    if (baskets.length == 0) setState(() => discount = 0);
  }

  void checkItemInList(int indexItem, List value) {
    baskets[indexItem].basketDiscount = value[0];
    baskets[indexItem].basketValue = value[1];
    baskets[indexItem].employee = value[2];
    baskets[indexItem].itemDiscountPrice = value[3];

    totalDiscount = totalAmount;

    setState(() {
      if (discountValue == 0)
        totalDiscount = totalAmount;
      else {
        if (discountValue < totalAmount) {
          if (discountUnit == "MONEY") {
            discount = discountValue;
            totalDiscount = totalAmount - discountValue;
          }
          if (discountUnit == "PERCENT") {
            discount = totalAmount * (discountValue / 100);
            totalDiscount = totalAmount - discount;
          }
        }
      }
    });

    var _itemIdInList = baskets[indexItem].productId;
    int inServiceList =
        basketService.indexWhere((item) => item.serviceId == _itemIdInList);
    if (inServiceList != -1) {
      basketService[inServiceList].discountValue = value[0];
      basketService[inServiceList].discountUnit = value[1];
      basketService[inServiceList].posInvoiceCommissions = value[2];
    }

    int inProductList =
        basketProduct.indexWhere((item) => item.productId == _itemIdInList);
    if (inProductList != -1) {
      basketProduct[inProductList].discountValue = value[0];
      basketProduct[inProductList].discountUnit = value[1];
      basketProduct[inProductList].posInvoiceCommissions = value[2];
    }

    int inPackageList =
        basketPackage.indexWhere((item) => item.packageId == _itemIdInList);
    if (inPackageList != -1) {
      basketPackage[inPackageList].discountValue = value[0];
      basketPackage[inPackageList].discountUnit = value[1];
      basketPackage[inPackageList].posInvoiceCommissions = value[2];
    }
  }

  //PRINT BILL
  Future<void> _loadPrintData() async {
    var header = '${salon.name.toUpperCase()}';
    var mobile = '${salon.mobile}';
    var address = '${salon.address}';
    var timestamp = DateFormat('dd/MM/yyyy H:m').format(DateTime.now());
    var cashier = customer != null ? customer.name : 'Khách lẻ';
    var itemsHeaderLeft = 'Tên dịch vụ';
    var itemsHeaderRight = '(VND)';

    var items = [];

    for (int i = 0; i < baskets.length; i++) {
      String _value = baskets[i].basketValue == "PERCENT"
          ? baskets[i].basketValue = "%"
          : "₫";
      items.add(Basket(
          productName: baskets[i].productName.toUpperCase(),
          price: baskets[i].price,
          quantity: 1,
          basketValue: _value,
          basketDiscount: baskets[i].basketDiscount,
          employee: baskets[i].employee));
    }

    var footer = 'Cảm ơn quý khách và hẹn gặp lại';

    _printer = SunmiThermalPrinter()
      ..bold()
      ..printCenter(header)
      ..printCenter(mobile)
      ..println(address)
      ..printLR('Ngày:', timestamp)
      ..printLR('Khách hàng:', cashier)
      ..divider()
      ..printLR(itemsHeaderLeft, itemsHeaderRight)
      ..bold()
      ..divider();

    for (var item in items) {
      String amountStr = formatNumber(item.afterDiscountValue.toString());
      _printer
        ..bold()
        ..printLeft(item.productName)
        ..bold()
        ..printLR(
            '${formatNumber(item.price.toString())} × ${item.quantity.toString()}',
            amountStr);

      if (item.basketDiscount != null && item.basketDiscount > 0.0) {
        _printer
          ..println(
              'Giảm giá ${formatNumber(item.basketDiscount.toString())}${item.basketValue}');
      }

      if (item.employee != null && item.employee.length > 0) {
        String _employeeName = "";
        for (int i = 0; i < item.employee.length; i++)
          _employeeName += item.employee[i].name + ", ";

        _employeeName = _employeeName.substring(0, _employeeName.length - 2);
        _printer..println('Nhân viên: $_employeeName');
      }
      _printer..println('');
    }

    _printer
      ..divider()
      ..printLR('Tạm tính', formatNumber(totalAmount))
      ..printLR('Giảm giá', formatNumber(discount))
      ..printLR('Thành tiền', formatNumber(totalDiscount))
      ..divider()
      ..printCenter(footer)
      ..newLine();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
