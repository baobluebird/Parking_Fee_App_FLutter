import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_fee/screens/reset_password.dart';

import '../services/login_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String? email;
  final String? id;
  OTPVerificationScreen({Key? key, required this.email, required this.id});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  String serverMessage = '';
  bool check = false;
  String? userId;
  String? codeDigit1; // Separate variables for each digit
  String? codeDigit2;
  String? codeDigit3;
  String? codeDigit4;
  String? codeDigit5;
  bool _isResendEnabled = true;
  int _resendTimeout = 30; // 30 seconds timeout
  Timer? _timer;

  Future<void> _resendEmail() async {
    setState(() {
      _isResendEnabled = false;
      _resendTimeout = 30; // reset timer
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _resendTimeout--;
      });

      if (_resendTimeout == 0) {
        _timer?.cancel();
        setState(() {
          _isResendEnabled = true;
        });
      }
    });

    try {
      final Map<String, dynamic> response =
      await ResendCodeService.resendCode(widget.email!); // Accessing email from widget
      if (response['status'] == 'OK') {
        setState(() {
          serverMessage = response['message'];
        });
      } else {
        setState(() {
          serverMessage = response['message'];
        });
        print('Error occurred: ${response['message']}');
      }
    } catch (e) {
      setState(() {
        serverMessage = 'Error: $e';
      });
      print('Error occurred: $e');
    }
  }

  Future<void> _verifyCode() async {
    String completeCode = "$codeDigit1$codeDigit2$codeDigit3$codeDigit4$codeDigit5";
    try {
      final Map<String, dynamic> response = await VerifyCodeService.verifyCode(widget.id!, completeCode);
      if (response['status'] == 'OK') {
        setState(() {
          userId = response['userId'];
          check = true;
          serverMessage = response['message'];
        });
      } else {
        setState(() {
          check = false;
          serverMessage = response['message'];
        });
      }
    } catch (e) {
      setState(() {
        check = false;
        serverMessage = 'Error: $e';
      });
      print('Error occurred: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: TextButton(
            onPressed: _isResendEnabled ? () async {
              await _resendEmail();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(serverMessage),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.green,
                ),
              );
            } : null,
            child: Text(
              _isResendEnabled ? 'Resend OTP' : 'Resend in $_resendTimeout s',
              style: TextStyle(
                color: _isResendEnabled ? Colors.blue : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        appBar: AppBar(),
        body:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const Text(
                      'OTP Verification',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter the verification code we just sent on your email address',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              onChanged: (value) {
                                codeDigit1 = value;
                                if(value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: const InputDecoration(hintText: '0'),
                              style: Theme.of(context).textTheme.titleLarge,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              onChanged: (value) {
                                codeDigit2 = value;
                                if(value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: const InputDecoration(hintText: '0'),
                              style: Theme.of(context).textTheme.titleLarge,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              onChanged: (value) {
                                codeDigit3 = value;
                                if(value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: const InputDecoration(hintText: '0'),
                              style: Theme.of(context).textTheme.titleLarge,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              onChanged: (value) {
                                codeDigit4 = value;
                                if(value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: const InputDecoration(hintText: '0'),
                              style: Theme.of(context).textTheme.titleLarge,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              onChanged: (value) {
                                codeDigit5 = value;
                                if(value.length == 1){
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: const InputDecoration(hintText: '0'),
                              style: Theme.of(context).textTheme.titleLarge,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.blueAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _verifyCode();
                            if(check){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(serverMessage),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              print(userId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ResetPasswordScreen(userId: userId)
                                ),
                              );
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$serverMessage, please check code from Email or resend OTP'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Verify Code',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'Open Sans',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
        )

    );
  }
}
