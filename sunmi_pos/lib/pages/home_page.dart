import 'package:flutter/material.dart';
import '../model/model.dart';
import 'pages.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../repositories/repository.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _typeAheadController = new TextEditingController();
  TextEditingController _typeNameController = new TextEditingController();
  UserRepository userRepository;
  dynamic _customer;
  Salon salon;

  bool isLoading = false;
  bool isCreating = false;

  // FETCH DATA API
  List<ServiceCategory> serviceCategoryList = [];
  List<ProductCategory> productCategoryList = [];
  List<PackageCategory> packageCategoryList = [];

  @override
  void initState() {
    super.initState();
    /*==== Fetch Data API ==== */
    fetchServiceCategory().then(
      (value) => setState(() {
        serviceCategoryList.addAll(value);
      }),
    );

    fetchProductCategory().then(
      (value) => setState(() {
        productCategoryList.addAll(value);
      }),
    );

    fetchPackageCategory().then(
      (value) => setState(() {
        packageCategoryList.addAll(value);
      }),
    );

    getSalon();
  }

  void getSalon() async {
    final _user = await getUserDetail();
    salon = Salon(
      salonId: _user.salonId,
      name: _user.name,
      address: _user.salon.address,
      mobile: _user.salon.mobile,
      email: _user.salon.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldPhone = TypeAheadField<Customers>(
      hideSuggestionsOnKeyboardHide: false,
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(
          labelText: 'Nhập theo số điện thoại hoặc mã khách hàng',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          isDense: true,
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _typeAheadController.clear(),
          ),
        ),
        controller: _typeAheadController,
      ),
      suggestionsCallback: CustomerRepository.getUserSuggestions,
      itemBuilder: (context, Customers suggestion) {
        final customer = suggestion;
        return ListTile(
          title: Text('${customer.code}' + " - " + '${customer.name}'),
        );
      },
      noItemsFoundBuilder: (context) => Container(
        height: 50,
        child: Center(
          child: Text(
            'Không tìm thấy khách hàng !',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
      onSuggestionSelected: (Customers suggestion) {
        final customer = suggestion;
        this._typeAheadController.text = customer.name;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CasherPage(
                customer: customer,
                salon: salon,
                serviceCategoryList: serviceCategoryList,
                productCategoryList: productCategoryList,
                packageCategoryList: packageCategoryList),
          ),
        );
        _typeAheadController.clear();
      },
    );

    final fieldNameCustome = TextFormField(
      autofocus: false,
      controller: _typeNameController,
      decoration: InputDecoration(
        labelText: 'Nhập tên khách hàng',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        isDense: true,
      ),
    );

    final buttonChoose = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 130.0,
          height: 40.0,
          child: RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: isCreating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          backgroundColor: Colors.blue,
                          strokeWidth: 2,
                        ),
                      ),
                      Text('TẠO')
                    ],
                  )
                : Text('TẠO'),
            onPressed: () async {
              setState(() => isCreating = true);
              FocusScope.of(context).unfocus();
              if (_typeAheadController.text.isNotEmpty &&
                  _typeNameController.text.isNotEmpty) {
                _customer = {
                  'mobile': _typeAheadController.text,
                  'name': _typeNameController.text,
                  'salonBranchId': salon.salonId,
                  'salonId': salon.salonId
                };
                final _customerGet = await createCustomer(_customer);
                if (_customerGet != null) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                          content: Text('Tạo mới khách hàng thành công !'),
                          backgroundColor: Colors.green),
                    );

                  if (salon != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CasherPage(
                            customer: _customerGet,
                            salon: salon,
                            serviceCategoryList: serviceCategoryList,
                            productCategoryList: productCategoryList,
                            packageCategoryList: packageCategoryList),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                            content: Text(
                                'Có lỗi xảy ra, vui lòng thử lại thao tác !'),
                            backgroundColor: Colors.red),
                      );
                  }
                } else {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                          content: Text('Khách hàng đã tồn tại !'),
                          backgroundColor: Colors.red),
                    );
                }
              } else {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                        content: Text(
                            'Vui lòng kiểm tra lại thông tin khách hàng !'),
                        backgroundColor: Colors.red),
                  );
              }
              setState(() => isCreating = false);
            },
          ),
        ),
        Container(
          width: 130.0,
          height: 40.0,
          child: RaisedButton(
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          backgroundColor: Colors.blue,
                          strokeWidth: 2,
                        ),
                      ),
                      Text('BỎ QUA'),
                    ],
                  )
                : Text('BỎ QUA'),
            onPressed: () async {
              setState(() => isLoading = true);
              final customer = null;
              await new Future.delayed(const Duration(seconds: 5));
              if (salon != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CasherPage(
                        customer: customer,
                        salon: salon,
                        serviceCategoryList: serviceCategoryList,
                        productCategoryList: productCategoryList,
                        packageCategoryList: packageCategoryList),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                        content:
                            Text('Có lỗi xảy ra, vui lòng thử lại thao tác !'),
                        backgroundColor: Colors.red),
                  );
              }
              setState(() => isLoading = false);
            },
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: null,
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'CHỌN KHÁCH HÀNG',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue),
              ),
              SizedBox(height: 30),
              fieldPhone,
              SizedBox(height: 15),
              fieldNameCustome,
              SizedBox(height: 20),
              buttonChoose,
            ],
          ),
        ),
      ),
    );
  }
}
