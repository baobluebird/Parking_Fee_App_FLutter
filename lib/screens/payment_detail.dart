import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/payment.dart';

class PaymentDetailScreen extends StatefulWidget {
  final Payment? payment;

  const PaymentDetailScreen({Key? key, required this.payment}) : super(key: key);

  @override
  _PaymentDetailScreenState createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Payment ID: ${widget.payment?.BillId}'),
              Text('BillId: ${widget.payment?.BillId}'),
              Text('PayId: ${widget.payment?.PayId}'),
              Text('Method: ${widget.payment?.Method}'),
              Text('Price: ${widget.payment?.Price}'),
              Text('Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(widget.payment!.CreatedAt))}'),
            ],
          ),
        ),
      ),
    );
  }



}
