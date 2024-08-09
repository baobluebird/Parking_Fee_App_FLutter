import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../ipconfig/ip.dart';
import '../model/bill.dart';
import '../services/fee_service.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;

import '../services/payment_service.dart';
import 'bill_detail.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<dynamic>? _parkingOverTimeLocations;
  List<dynamic>? _duringParkingLocations;
  Set<Marker> _markers = {};
  static CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 14.4746,
  );
  late BitmapDescriptor _userIcon;
  late BitmapDescriptor _duringParking;
  late BitmapDescriptor _parkingOverTime;
  late Bill bill;
  int _total1 = 0;
  int _total2 = 0;

  bool _iconsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons().then((_) {
      _iconsLoaded = true;
      _getUserLocation();
      _getListLocationCarDuringParking();
      _getListLocationCarParkingOverTime();
      _showMyLocation();
    });
    _startLocationUpdates();
  }

  void _updateMarkers() {
    _markers.clear();
    _getUserLocation();
    _getListLocationCarDuringParking();
    _getListLocationCarParkingOverTime();
    _showMyLocation();
  }

  Future<void> _moveParkingOverTime(String id) async {
    final response = await http.post(
      Uri.parse('$ip/fee/is-parking/$id'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _duringParkingLocations!.removeWhere((bill) => bill['_id'] == id);
        _total1 = _duringParkingLocations!.length;
      });

      // Đóng showModalBottomSheet trước khi cập nhật marker
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Move bill successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _updateMarkers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to move bill.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showMoveConfirmationDialog(String billId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận di chuyển"),
          content: Text("Bạn có chắc chắn muốn di chuyển hóa đơn này không?"),
          actions: <Widget>[
            TextButton(
              child: Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Xác nhận"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _moveParkingOverTime(billId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _isPayment(String billId, String userId, String payId, double hour, int amount, String method) async {
    final response = await isPaymentService.isPayment(billId, userId, payId, hour, amount, method);
    if(response['status'] == 'OK') {

      setState(() {
        _parkingOverTimeLocations!.removeWhere((bill) => bill['_id'] == billId);
        _total2 = _parkingOverTimeLocations!.length;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Set Payment successful'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      _updateMarkers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set payment.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _showDeleteConfirmationDialog(String billId, String nameList) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa hoá đơn này không?"),
          actions: <Widget>[
            TextButton(
              child: Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Xác nhận"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteBill(billId, nameList);
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _deleteBill(String billId, String nameList) async {
    final response = await http.delete(
      Uri.parse('$ip/fee/delete-bill/$billId'),
    );

    if (response.statusCode == 200) {
      if(nameList == 'parkingOverTimeLocations'){
        setState(() {
          _parkingOverTimeLocations!.removeWhere((bill) => bill['_id'] == billId);
          _total2 = _parkingOverTimeLocations!.length;
        });
      } else {
        setState(() {
          _duringParkingLocations!.removeWhere((bill) => bill['_id'] == billId);
          _total1 = _duringParkingLocations!.length;
        });
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _updateMarkers();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete bill.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _showPaymentConfirmationDialog(String billId, String feeId, double hoursParking, int price) async {
    var uuid = Uuid();
    String uniqueId = uuid.v4();

    final response = await http.get(
      Uri.parse('$ip/fee/get-user-id/$feeId'),
    );
    var decodedResponse = json.decode(response.body);
    String userId = decodedResponse['data']['UserId'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận thanh toán"),
          content: Text("Bạn có chắc chắn đặt hoá đơn này thành đã thanh toán không?"),
          actions: <Widget>[
            TextButton(
              child: Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Xác nhận"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _isPayment(billId, userId, uniqueId, hoursParking, price, 'Tiền mặt');
              },
            ),
          ],
        );
      },
    );
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

  Future<void> _loadCustomIcons() async {
    final Uint8List location =
        await getBytesFromAsset('assets/images/user_icon.png', 100);
    final Uint8List _duringParkingIcon =
        await getBytesFromAsset('assets/images/during_parking.png', 130);
    final Uint8List _parkingOverTimeIcon =
        await getBytesFromAsset('assets/images/parking_over_time.png', 130);
    setState(() {
      _userIcon = BitmapDescriptor.fromBytes(location);
      _duringParking = BitmapDescriptor.fromBytes(_duringParkingIcon);
      _parkingOverTime = BitmapDescriptor.fromBytes(_parkingOverTimeIcon);
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.4746,
      );
      _addMarker(position);
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  void _showMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _updateUserLocationMarker(position);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ));
    } catch (e) {
      print('Error showing current location: $e');
    }
  }

  void _updateUserLocationMarker(Position position) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'myLocation');
      _markers.add(
        Marker(
          icon: _userIcon,
          markerId: MarkerId('myLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: 'This is where you are.',
          ),
        ),
      );
    });
  }

  void _addMarker(Position position) {
    setState(() {
      _markers.add(
        Marker(
          icon: _userIcon,
          markerId: MarkerId('myLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: 'This is where you are.',
          ),
        ),
      );
    });
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high, distanceFilter: 10)
        .listen((Position position) {
      _updateUserLocationMarker(position);
    });
  }

  Future<void> _getListLocationCarDuringParking() async {
    final Map<String, dynamic> response =
        await getListLocationCarDuringParkingService
            .getListLocationCarDuringParking();
    if (response['status'] == 'OK') {
      print(response['data']);
      setState(() {
        _duringParkingLocations =
            response['data'] == 'null' ? [] : response['data'];
        _total1 = _duringParkingLocations!.length;
      });
      if (_iconsLoaded) {
        _addMarkersDuringParkingFromBills();
      }
    } else {
      print('Error occurred: ${response['message']}');
    }
  }

  Future<void> _getListLocationCarParkingOverTime() async {
    final Map<String, dynamic> response =
        await getListLocationCarParkingOverTimeService
            .getListLocationCarParkingOverTime();
    if (response['status'] == 'OK') {
      setState(() {
        _parkingOverTimeLocations =
            response['data'] == 'null' ? [] : response['data'];
        _total2 = _parkingOverTimeLocations!.length;
      });
      if (_iconsLoaded) {
        _addMarkersParkingOverTimeFromBills();
      }
    } else {
      print('Error occurred: ${response['message']}');
    }
  }

  void _addMarkersDuringParkingFromBills() {
    if (_duringParkingLocations != null) {
      for (var item in _duringParkingLocations!) {
        var location = item['Location'];
        var coordinates = _parseLocation(location);
        if (coordinates != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(location),
              position: coordinates,
              infoWindow: InfoWindow(
                title: 'License Plate: ${item['LicensePlate']}',
                snippet:
                'Price: ${intl.NumberFormat.decimalPattern().format(item['Price'])}, Hours: ${item['hour']}h',
              ),
              icon: _duringParking, // Use custom icon
            ),
          );
        }
      }
      setState(() {});
    }
  }

  void _addMarkersParkingOverTimeFromBills() {
    if (_parkingOverTimeLocations != null) {
      for (var item in _parkingOverTimeLocations!) {
        var location = item['Location'];
        var coordinates = _parseLocation(location);
        if (coordinates != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(location),
              position: coordinates,
              infoWindow: InfoWindow(
                title: 'License Plate: ${item['LicensePlate']}',
                snippet:
                'Price: ${intl.NumberFormat.decimalPattern().format(item['Price'])}, Hours: ${item['HoursParking']}h',
              ),
              icon: _parkingOverTime, // Use custom icon
            ),
          );
        }
      }
      setState(() {});
    }
  }

  LatLng? _parseLocation(String? location) {
    if (location == null) return null;
    var latitudeRegExp = RegExp(r'latitude:([0-9.]+)');
    var longitudeRegExp = RegExp(r'longitude:([0-9.]+)');
    var latitudeMatch = latitudeRegExp.firstMatch(location);
    var longitudeMatch = longitudeRegExp.firstMatch(location);
    if (latitudeMatch != null && longitudeMatch != null) {
      var latitude = double.tryParse(latitudeMatch.group(1)!);
      var longitude = double.tryParse(longitudeMatch.group(1)!);
      if (latitude != null && longitude != null) {
        return LatLng(latitude, longitude);
      }
    }
    return null;
  }

  void _goToMarkerDuringParking(
      String location, String licensePlate, int price) async {
    var coordinates = _parseLocation(location);
    if (coordinates != null) {
      setState(() async {
        _markers.add(
          Marker(
            icon: _duringParking,
            markerId: MarkerId('Car Parking'),
            position: coordinates,
            infoWindow: InfoWindow(
              title: '$licensePlate',
              snippet: '$price',
            ),
          ),
        );
        final GoogleMapController controller = await _controller.future;

        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(coordinates.latitude, coordinates.longitude),
            zoom: 17.0,
          ),
        ));
      });
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: coordinates,
          zoom: 14.0,
        ),
      ));
    } else {
      print("Invalid location string format");
    }
  }

  void _showDuringParkingDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 70.0,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Danh sách xe đang đỗ: $_total1',
                  style: GoogleFonts.beVietnamPro(
                    textStyle: const TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ...?_duringParkingLocations
                ?.map((item) => ListTile(
                      title: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.blueAccent,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['AddressParking'],
                              style: GoogleFonts.beVietnamPro(
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['LicensePlate'],
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF002FD3),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.move_up, color: Colors.blue),
                                      onPressed: () {
                                        _showMoveConfirmationDialog(item['BillId']);
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                        onPressed: () {
                                          _getDetailBill(item['BillId']);
                                        },
                                        icon: Icon(Icons.library_add_sharp)),
                                    IconButton(
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(item['BillId'], 'duringParkingLocations');
                                        },
                                        icon: Icon(Icons.delete_forever,color: Colors.red)
                                    ),
                                  ],
                                ),

                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${intl.NumberFormat.decimalPattern().format(item['Price'])}VND',
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF0060A9),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${item['hour']}h',
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF0060A9),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _goToMarkerDuringParking(item['Location'],
                            item['LicensePlate'], item['Price']);
                      },
                    ))
                .toList(),
          ],
        );
      },
    );
  }

  void _showOverTimeDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 70.0,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Danh sách xe nợ phí: $_total2',
                  style: GoogleFonts.beVietnamPro(
                    textStyle: const TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ...?_parkingOverTimeLocations
                ?.map((item) => ListTile(
                      title: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.blueAccent,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['AddressParking'],
                              style: GoogleFonts.beVietnamPro(
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['LicensePlate'],
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF002FD3),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.payment_outlined, color: Colors.deepPurpleAccent),
                                      onPressed: () {
                                        _showPaymentConfirmationDialog(
                                          item['BillId'],
                                          item['FeeId'],
                                          item['HoursParking'],
                                          item['Price'],
                                        );
                                      },
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          _getDetailBill(item['BillId']);
                                        },
                                        icon: Icon(Icons.library_add_sharp)
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(item['BillId'] , 'parkingOverTimeLocations');
                                        },
                                        icon: Icon(Icons.delete_forever,color: Colors.red)
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${intl.NumberFormat.decimalPattern().format(item['Price'])}VND',
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF0060A9),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${item['HoursParking']}h',
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF0060A9),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _goToMarkerDuringParking(item['Location'],
                            item['LicensePlate'], item['Price']);
                      },
                    ))
                .toList(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Stack(
          children: [
            GoogleMap(
              mapType: MapType.terrain,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
            ),
            Positioned(
              bottom: 250,
              right: 8,
              child: FloatingActionButton(
                heroTag: 'reload data',
                mini: true,
                shape: const CircleBorder(),
                backgroundColor: Color(0xFFFFFFFF),
                onPressed: _updateMarkers,
                tooltip: 'Reload Data',
                child: Icon(Icons.refresh, color: Colors.blue,),
              ),
            ),
            Positioned(
              bottom: 200,
              right: 8,
              child: FloatingActionButton(
                heroTag: 'drawerButton2',
                mini: true,
                shape: const CircleBorder(),
                backgroundColor: Color(0xFFFFFFFF),
                onPressed: () {
                  _showOverTimeDrawer(context);
                },
                tooltip: 'Show Drawer Parking Over Time',
                child: Image.asset('assets/images/parking_over_time.png',
                    width: 30, height: 30),
              ),
            ),
            Positioned(
              bottom: 150,
              right: 8,
              child: FloatingActionButton(
                heroTag: 'drawerButton1',
                mini: true,
                shape: const CircleBorder(),
                backgroundColor: Color(0xFFFFFFFF),
                onPressed: () {
                  _showDuringParkingDrawer(context);
                },
                tooltip: 'Show Drawer During Parking',
                child: Image.asset('assets/images/during_parking.png',
                    width: 30, height: 30),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 8,
              child: FloatingActionButton(
                heroTag: 'locationButton',
                mini: true,
                shape: const CircleBorder(),
                backgroundColor: Color(0xFFFFFFFF),
                onPressed: _showMyLocation,
                tooltip: 'Location User',
                child: Image.asset('assets/images/user_icon.png',
                    width: 30, height: 30),
              ),
            ),
            Positioned(
              bottom: 25.0,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white70,
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Over Time',
                            style: GoogleFonts.beVietnamPro(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 35),
                          Image.asset('assets/images/parking_over_time.png',
                              width: 40, height: 40),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'During Parking',
                            style: GoogleFonts.beVietnamPro(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Image.asset('assets/images/during_parking.png',
                              width: 40, height: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}
