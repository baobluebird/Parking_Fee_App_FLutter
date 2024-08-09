import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final Future<void> Function() uploadFunction;

  const LoadingScreen({required this.uploadFunction, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Call the upload function when this screen is built
    _startUpload(context);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _startUpload(BuildContext context) async {
    try {
      await uploadFunction();
    } catch (e) {
      // Handle any errors here
      print('Upload error: $e');
    }
  }
}
