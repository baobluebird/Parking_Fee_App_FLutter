import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:parking_fee/screens/payment.dart';
import '../model/bill.dart';
import '../services/fee_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;

import 'bill_detail.dart';

class UserParkingListScreen extends StatefulWidget {
  const UserParkingListScreen({Key? key}) : super(key: key);

  @override
  State<UserParkingListScreen> createState() => _UserParkingListScreenState();
}

class _UserParkingListScreenState extends State<UserParkingListScreen> {
  List<dynamic>? _bills;
  late Bill bill;
  int _total = 0;
  final myBox = Hive.box('myBox');
  String? _userId;

  Future<void> _getListCarDuringParkingByUser() async {
    final Map<String, dynamic> response =
    await getListCarDuringParkingByUserService.getListCarDuringParkingByUser(_userId!);
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
      if (billData['HoursParking'] == 0) {
        billData['HoursParking'] = 0.toDouble();
      }
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

  @override
  void initState() {
    super.initState();
    _userId = myBox.get('userId', defaultValue: '');
    _getListCarDuringParkingByUser();
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
              : RefreshIndicator(
            onRefresh: _getListCarDuringParkingByUser,
            child: ListView.builder(
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
                                  'Hours Parking To Current: ${bill['hour']}'),
                              Text(
                                  'Price: ${intl.NumberFormat.decimalPattern().format(bill['Price'])} VND'),
                              Text(
                                  'Time start parking: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(bill['CreatedAt']))}'),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (bill['HoursParking'] == 0) {
                              bill['HoursParking'] = 0.toDouble();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                      userId: _userId,
                                      billId: bill['BillId'],
                                      hour: double.parse(
                                          bill['hour'].toString()),
                                      amount: bill['Price'])),
                            );
                          },
                          icon: Icon(
                            Icons.payment,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
