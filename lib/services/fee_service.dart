import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ipconfig/ip.dart';

class getListCarDuringParkingService {
  static Future<Map<String, dynamic>> getListCarDuringParking() async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/list-car-during-parking'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
            print('data null');
          return {'status': 'OK', 'data': 'null'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class getListCarDuringParkingByUserService {
  static Future<Map<String, dynamic>> getListCarDuringParkingByUser(String userId) async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/list-car-during-parking-by-user/$userId'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          print('data null');
          return {'status': 'OK', 'data': 'null'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class getListLocationCarDuringParkingService {
  static Future<Map<String, dynamic>> getListLocationCarDuringParking() async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/get-all-location-during-parking'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          print('data null');
          return {'status': 'OK', 'data': 'null'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class getListLocationCarParkingOverTimeService {
  static Future<Map<String, dynamic>> getListLocationCarParkingOverTime() async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/get-all-location-parking-time-over'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          print('data null');
          return {'status': 'OK', 'data': 'null'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class getListCarParkingOverTimeService {
  static Future<Map<String, dynamic>> getListCarParkingOverTime() async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/list-car-parking-time-over'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          print('data null');
          return {'status': 'OK', 'data': 'null'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class getListCarParkingOverTimeByUserService {
  static Future<Map<String, dynamic>> getListCarParkingOverTimeByUser(String userId) async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/list-car-parking-time-over-by-user/$userId'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          print('data null');
          return {'status': 'OK', 'data': 'null'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}


class getDetailBillService {
  static Future<Map<String, dynamic>> getDetailBill(String id) async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/get-detail-bill/$id'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          return {'status': 'error', 'message': 'Unexpected response format'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class getFeeIdService {
  static Future<Map<String, dynamic>> getFeeId(String id) async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/get-fee-id/$id'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          return {'status': 'error', 'message': 'Unexpected response format'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class getAllBillOfUserService {
  static Future<Map<String, dynamic>> getAllBillOfUser(String id)async {
    try {
      var response = await http.get(
        Uri.parse('$ip/fee/get-all-bill-with-fee-id/$id'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('data') &&
            decodedResponse.containsKey('message') ) {
          return {
            'status': decodedResponse['status'],
            'data': decodedResponse['data'],
            'message': decodedResponse['message']
          };
        } else {
          return {'status': 'error', 'message': 'Unexpected response format'};
        }
      } else {
        return {'status': 'error', 'message': 'Non-200 status code'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}