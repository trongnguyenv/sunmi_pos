import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import '../model/model.dart';
import '../contains/contains.dart';
import '../repositories/repository.dart';

class EmployeeDiscount extends StatefulWidget {
  final String itemName;
  final double itemPrice;
  final String _discountUnitItem;
  final double _discountValueItem;
  final List<Employee> employeeList;

  const EmployeeDiscount(this.itemName, this.itemPrice, this._discountUnitItem,
      this._discountValueItem, this.employeeList);

  @override
  _EmployeeDiscountState createState() => _EmployeeDiscountState(
        itemName: itemName,
        itemPrice: itemPrice,
        discountUnitItem: _discountUnitItem,
        discountValueItem: _discountValueItem,
        employees: employeeList,
      );
}

class _EmployeeDiscountState extends State<EmployeeDiscount> {
  //GET INFO ITEM
  final String itemName;
  final double itemPrice;
  final List<Employee> employees;
  String discountUnitItem;
  double discountValueItem;
  _EmployeeDiscountState({
    this.itemName,
    this.itemPrice,
    this.discountUnitItem,
    this.discountValueItem,
    this.employees,
  });

  final _chipKey = GlobalKey<ChipsInputState>();
  final mockResults = <Employee>[];

  final TextEditingController _tipPercentageController =
      new TextEditingController();

  double discount;
  String _selectedId = '₫';
  double _tipPercentage = 0;
  double _totalDiscount;
  List<Employee> employeeList = List<Employee>();
  List<Employee> _dataTemp = [];
  final result = [];

  @override
  void initState() {
    super.initState();

    fetchListEmployees().then(
      (value) => setState(() {
        mockResults.addAll(value);
      }),
    );

    _totalDiscount = this.itemPrice;
    if (discountValueItem != null) {
      _tipPercentageController.text =
          discountValueItem.toString().replaceAll(".0", "");

      if (discountUnitItem == "MONEY" || discountUnitItem == null)
        _selectedId = '₫';
      else
        _selectedId = '%';

      setState(() {
        discountValueItem = double.tryParse(_tipPercentageController.text) ?? 0;
        _tipPercentage = double.tryParse(_tipPercentageController.text) ?? 0.0;

        if (_tipPercentage < this.itemPrice) {
          if (_selectedId == '₫')
            _totalDiscount = this.itemPrice - _tipPercentage;

          if (_selectedId == '%') {
            _tipPercentage = this.itemPrice * (_tipPercentage / 100);
            _totalDiscount = this.itemPrice - _tipPercentage;
          }
        }
      });
    }

    _tipPercentageController.addListener(_onTipAmountChanged);

    if (employees != null) {
      _dataTemp.addAll(employees);
      for (var e in employees) {
        result.add(Employee(e.id, e.name));
      }
    }
  }

  _onTipAmountChanged() {
    setState(() {
      discountValueItem = double.tryParse(_tipPercentageController.text) ?? 0;
      _tipPercentage = double.tryParse(_tipPercentageController.text) ?? 0.0;

      if (_tipPercentage < this.itemPrice) {
        if (_selectedId == '₫')
          _totalDiscount = this.itemPrice - _tipPercentage;

        if (_selectedId == '%') {
          _tipPercentage = this.itemPrice * (_tipPercentage / 100);
          _totalDiscount = this.itemPrice - _tipPercentage;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Giảm giá / Xếp nhân viên',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.red),
            onPressed: () => Navigator.of(context).pop(),
          )),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(width: 20),
                  Expanded(
                      child: TextField(
                    autofocus: false,
                    controller: _tipPercentageController,
                    decoration: InputDecoration(
                      labelText: 'Giảm giá',
                      suffixIcon: IconButton(
                        onPressed: () => _tipPercentageController.clear(),
                        icon: Icon(Icons.clear),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                  )),
                  DropdownButton<String>(
                    value: _selectedId,
                    underline: Container(),
                    items: <String>['₫', '%'].map((String value) {
                      return new DropdownMenuItem(
                          value: value, child: new Text(value));
                    }).toList(),
                    onChanged: (String value) {
                      setState(() {
                        _selectedId = value;
                        discountValueItem =
                            double.tryParse(_tipPercentageController.text);
                        discountUnitItem = value == '₫' ? "MONEY" : "PERCENT";
                      });
                      _onTipAmountChanged();
                    },
                  ),
                  SizedBox(width: 20)
                ],
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    ChipsInput(
                        key: _chipKey,
                        initialValue: employees != null ? result : [],
                        autofocus: true,
                        keyboardAppearance: Brightness.dark,
                        textCapitalization: TextCapitalization.words,
                        textStyle: const TextStyle(
                            height: 1.5, fontFamily: 'Roboto', fontSize: 16),
                        decoration:
                            const InputDecoration(labelText: 'Chọn nhân viên'),
                        findSuggestions: (String query) {
                          if (query.isNotEmpty) {
                            var lowercaseQuery = query.toLowerCase();
                            return mockResults.where((profile) {
                              return profile.name.toLowerCase().contains(
                                    query.toLowerCase(),
                                  );
                            }).toList(growable: false)
                              ..sort(
                                (a, b) => a.name
                                    .toLowerCase()
                                    .indexOf(lowercaseQuery)
                                    .compareTo(
                                      b.name
                                          .toLowerCase()
                                          .indexOf(lowercaseQuery),
                                    ),
                              );
                          }
                          return mockResults;
                        },
                        onChanged: (data) {},
                        chipBuilder: (context, state, dynamic profile) {
                          return InputChip(
                              key: ObjectKey(profile),
                              label: Text(profile.name),
                              onDeleted: () => {
                                    state.deleteChip(profile),
                                    _dataTemp
                                        .removeWhere((e) => e.id == profile.id)
                                  },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap);
                        },
                        suggestionBuilder: (context, state, dynamic profile) {
                          return ListTile(
                            key: ObjectKey(profile),
                            title: Text(profile.name),
                            onTap: () => {
                              _dataTemp.add(profile),
                              state.selectSuggestion(profile)
                            },
                          );
                        }),
                  ]),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$itemName',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Giá gốc:",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold)),
                    Text(
                      "${formatNumber(itemPrice)} VND",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Giảm giá:",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold)),
                    Text(
                      "${formatNumber(_tipPercentage)} VND",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Thành tiền:",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold)),
                    Text(
                      "${formatNumber(_totalDiscount)} VND",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      padding: EdgeInsets.symmetric(horizontal: 35.0),
                      child: Text(
                        "HỦY BỎ",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(horizontal: 35.0),
                      child: Text(
                        "ÁP DỤNG",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        if (_dataTemp.length > 0)
                          for (int i = 0; i < _dataTemp.length; i++) {
                            employeeList.add(
                              Employee(_dataTemp[i].id, _dataTemp[i].name),
                            );
                          }

                        Navigator.pop(context, [
                          discountValueItem,
                          discountUnitItem,
                          employeeList,
                          _totalDiscount
                        ]);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
