import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;
import 'package:parking_fee/screens/payment_detail.dart';
import '../model/payment.dart';
import '../services/payment_service.dart';

class HistoryPaymentScreen extends StatefulWidget {
  const HistoryPaymentScreen({super.key});

  @override
  State<HistoryPaymentScreen> createState() => _HistoryPaymentScreenState();
}

class _HistoryPaymentScreenState extends State<HistoryPaymentScreen> {
  List<dynamic>? _payments;
  late Payment payment;
  int _total = 0;
  String? _userId;
  final myBox = Hive.box('myBox');

  Future<void> _getListCarIsPayment() async {
    final Map<String, dynamic> response =
    await getListPaymentUserService.getListPaymentUser(_userId!);
    if (response['status'] == 'OK') {
      if (response['data'] is String && response['data'] == 'null') {
        setState(() {
          _payments = [];
          _total = 0;
        });
      } else {
        setState(() {
          _payments = response['data'];
          _total = _payments!.length;
        });
      }
    } else {
      print('Error occurred: ${response['message']}');
    }
  }

  Future<void> _getDetailPayment(String paymentId) async {
    final Map<String, dynamic> response =
    await getDetailPaymentUserService.getDetailPaymentUser(paymentId);
    if (response['status'] == 'OK') {
      final Map<String, dynamic> paymentData = response['data'];
      if (paymentData['HoursParking'] == 0) {
        paymentData['HoursParking'] = 0.toDouble();
      }
      payment = Payment.fromJson(paymentData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetailScreen(payment: payment),
        ),
      );
    } else {
      print('Error occurred: ${response['message']}');
    }
  }

  @override
  void initState() {
    super.initState();
    _userId = myBox.get('userId', defaultValue: '');
    _getListCarIsPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _payments == null
              ? const Center(child: CircularProgressIndicator())
              : _payments!.isEmpty
              ? const Center(child: Text('No bills available'))
              : ListView.builder(
            itemCount: _payments!.length,
            itemBuilder: (BuildContext context, int index) {
              final payment = _payments![index];
              return GestureDetector(
                onTap: () {
                  _getDetailPayment(payment['PaymentId']);
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Payment Id: ${payment['PaymentId']}'),
                            Text(
                                'Method: ${payment['Method']}'),
                            Text(
                                'Hours Parking: ${payment['HoursParking']}'),
                            Text(
                                'Price: ${intl.NumberFormat.decimalPattern().format(payment['Price'])} VND'),
                            Text(
                                'Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(payment['CreatedAt']))}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Total Items: $_total',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
