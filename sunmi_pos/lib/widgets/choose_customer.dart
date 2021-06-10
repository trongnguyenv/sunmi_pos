import 'package:flutter/material.dart';
import '../model/model.dart';
import '../pages/pages.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../repositories/repository.dart';

class CustomerPage extends StatefulWidget {
  final Salon salon;
  CustomerPage({this.salon});
  @override
  _CustomerPageState createState() => new _CustomerPageState(salon: salon);
}

class _CustomerPageState extends State<CustomerPage> {
  final Salon salon;
  TextEditingController _typeAheadController = new TextEditingController();
  TextEditingController _typeNameController = new TextEditingController();
  dynamic _customer;

  _CustomerPageState({this.salon});

  @override
  Widget build(BuildContext context) {
    final fieldPhone = TypeAheadField<Customers>(
      hideSuggestionsOnKeyboardHide: false,
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(
            labelText: 'Nhập theo số điện thoại hoặc mã khách hàng',
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => _typeAheadController.clear(),
            )),
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
        height: 100,
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
        Navigator.pop(context, customer);

        _typeAheadController.clear();
      },
    );

    final fieldNameCustome = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        labelText: 'Nhập tên khách hàng',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
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
            child: Text('TẠO'),
            onPressed: () async {
              FocusScope.of(context).unfocus();
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
                  ..showSnackBar(SnackBar(
                      content: Text('Tạo mới khách hàng thành công !'),
                      backgroundColor: Colors.green));

                Navigator.pop(context, _customerGet);
              } else {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text('Khách hàng đã tồn tại !'),
                      backgroundColor: Colors.red));
              }
            },
          ),
        ),
        Container(
          width: 130.0,
          height: 40.0,
          child: RaisedButton(
              textColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text('HỦY'),
              onPressed: () => Navigator.pop(context)),
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
              fieldPhone,
              SizedBox(height: 15),
              fieldNameCustome,
              SizedBox(height: 30),
              buttonChoose,
              SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}
