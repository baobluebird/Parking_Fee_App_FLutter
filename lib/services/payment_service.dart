import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ipconfig/ip.dart';

class createPaymentService {
  static Future<Map<String, dynamic>> createPayment( int amount) async {
    try {
      var response = await http.post(
        Uri.parse('$ip/payment/create-payment'),
        body: jsonEncode({'amount': amount}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('status') &&
            decodedResponse.containsKey('paymentId') &&
            decodedResponse.containsKey('approval_url') &&
            decodedResponse.containsKey('message')) {
          return {
            'status': decodedResponse['status'],
            'paymentId': decodedResponse['paymentId'],
            'approval_url': decodedResponse['approval_url'],
            'message': decodedResponse['message']
          };
        } else {
          return {
            'status': decodedResponse['status'],
            'message': decodedResponse['message']
          };
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

class isPaymentService {
  static Future<Map<String, dynamic>> isPayment(String billId, String userId, String payId, double hour, int amount, String method) async {
    try {
      var response = await http.post(
        Uri.parse('$ip/payment/is-payment/$billId'),
        body: jsonEncode({'userId': userId, 'amount': amount, 'payId': payId, 'hour': hour, 'method': method}),
        headers: {'Content-Type': 'application/json'},
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

class getListPaymentUserService {
  static Future<Map<String, dynamic>> getListPaymentUser(String userId) async {
    try {
      var response = await http.get(
        Uri.parse('$ip/payment/get-list-payment-by-user/$userId'),
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

class getDetailPaymentService {
  static Future<Map<String, dynamic>> getDetailPayment(String billId) async {
    try {
      var response = await http.get(
        Uri.parse('$ip/payment/get-detail-payment/$billId'),
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

class getDetailPaymentUserService {
  static Future<Map<String, dynamic>> getDetailPaymentUser(String paymentId) async {
    try {
      var response = await http.get(
        Uri.parse('$ip/payment/get-detail-payment-by-user/$paymentId'),
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

class getListCarIsPaymentService {
  static Future<Map<String, dynamic>> getListCarIsPayment() async {
    try {
      var response = await http.get(
        Uri.parse('$ip/payment/get-list-car-is-payment'),
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

class getListCarIsPaymentByUserService {
  static Future<Map<String, dynamic>> getListCarIsPaymentByUser(String userId) async {
    try {
      var response = await http.get(
        Uri.parse('$ip/payment/get-list-car-is-payment-by-user/$userId'),
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