import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/sql_helper.dart';

import '../helper.dart';
import '../models/payment.dart';

class PaymentsList extends StatefulWidget {
  final Occupant occupant;
  const PaymentsList({Key? key, required this.occupant}) : super(key: key);

  @override
  State<PaymentsList> createState() => _PaymentsListState();
}

class _PaymentsListState extends State<PaymentsList> {
  final TextEditingController _editingController = TextEditingController();
  Icon _searchIcon = const Icon(Icons.search);
  Widget _appBarTitle = const Text('Les payements');

  List<Payment> _payments = [];
  final List<Payment> _items = [];

  @override
  void initState() {
    _loadPayments();
    super.initState();
    //_items.addAll(_payments);

    //_loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: [
          IconButton(
            onPressed: () {
              _searchPressed();
            },
            icon: _searchIcon,
          )
        ],
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, index) {
            var payment = _items.elementAt(index);
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                //semanticContainer: false,
                shadowColor: Colors.green,
                elevation: 8.0,
                /*shape: OutlineInputBorder(*/
                /*    borderRadius: BorderRadius.circular(10),*/
                /*    borderSide: const BorderSide(color: Colors.white))*/
                child: ListTile(
                  textColor: Colors.black,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      payment.paymentPeriod.toString(),
                    ),
                  ),
                  title: Text(" ${payment.amount} ${payment.currency}"),
                  trailing: Text(
                    " ${stringValue(payment.paymentDate)}",
                  ),
                ),
              ),
            );
          }),
    );
  }

  _loadPayments() async {
    var list = await SQLHelper.getPayments(widget.occupant.id)
        .then((value) => value.map((e) => Payment.fromMap(e)).toList());

    setState(() {
      _payments = list;
      _items.addAll(_payments);
    });
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = const Icon(Icons.close);
        _appBarTitle = Container(
          color: Colors.white,
          child: TextField(
            onChanged: (value){
              _filterSearchResults(value);
            },
            controller: _editingController,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Chercher...'),
          ),
        );
      } else {
        _searchIcon = const Icon(Icons.search);
        _appBarTitle = const Text('Les payements');
        //  filteredNames = names;
        _editingController.clear();
        //_filter.clear();
        setState(() {
          _items.clear();
          _items.addAll(_payments);
        });
      }
    });
  }

  void _filterSearchResults(String query) {
    List<Payment> payments = <Payment>[];
    payments.addAll(_payments);
    if (query.isNotEmpty) {
      List<Payment> dummyListData = <Payment>[];
      for (var payment in payments) {
        if (payment.stringValue().contains(query)) {
          dummyListData.add(payment);
        }
      }
      setState(() {
        _items.clear();
        _items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _items.clear();
        _items.addAll(payments);
      });
    }
  }
}
