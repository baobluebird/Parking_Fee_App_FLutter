import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:parking_fee/page/login.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await openHiveBox('mybox');
  runApp(const MyApp());
}

Future<void> openHiveBox(String boxName) async {
  if (!kIsWeb && !Hive.isBoxOpen(boxName))
    Hive.init((await getApplicationDocumentsDirectory()).path);
  await Hive.openBox(boxName);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Parking Fees Admin',
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}