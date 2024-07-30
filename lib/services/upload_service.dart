import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../ipconfig/ip.dart';

class UploadService {
  static Future<Map<String, dynamic>> uploadImage(File image,
      String typeCar, String location, bool payment) async {
    try {
      print('anh 1: $image');
      DateTime now = DateTime.now();
      String currentDateAndTime = now.toString();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$ip/fee/upload'),
      );

      var imageFile = await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: image.path.split('/').last,
      );
      request.files.add(imageFile);

      //request.files.add(await http.MultipartFile.fromPath('imageUp', imageUp!.path));
      request.fields['typeCar'] = typeCar;
      request.fields['location'] = location;
      //request.fields['address'] = address;
      request.fields['currentDateAndTime'] = currentDateAndTime;
      request.fields['payment'] = payment.toString();

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        var response = await streamedResponse.stream.bytesToString();
        var decodedResponse = json.decode(response);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message')) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          return {
            'status': decodedResponse['status'],
            'message': decodedResponse['message']
          };;
        }
      } else {
        var response = await streamedResponse.stream.bytesToString();
        var decodedResponse = json.decode(response);
        return {'status': decodedResponse['status'], 'message': decodedResponse['message']};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}
