import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../ipconfig/ip.dart';
import '../model/bill.dart';
import '../services/fee_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;

import '../services/payment_service.dart';
import 'bill_detail.dart';

class ListBillOverTime extends StatefulWidget {
  const ListBillOverTime({Key? key}) : super(key: key);

  @override
  State<ListBillOverTime> createState() => _ListBillOverTimeState();
}

class _ListBillOverTimeState extends State<ListBillOverTime> {
  List<dynamic>? _bills;
  late Bill bill;
  int _total = 0;
  final myBox = Hive.box('myBox');
  String? _userId;

  Future<void> _getListCarParkingOverTime() async {
    final Map<String, dynamic> response =
    await getListCarParkingOverTimeService.getListCarParkingOverTime();
    if (response['status'] == 'OK') {
      if (response['data'] is String && response['data'] == 'null') {
        setState(() {
          _bills = [];
          _total = 0;
        });
      } else {
        setState(() {
          _bills = response['data'];
          _total = _bills!.length;
        });
      }
    } else {
      print('Error occurred: ${response['message']}');
    }
  }

  Future<void> _getDetailBill(String id) async {
    final Map<String, dynamic> response =
    await getDetailBillService.getDetailBill(id);
    if (response['status'] == 'OK') {
      final Map<String, dynamic> billData = response['data'];
      bill = Bill.fromJson(billData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillScreen(bill: bill),
        ),
      );
    } else {
      print('Error occurred: ${response['message']}');
    }
  }

  Future<void> _isPayment(String billId, String userId, String payId, double hour, int amount, String method) async {
    await isPaymentService.isPayment(billId, userId, payId, hour, amount, method);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
    _getListCarParkingOverTime();
  }

  Future<void> _deleteBill(String id) async {
    final response = await http.delete(
      Uri.parse('$ip/fee/delete-bill/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _bills!.removeWhere((bill) => bill['_id'] == id);
        _total = _bills!.length;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete bill.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _userId = myBox.get('userId', defaultValue: '');
    _getListCarParkingOverTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _bills == null
              ? const Center(child: CircularProgressIndicator())
              : _bills!.isEmpty
              ? const Center(child: Text('No bills available'))
              : ListView.builder(
            itemCount: _bills!.length,
            itemBuilder: (BuildContext context, int index) {
              final bill = _bills![index];
              return GestureDetector(
                onTap: () {
                  _getDetailBill(bill['BillId']);
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
                      CircleAvatar(
                        backgroundImage:
                        Image.network('${bill['ImageName']}')
                            .image,
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                                'License Plate: ${bill['LicensePlate']}'),
                            Text(
                                'Address Parking: ${bill['AddressParking']}'),
                            Text(
                                'Is Payment: ${bill['IsPayment']}'),
                            Text(
                                'Hours Parking: ${bill['HoursParking']}'),
                            Text(
                                'Price: ${intl.NumberFormat.decimalPattern().format(bill['Price'])} VND'),
                            Text(
                                'Time start parking: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(bill['CreatedAt']))}'),
                            Text(
                                'Time end parking: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(bill['UpdatedAt']))}'),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.payment_outlined, color: Colors.deepPurpleAccent),
                            onPressed: () async {
                              var uuid = Uuid();
                              String uniqueId = uuid.v4();
                              if (bill['HoursParking'] == 0) {
                                bill['HoursParking'] = 0.toDouble();
                              }
                              await _isPayment(bill['BillId'], _userId!, uniqueId, bill['HoursParking'], bill['Price'], 'Tiền mặt');
                            },
                          ),
                          SizedBox(height: 20,),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () async {
                              await _deleteBill(bill['BillId']);
                              _getListCarParkingOverTime();
                            },
                          ),
                        ],
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
