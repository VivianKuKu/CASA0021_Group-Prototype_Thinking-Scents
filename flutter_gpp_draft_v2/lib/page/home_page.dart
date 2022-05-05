import 'package:flutter/material.dart';


import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

// import './BackgroundCollectedPage.dart';
// import './BackgroundCollectingTask.dart';
import './DiffuserControlPage.dart';
// import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';


import '../page/bluetooth_control_page.dart';
import '../task/animated_task.dart';
import '../task/task_complete_ring.dart';
import 'first_page.dart';
import 'second_page.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey,
      // body: Center(
      //
      //
      //
      //   child: SizedBox(
      //     width: 150,
      //     child: AnimatedTask(),
      //   ),
      //
      // ),

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // SizedBox(
            //   width: 150,
            //   child: pressed
            //   // ? const AnimatedTask()
            //       ?  Text('world')
            //       :  Text('Helloooo'),
            // ),
            // ElevatedButton(
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            //           (Set<MaterialState> states) {
            //         if (states.contains(MaterialState.pressed)) {
            //           return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            //         }
            //         return null; // Use the component's default.
            //       },
            //     ),
            //   ),
            //   onPressed: () {
            //
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(builder: (context) => const FirstPage()),
            //     // );
            //
            //     Navigator.pushNamed(context, '/bluetooth_control_page');
            //
            //   },
            //   child: const Text('Bluetooth Control'),
            // ),

            ElevatedButton(
              child: const Text('Bluetooth Control'),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(checkAvailability: false);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  print('Connect -> selected ' + selectedDevice.address);
                  _startChat(context, selectedDevice);
                } else {
                  print('Connect -> no device selected');
                }
              },
            ),

            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              onPressed: () {

                Navigator.pushNamed(context, '/bluetooth_control_page');
              },
              child: const Text('Settings'),
            ),

            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              onPressed: () {},
              child: const Text('About'),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }

}




// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key}) : super(key: key);
//   bool pressed = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueGrey,
//       // body: Center(
//       //
//       //
//       //
//       //   child: SizedBox(
//       //     width: 150,
//       //     child: AnimatedTask(),
//       //   ),
//       //
//       // ),
//
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//              SizedBox(
//               width: 150,
//               child: pressed
//                   ? const AnimatedTask()
//                   : const Text('Hello'),
//             ),
//             ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                       (Set<MaterialState> states) {
//                     if (states.contains(MaterialState.pressed)) {
//                       return Theme.of(context).colorScheme.primary.withOpacity(0.5);
//                     }
//                     return null; // Use the component's default.
//                   },
//                 ),
//               ),
//               onPressed: () {
//
//                   pressed = !pressed;
//                   print('value: ${pressed}');
//
//               },
//               child: const Text('START'),
//             ),
//
//             ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                       (Set<MaterialState> states) {
//                     if (states.contains(MaterialState.pressed)) {
//                       return Theme.of(context).colorScheme.primary.withOpacity(0.5);
//                     }
//                     return null; // Use the component's default.
//                   },
//                 ),
//               ),
//               onPressed: () {},
//               child: const Text('Settings'),
//             ),
//
//             ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                       (Set<MaterialState> states) {
//                     if (states.contains(MaterialState.pressed)) {
//                       return Theme.of(context).colorScheme.primary.withOpacity(0.5);
//                     }
//                     return null; // Use the component's default.
//                   },
//                 ),
//               ),
//               onPressed: () {},
//               child: const Text('About'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }





// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//
//             ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                       (Set<MaterialState> states) {
//                     if (states.contains(MaterialState.pressed)) {
//                       return Theme.of(context).colorScheme.primary.withOpacity(0.5);
//                     }
//                     return null; // Use the component's default.
//                   },
//                 ),
//               ),
//               onPressed: () {},
//               child: const Text('START'),
//             ),
//
//             ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                       (Set<MaterialState> states) {
//                     if (states.contains(MaterialState.pressed)) {
//                       return Theme.of(context).colorScheme.primary.withOpacity(0.5);
//                     }
//                     return null; // Use the component's default.
//                   },
//                 ),
//               ),
//               onPressed: () {},
//               child: const Text('Settings'),
//             ),
//
//             ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                       (Set<MaterialState> states) {
//                     if (states.contains(MaterialState.pressed)) {
//                       return Theme.of(context).colorScheme.primary.withOpacity(0.5);
//                     }
//                     return null; // Use the component's default.
//                   },
//                 ),
//               ),
//               onPressed: () {},
//               child: const Text('About'),
//             ),
//
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
//
