import 'package:flutter/material.dart';
import './page/first_page.dart';
import './page/home_page.dart';
import './page/second_page.dart';
import './theme/custom_theme.dart';

import './page/bluetooth_control_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: CustomTheme.lightTheme,
      home: const MyHomePage(title: 'CASA0021 GPP'), // home:   MyHomePage(),
      routes: {
        '/first_page': (BuildContext context) => const FirstPage(),
        '/second_page': (BuildContext context) => const SecondPage(),
        '/bluetooth_control_page': (BuildContext context) => BluetoothControlPage(),

      },

    );
  }
}

