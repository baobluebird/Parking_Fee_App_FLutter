import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../page/home_user.dart';
import '../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final String? userId;
  final String billId;
  final double hour;
  final int amount;

  PaymentScreen({Key? key, required this.userId, required this.billId, required this.hour, required this.amount}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late TextEditingController _billIdController;
  late TextEditingController _amountController;
  bool _isLoading = false;
  String _selectedPaymentMethod = 'Credit Card';
  StreamSubscription? _sub;
  String _billID = '';
  String _paymentId ='';
  @override
  void initState() {
    super.initState();
    _billIdController = TextEditingController(text: widget.billId);
    _amountController = TextEditingController(text: widget.amount.toString());
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    String err = '';
    _sub = linkStream.listen((String? link) {
      if (link != null && link.contains('myapp://payment/success')) {
        err = "OK";
        _handlePaymentSuccess(err);
      } else {
        err = "ERR";
        _handlePaymentSuccess(err);
      }
    }, onError: (err) {
      print('Error: $err');
    });
  }

  void _handlePaymentSuccess(String status) async {
    if (status == 'ERR') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => UserHome(),
      ));
    } else {
      await isPaymentService.isPayment(_billID, widget.userId!, _paymentId, widget.hour, widget.amount, _selectedPaymentMethod);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => UserHome(),
      ));
    }
  }

  Future<void> _payBill(int amount) async {
    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> response = await createPaymentService.createPayment(amount);
    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 'OK') {
      setState(() {
        _paymentId = response['paymentId'];
      });
      final Uri orderUrl = Uri.parse(response['approval_url']);
      await launchUrl(orderUrl);
    } else {
      print('Error occurred: ${response['return_message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: ${response['return_message']}')),
      );
    }
  }

  @override
  void dispose() {
    _billIdController.dispose();
    _amountController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Bill ID: ${widget.billId}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('User ID: ${widget.userId}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Hours Parking: ${widget.hour}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Amount: \$${widget.amount}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              items: <String>['Credit Card', 'PayPal', 'Bank Transfer']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                final String userId = widget.userId!;
                final String billId = widget.billId;
                final double hour = widget.hour;
                final int amount = widget.amount;
                setState(() {
                  _billID = billId;
                });
                _payBill(amount);
              },
              child: Text('Pay Bill'),
            ),
          ],
        ),
      ),
    );
  }
}
