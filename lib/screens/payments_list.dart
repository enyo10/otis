import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/sql_helper.dart';
import '../models/payment.dart';
import '../widgets/otis_appBar_title.dart';
import '../widgets/payment_list_tile.dart';

class PaymentsList extends StatefulWidget {
  final Occupant occupant;
  const PaymentsList({Key? key, required this.occupant}) : super(key: key);

  @override
  State<PaymentsList> createState() => _PaymentsListState();
}

class _PaymentsListState extends State<PaymentsList> {
  final TextEditingController _editingController = TextEditingController();
  Icon _searchIcon = const Icon(Icons.search);

  Widget _appBarTitle =const AppBarTitleWidget(title: "Payements", ratio: 40);

  List<Payment> _payments = [];
  final List<Payment> _items = [];

  @override
  void initState() {
    _loadPayments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.10;
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
      body: Container(
        padding: EdgeInsets.only(bottom: height +10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const PaymentTileHeader(),
            Expanded(
              child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, index) {
                    var payment = _items.elementAt(index);
                    return PaymentListTile(payment: payment);
                  }),
            ),
          ],
        ),
      ),
      bottomSheet: TotalAmountWidget(
        amount: getTotalAmount(_items),
        height: height,
      ),
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
            onChanged: (value) {
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
        _editingController.clear();

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
