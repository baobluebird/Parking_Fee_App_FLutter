import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../model/bill.dart';
import '../services/fee_service.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;


import 'bill_detail.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  List<dynamic>? _parkingLocations;
  List<dynamic>? _duringLocations;
  Set<Marker> _markers = {};
  static CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 14.4746,
  );
  late BitmapDescriptor _userIcon;
  late BitmapDescriptor _duringParking;
  late BitmapDescriptor _parkingOverTime;
  late Bill bill;

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
      _markers.removeWhere((marker) =>
      marker.markerId.value == 'myLocation' &&
          marker.icon == _userIcon &&
          marker.icon == _duringParking &&
          marker.icon == _parkingOverTime);
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
      setState(() {
        _duringLocations = response['data'] == 'null' ? [] : response['data'];
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
        _parkingLocations = response['data'] == 'null' ? [] : response['data'];
      });
      if (_iconsLoaded) {
        _addMarkersParkingOverTimeFromBills();
      }
    } else {
      print('Error occurred: ${response['message']}');
    }
  }

  void _addMarkersParkingOverTimeFromBills() {
    if (_parkingLocations != null) {
      for (var item in _parkingLocations!) {
        var location = item['Location'];
        var coordinates = _parseLocation(location);
        if (coordinates != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(location),
              position: coordinates,
              infoWindow: InfoWindow(
                title: 'License Plate: ${item['LicensePlate']}',
                snippet: 'Price: ${intl.NumberFormat.decimalPattern().format(item['Price'])}, Hours: ${item['HoursParking']}h',
              ),
              icon: _parkingOverTime, // Use custom icon
            ),
          );
        }
      }
      setState(() {});
    }
  }

  void _addMarkersDuringParkingFromBills() {
    if (_duringLocations != null) {
      for (var item in _duringLocations!) {
        var location = item['Location'];
        var coordinates = _parseLocation(location);
        if (coordinates != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(location),
              position: coordinates,
              infoWindow: InfoWindow(
                title: 'License Plate: ${item['LicensePlate']}',
                snippet: 'Price: ${intl.NumberFormat.decimalPattern().format(item['Price'])}, Hours: ${item['hour']}h',
              ),
              icon: _duringParking, // Use custom icon
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
                  'Danh sách xe đang đỗ',
                  style: GoogleFonts.beVietnamPro(
                    textStyle: const TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ...?_duringLocations
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
                        IconButton(
                            onPressed: () {
                              _getDetailBill(item['BillId']);
                            },
                            icon: Icon(Icons.library_add_sharp))
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
                  'Danh sách xe nợ phí',
                  style: GoogleFonts.beVietnamPro(
                    textStyle: const TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ...?_parkingLocations
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
                        IconButton(
                            onPressed: () {
                              _getDetailBill(item['BillId']);
                            },
                            icon: Icon(Icons.library_add_sharp))
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
