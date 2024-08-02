import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:parking_fee/screens/payment.dart';
import '../model/bill.dart';
import '../services/fee_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;

import 'bill_detail.dart';

class UserOverTimeParkingListScreen extends StatefulWidget {
  const UserOverTimeParkingListScreen({Key? key}) : super(key: key);

  @override
  State<UserOverTimeParkingListScreen> createState() => _UserOverTimeParkingListScreenState();
}

class _UserOverTimeParkingListScreenState extends State<UserOverTimeParkingListScreen> {
  List<dynamic>? _bills;
  late Bill bill;
  int _total = 0;
  final myBox = Hive.box('myBox');
  String? _userId;

  Future<void> _getListCarParkingOverTimeByUser() async {
    final Map<String, dynamic> response =
    await getListCarParkingOverTimeByUserService.getListCarParkingOverTimeByUser(_userId!);
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

  @override
  void initState() {
    super.initState();
    _userId = myBox.get('userId', defaultValue: '');
    _getListCarParkingOverTimeByUser();
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
            onRefresh: _getListCarParkingOverTimeByUser,
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
                        IconButton(
                          onPressed: () async{
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentScreen(userId: _userId, billId: bill['BillId'], hour:bill['HoursParking'], amount: bill['Price'])),
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
