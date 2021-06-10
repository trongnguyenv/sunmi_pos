import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_list_tabview/scrollable_list_tabview.dart';
import '../blocs/authentication/authentication.dart';
import 'pages.dart';
import '../repositories/repository.dart';
import '../model/model.dart';
import '../contains/contains.dart';

class CasherPage extends StatefulWidget {
  final Customers customer;
  final Salon salon;
  final List<ServiceCategory> serviceCategoryList;
  final List<ProductCategory> productCategoryList;
  final List<PackageCategory> packageCategoryList;

  CasherPage(
      {this.customer,
      this.salon,
      this.serviceCategoryList,
      this.packageCategoryList,
      this.productCategoryList});

  @override
  State<CasherPage> createState() => _CasherPageState(
      customer: customer,
      salon: salon,
      serviceCategoryList: serviceCategoryList,
      productCategoryList: productCategoryList,
      packageCategoryList: packageCategoryList);
}

class _CasherPageState extends State<CasherPage> {
  Customers customer;
  final Salon salon;
  List<Basket> basketList = List<Basket>();
  UserRepository userRepository;

  _CasherPageState(
      {this.customer,
      this.salon,
      this.serviceCategoryList,
      this.productCategoryList,
      this.packageCategoryList});

  // RECIEVE DATA FROM HOME PAGE
  final List<ServiceCategory> serviceCategoryList;
  final List<ProductCategory> productCategoryList;
  final List<PackageCategory> packageCategoryList;

  // LIST POST TO SERVE
  List<BasketSevices> basketService = List<BasketSevices>();
  List<BasketProducts> basketProduct = List<BasketProducts>();
  List<BasketPackages> basketPackage = List<BasketPackages>();

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    counterItems;
  }

  /*==== List Service Category ==== */
  _listServiceCategoryTab() {
    List<ScrollableListTab> tabs = [];

    for (var i = 0; i < serviceCategoryList.length; i++) {
      tabs.add(ScrollableListTab(
        tab: ListTab(
          borderColor: Colors.green,
          activeBackgroundColor: Colors.lightBlue,
          label: Text(serviceCategoryList[i].categoryName.toUpperCase()),
        ),
        body: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, childAspectRatio: 4),
          physics: NeverScrollableScrollPhysics(),
          itemCount: serviceCategoryList[i].services.length,
          itemBuilder: (_, index) => Card(
            shape: serviceCategoryList[i].services[index].selected
                ? RoundedRectangleBorder(side: BorderSide(color: Colors.green))
                : null,
            child: Center(
              child: ListTile(
                // onTap: () => setState(() =>
                //     serviceCategoryList[i].services[index].selected = true),
                title: Text(
                  serviceCategoryList[i]
                      .services[index]
                      .serviceName
                      .toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    formatNumber(
                        serviceCategoryList[i].services[index].servicePrice),
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
                trailing: ClipOval(
                  child: Material(
                    color: Colors.green[300], // Button color
                    child: InkWell(
                        splashColor: Colors.red,
                        child: SizedBox(
                            width: 45, height: 45, child: Icon(Icons.add)),
                        onTap: () {
                          // setState(() => serviceCategoryList[i]
                          //     .services[index]
                          //     .selected = true);

                          basketList.add(Basket(
                            productId: serviceCategoryList[i]
                                .services[index]
                                .serviceId,
                            productName: serviceCategoryList[i]
                                .services[index]
                                .serviceName,
                            price: serviceCategoryList[i]
                                .services[index]
                                .servicePrice,
                          ));

                          basketService.add(BasketSevices(
                              serviceId: serviceCategoryList[i]
                                  .services[index]
                                  .serviceId,
                              quantity: 1));
                          counterItems;
                        }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
    }
    return tabs;
  }

  /*==== List Product Category ==== */
  _listProductCategoryTab() {
    List<ScrollableListTab> tabs = [];

    for (var i = 0; i < productCategoryList.length; i++) {
      tabs.add(ScrollableListTab(
        tab: ListTab(
          borderColor: Colors.green,
          activeBackgroundColor: Colors.lightBlue,
          label: Text(productCategoryList[i].productCategoryName.toUpperCase()),
        ),
        body: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, childAspectRatio: 4),
          physics: NeverScrollableScrollPhysics(),
          itemCount: productCategoryList[i].warehouse.length,
          itemBuilder: (_, index) => Card(
            child: Center(
              child: ListTile(
                title: Text(
                  productCategoryList[i]
                      .warehouse[index]
                      .productName
                      .toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    formatNumber(
                        productCategoryList[i].warehouse[index].productPrice),
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
                trailing: ClipOval(
                  child: Material(
                    color: Colors.green[300], // Button color
                    child: InkWell(
                        splashColor: Colors.red,
                        child: SizedBox(
                            width: 45, height: 45, child: Icon(Icons.add)),
                        onTap: () {
                          basketList.add(Basket(
                            productId: productCategoryList[i]
                                .warehouse[index]
                                .productId,
                            productName: productCategoryList[i]
                                .warehouse[index]
                                .productName,
                            price: productCategoryList[i]
                                .warehouse[index]
                                .productPrice,
                          ));

                          basketProduct.add(BasketProducts(
                              productId: productCategoryList[i]
                                  .warehouse[index]
                                  .productId,
                              quantity: 1));
                          counterItems;
                        }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return tabs;
  }

  /*==== List Package Category ==== */
  _listPackageCategoryTab() {
    List<ScrollableListTab> tabs = [];

    for (var i = 0; i < packageCategoryList.length; i++) {
      tabs.add(ScrollableListTab(
        tab: ListTab(
          borderColor: Colors.green,
          activeBackgroundColor: Colors.lightBlue,
          label: Text(packageCategoryList[i].packageName.toUpperCase()),
        ),
        body: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, childAspectRatio: 4),
          physics: NeverScrollableScrollPhysics(),
          itemCount: packageCategoryList[i].packages.length,
          itemBuilder: (_, index) => Card(
            margin: EdgeInsets.all(8),
            child: Center(
              child: ListTile(
                title: Text(
                  packageCategoryList[i]
                      .packages[index]
                      .packageName
                      .toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    formatNumber(
                        packageCategoryList[i].packages[index].packagePrice),
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
                trailing: ClipOval(
                  child: Material(
                    color: Colors.green[300], // Button color
                    child: InkWell(
                        splashColor: Colors.red,
                        child: SizedBox(
                            width: 45, height: 45, child: Icon(Icons.add)),
                        onTap: () {
                          basketList.add(Basket(
                              productId: packageCategoryList[i]
                                  .packages[index]
                                  .packageId,
                              productName: packageCategoryList[i]
                                  .packages[index]
                                  .packageName,
                              price: packageCategoryList[i]
                                  .packages[index]
                                  .packagePrice));

                          basketPackage.add(BasketPackages(
                              packageId: packageCategoryList[i]
                                  .packages[index]
                                  .packageId,
                              quantity: 1));
                          counterItems;
                        }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);

    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text('${salon.name.toUpperCase()}',
                style: TextStyle(
                  color: Colors.white,
                )),
            elevation: 0.0,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 22.0,
                ),
                onPressed: () {
                  authBloc.add(UserLoggedOut());
                  RestartApp.restartApp(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(
                        userRepository: userRepository,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: DefaultTabController(
            length: 3,
            child: Scaffold(
                body: DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: TabBar(
                  labelPadding: EdgeInsets.all(15),
                  labelColor: Colors.lightBlue,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Text('DỊCH VỤ'),
                    Text('SẢN PHẨM'),
                    Text('GÓI DỊCH VỤ'),
                  ],
                ),
                body: TabBarView(
                  children: [
                    //---------------- TAB 1
                    ScrollableListTabView(
                        tabHeight: 45,
                        bodyAnimationDuration:
                            const Duration(milliseconds: 500),
                        tabAnimationCurve: Curves.easeOut,
                        tabAnimationDuration: const Duration(milliseconds: 500),
                        tabs: _listServiceCategoryTab()),
                    //---------------- TAB 2
                    ScrollableListTabView(
                        tabHeight: 45,
                        bodyAnimationDuration:
                            const Duration(milliseconds: 400),
                        tabAnimationCurve: Curves.easeOut,
                        tabAnimationDuration: const Duration(milliseconds: 400),
                        tabs: _listProductCategoryTab()),
                    //---------------- TAB 3
                    ScrollableListTabView(
                        tabHeight: 45,
                        bodyAnimationDuration:
                            const Duration(milliseconds: 500),
                        tabAnimationCurve: Curves.easeOut,
                        tabAnimationDuration: const Duration(milliseconds: 500),
                        tabs: _listPackageCategoryTab()),
                  ],
                ),
              ),
            )),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
              ),
              child: new Stack(
                children: <Widget>[
                  new IconButton(
                    icon: Icon(Icons.shopping_basket_outlined,
                        color: Colors.white),
                    onPressed: () => {
                      Future.delayed(
                        const Duration(milliseconds: 500),
                      ),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BasketPage(
                              customer: customer,
                              salon: salon,
                              baskets: basketList,
                              basketService: basketService,
                              basketProduct: basketProduct,
                              basketPackage: basketPackage),
                        ),
                      ).then(
                        (value) {
                          counterItems;
                          if (value != null) {
                            customer = Customers(
                                id: value.id,
                                name: value.name,
                                mobile: value.mobile,
                                salonBranchId: value.salonBranchId,
                                salonId: value.salonId);
                          }
                        },
                      ),
                    },
                  ),
                  new Positioned(
                    right: 0,
                    top: 0,
                    child: new Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: new BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      constraints: BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                      child: Text(
                        "$counterItems",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BasketPage(
                        customer: customer, salon: salon, baskets: basketList),
                  ),
                ).then((_) => counterItems),
              },
            ),
          )),
    );
  }

  int get counterItems {
    setState(() {
      basketList.length;
    });
    return basketList.length;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
