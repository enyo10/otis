import 'package:flutter/material.dart';

import '../models/payment.dart';
import '../models/rent_period.dart';
import '../models/sql_helper.dart';

class IconWidget extends StatefulWidget {
  final List<Payment> payments;
  final int id;
  const IconWidget({Key? key, required this.id, required this.payments})
      : super(key: key);

  @override
  State<IconWidget> createState() => _IconWidgetState();
}

class _IconWidgetState extends State<IconWidget> {
  late Icon icon;

  @override
  void initState() {
    super.initState();
    icon = const Icon(
      Icons.close,
      color: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.payments.isNotEmpty) {
      _checkPaymentStatus();
    }
    return Container(
      child: icon,
    );
  }

  Future<Rent?> _loadRent(int lodgingId, DateTime dateTime) async {
    Rent? rent;
    await SQLHelper.getRents(lodgingId).then((value) {
      for (dynamic rentMap in value) {
        if (Rent.formMap(rentMap).startDate.microsecondsSinceEpoch <
            dateTime.microsecondsSinceEpoch) {
          rent = Rent.formMap(rentMap);
        }
      }
    });
    return rent;
  }

  double _getSum(List<Payment> payments) {
    var sum = 0.0;

    for (Payment payment in payments) {
      sum += payment.amount / payment.rate;
    }
    return sum;
  }

  _checkPaymentStatus() {
    var payments = widget.payments;
    var periodPayment = payments.elementAt(0).paymentPeriod;
    _loadRent(widget.id, DateTime(periodPayment.year, periodPayment.month))
        .then((value) {
      if (_getSum(payments) == value?.rent) {
        print("Equal");

        icon = const Icon(
          Icons.check,
          color: Colors.green,
        );
      } else {
        print("Not Equal");

        icon = const Icon(
          Icons.check_box_outlined,
          color: Colors.orange,
        );
      }
    });
    setState(() {});
  }
}
