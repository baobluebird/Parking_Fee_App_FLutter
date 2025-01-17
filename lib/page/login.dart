import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../screens/sign_in.dart';
import 'package:colorful_background/colorful_background.dart';

import '../screens/sign_up.dart';
import '../services/login_service.dart';
import 'home_admin.dart';
import 'home_user.dart';

class Login extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const Login({Key? key, this.cameras}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  int backButtonPressCounter = 0;
  DateTime? currentBackPressTime;

  final myBox = Hive.box('myBox');
  late String storedToken;
  String serverMessage = '';
  bool _isInitComplete = false;

  Future<void> clearHiveBox(String boxName) async {
    var box = await Hive.openBox(boxName);
    await box.clear();
  }

  Future<void> _decodeToken(String token) async {
    try {
      final Map<String, dynamic> response =
          await DecodeTokenService.decodeToken(token);
      print('Response status: ${response['status']}');
      print('Response body: ${response['message']}');
      if (response['status'] == "OK") {
        setState(() {
          serverMessage = response['message'];
        });
        print('Login successful');
        if (response['isAdmin'] == true) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AdminHome()));
          print(serverMessage);
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => UserHome()));
          print(serverMessage);
        }
      } else {
        setState(() {
          serverMessage = response['message'];
        });
        print('Login failed: ${response['message']}');
        print(serverMessage);
      }
    } catch (error) {
      setState(() {
        serverMessage = 'Error: $error';
      });
      print('Error: $error');
      print(serverMessage);
    }
  }

  Future<void> _initData() async {
    print("Amount of data is ${myBox.length}");
    storedToken = myBox.get('token', defaultValue: '');
    print('Stored Token: $storedToken');
    if (storedToken != '') {
      await _decodeToken(storedToken);
    }
    setState(() {
      _isInitComplete = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitComplete
        ? ColorfulBackground(
            duration: const Duration(milliseconds: 1000),
            decoratorsList: [
              Positioned(
                top: MediaQuery.of(context).size.height / 2.5,
                left: MediaQuery.of(context).size.width / 2.5,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: 20,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 200,
                left: 90,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
            backgroundColors: const [
              Color(0xFFFFFFFF),
              Color(0xFFEBEBEB),
              Color(0xFFD7D7D7),
              Color(0xFFC3C3C3),
              Color(0xFFAFAFAF),
            ],
            child: WillPopScope(
              onWillPop: () async {
                if (backButtonPressCounter < 1) {
                  setState(() {
                    backButtonPressCounter++;
                    currentBackPressTime = DateTime.now();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Press back again to exit."),
                    ),
                  );
                  return false;
                } else {
                  if (currentBackPressTime == null ||
                      DateTime.now().difference(currentBackPressTime!) >
                          const Duration(seconds: 2)) {
                    setState(() {
                      backButtonPressCounter = 0;
                    });
                    return false;
                  }
                  return true;
                }
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    Center(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(25),
                        children: <Widget>[
                          Image.asset('assets/images/logo_app.png',
                              width: 200, height: 200),
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              "assets/images/car.png",
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'All parking spots in one place',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  'NotoSans-Italic-VariableFont_wdth,wght.ttf',
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SigninScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10),
                                ),
                                backgroundColor: Colors
                                    .blue,
                              ),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily:
                                      'NotoSans-Italic-VariableFont_wdth,wght.ttf',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Don\'t have an account?',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignupScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        'NotoSans-Italic-VariableFont_wdth,wght.ttf',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
  }
}
