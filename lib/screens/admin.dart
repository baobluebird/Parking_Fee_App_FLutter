import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocode/geocode.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'dart:async'; // Thêm dòng này

import '../components/list.dart';
import '../model/bill.dart';
import '../screens/bill_detail.dart';
import '../services/upload_service.dart';

class AdminScreen extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const AdminScreen({this.cameras, Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  GeoCode geoCode = GeoCode();
  CameraController? _controller;
  XFile? _pictureFile;
  bool _showImage = false;
  Position? currentPosition;
  LatLng? _currentLatLng;
  String? _selectedtypecar;
  late Bill bill;
  StreamSubscription<Position>? positionStream;

  final myBox = Hive.box('myBox');
  late String storedToken;

  String serverMessage = '';
  bool _isLoading = false;
  bool _isFlashOn = false; // Added to manage flash state

  Future<void> clearHiveBox(String boxName) async {
    var box = await Hive.openBox(boxName);
    await box.clear();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.max,
    );
    _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((error) {
      print('Camera initialization error: $error');
    });
  }

  Future<void> _upload() async {
    await _getLocation();
    if (_pictureFile != null &&
        _selectedtypecar != null &&
        _currentLatLng != null) {
      final File file = File(_pictureFile!.path);
      final Map<String, dynamic> response = await UploadService.uploadImage(
          file,
          _selectedtypecar!,
          _currentLatLng.toString());

      if (response['status'] == "OK") {
        serverMessage = response['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serverMessage),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        final Map<String, dynamic> billData = response['data'];
        if (billData['HoursParking'] == 0) {
          billData['HoursParking'] = 0.toDouble();
        }
        bill = Bill.fromJson(billData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BillScreen(bill: bill),
          ),
        );
      } else {
        serverMessage = response['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serverMessage),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (_selectedtypecar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a type of car.'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (_pictureFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select or take a picture.'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //File im = File(pickedFile!.path);
    setState(() {
      //_pictureFile = im;
      _pictureFile = XFile(pickedFile!.path);
      _showImage = true;
    });
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best)
          .timeout(Duration(seconds: 5));
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });

      if (kDebugMode) {
        print('Current location: $_currentLatLng');
      }
    } on PlatformException catch (e) {
      print("Error getting current location: ${e.message}");
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _startLocationUpdates() {
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      distanceFilter: 10, // Update location every 10 meters
    ).listen((Position position) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<void> _toggleFlash() async {
    if (_controller != null && _controller!.value.isInitialized) {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startLocationUpdates(); // Start location updates when the screen is initialized
    if (widget.cameras != null && widget.cameras!.isNotEmpty) {
      _controller = CameraController(
        widget.cameras![0],
        ResolutionPreset.max,
      );
      _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      }).catchError((error) {
        if (kDebugMode) {
          print('Camera initialization error: $error');
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    positionStream?.cancel(); // Cancel the stream when the screen is disposed
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBodyWithMap(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBodyWithMap() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                height: 400,
                width: 400,
                child: _controller != null && _controller!.value.isInitialized
                    ? CameraPreview(_controller!)
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_controller != null &&
                            _controller!.value.isInitialized) {
                          setState(() {
                            _showImage = false;
                          });

                          try {
                            final pictureFile =
                            await _controller!.takePicture();
                            setState(() {
                              _pictureFile = pictureFile;
                              _showImage = true;
                            });
                          } on CameraException catch (e) {
                            print('Error taking picture: $e');
                          }
                        }
                      },
                      child: const Text('Capture Image'),
                    ),
                    ElevatedButton(
                      onPressed: getImageFromGallery,
                      child: const Text('Gallery'),
                    ),
                    ElevatedButton(
                      onPressed: _toggleFlash, // Added flash toggle button
                      child: Text(_isFlashOn ? 'Flash On' : 'Flash Off'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Chọn loại xe'),
                    value: _selectedtypecar,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedtypecar = newValue;
                      });
                    },
                    items: listTypeCar
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          if (_showImage && _pictureFile != null)
            Column(
              children: [
                Image.file(
                  File(_pictureFile!.path),
                  height: 200,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showImage = false;
                      _pictureFile = null;
                    });
                  },
                  child: Text('Clear Image'),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Stack(
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (!_isLoading) {
                    setState(() {
                      _isLoading = true;
                    });
                    await _upload();
                    setState(() {
                      _isLoading = false;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text('Please fill in all fields and choose image!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Upload'),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
