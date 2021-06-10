import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../contains/contains.dart';

class TipCalculatorPage extends StatefulWidget {
  const TipCalculatorPage(
      {this.discountValue,
      this.discountUnit,
      this.discountPrice,
      this.costPrice});

  final double discountValue;
  final String discountUnit;
  final double costPrice;
  final double discountPrice;

  @override
  _TipCalculatorPageState createState() => _TipCalculatorPageState(
      discountValue: discountValue,
      discountUnit: discountUnit,
      costPrice: costPrice,
      discount: discountPrice);
}

class _TipCalculatorPageState extends State<TipCalculatorPage> {
  _TipCalculatorPageState(
      {this.discountValue, this.discountUnit, this.discount, this.costPrice});

  double discountValue;
  double costPrice;
  double discount;
  String _selectedId = '₫';
  String discountUnit;
  double _tipPercentage = 0;
  double _totalDiscount;

  final TextEditingController _tipPercentageController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    _totalDiscount = costPrice;
    if (discountValue != 0) {
      _tipPercentageController.text =
          discountValue.toString().replaceAll(".0", "");
      _onTipAmountChanged();
    }

    if (discountUnit == "MONEY")
      _selectedId = '₫';
    else
      _selectedId = '%';

    _tipPercentageController.addListener(_onTipAmountChanged);
  }

  _onTipAmountChanged() {
    setState(() {
      discountValue = double.tryParse(_tipPercentageController.text) ?? 0;
      _tipPercentage = double.tryParse(_tipPercentageController.text) ?? 0.0;

      if (_tipPercentage < costPrice) {
        if (_selectedId == '₫') _totalDiscount = costPrice - _tipPercentage;

        if (_selectedId == '%') {
          _tipPercentage = costPrice * (_tipPercentage / 100);
          _totalDiscount = costPrice - _tipPercentage;
        }
      }
    });
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 200,
        width: 450,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: TextField(
                  autofocus: true,
                  controller: _tipPercentageController,
                  decoration: InputDecoration(
                    hintText: 'Giảm giá',
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
                      discountValue =
                          double.tryParse(_tipPercentageController.text);
                      discountUnit = value == '₫' ? "MONEY" : "PERCENT";
                    });
                    _onTipAmountChanged();
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Giá gốc:",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "${formatNumber(costPrice)}",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 14.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Giảm giá:",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "${formatNumber(_tipPercentage)}",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 14.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Thành tiền:",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "${formatNumber(_totalDiscount)}",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'ĐÓNG',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text(
            'ÁP DỤNG',
            style:
                TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(
            context,
            [discountValue, discountUnit, _tipPercentage, _totalDiscount],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
