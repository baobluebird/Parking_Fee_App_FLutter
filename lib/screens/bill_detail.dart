import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/bill.dart';

class BillScreen extends StatefulWidget {
  final Bill? bill;

  const BillScreen({Key? key, required this.bill}) : super(key: key);

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  late GoogleMapController _mapController;
  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();
    _initialPosition = _parseLatLng(widget.bill?.Location);
  }

  LatLng _parseLatLng(String? location) {
    final regex = RegExp(r'LatLng\(latitude:(.*), longitude:(.*)\)');
    final match = regex.firstMatch(location!);
    if (match != null) {
      final latitude = double.parse(match.group(1)!);
      final longitude = double.parse(match.group(2)!);
      return LatLng(latitude, longitude);
    }
    throw Exception('Invalid location format');
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Bill ID: ${widget.bill?.BillId}'),
              Text('License Plate: ${widget.bill?.LicensePlate}'),
              Text('Location: ${widget.bill?.Location}'),
              Text('Address Parking: ${widget.bill?.AddressParking}'),
              Text('Is Payment: ${widget.bill?.IsPayment}'),
              const SizedBox(height: 16),
              const Text('Image:'),
              const SizedBox(height: 8),
              Image.network('${widget.bill?.ImageName}'),
              const SizedBox(height: 16),
              Text('Time Parking: ${widget.bill?.HoursParking}'),
              Text('Price: ${intl.NumberFormat.decimalPattern().format(widget.bill?.Price)} VND'),
              Text('Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(widget.bill!.CreatedAt))}'),
              Text('UpdatedAt At: ${widget.bill?.UpdatedAt != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(widget.bill!.UpdatedAt!)) : 'Still Parking'}'),
              Container(
                height: 300,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 18.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('detectionLocation'),
                      position: _initialPosition,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



}
