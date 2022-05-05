import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../task/animated_task.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('second Screen'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[

            const Icon(
              Icons.house_rounded,
              color: Color(0xffEDD5B3),
              size: 200.0,
            ),
            Column(
              children: const <Widget>[
                Text(
                  'Temperature: 7',
                  style: TextStyle(height: 2, fontSize: 20),
                ),
                Text(
                  'Humidity: 70 %',
                  style: TextStyle(height: 2, fontSize: 20),
                ),
              ],
            ),
            ToggleSwitch(
              minWidth: 150.0,
              initialLabelIndex: 1,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              labels: const ['Schedule', 'Smart'],
              icons: [Icons.alarm, Icons.lightbulb_outline],
              activeBgColors: const [
                [Color(0xffEDD5B3)],
                [Color(0xffEDD5B3)]
              ],
              onToggle: (index) {
                print('switched to: $index');
              },
            ),
            const SizedBox(
              width: 150,
              child: AnimatedTask(),
            ),

            ElevatedButton(
              child: const Text('Launch new screen'),
              onPressed: () {
                // Navigate to second screen when tapped!
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: const Color(0xffEDD5B3),
        activeColor: const Color(0xfffff5E0),
        color: const Color(0xffC9A87C),
        items: const [
          TabItem(icon: Icons.home_filled),
          TabItem(icon: Icons.workspaces),
          TabItem(icon: Icons.person),
        ],
        initialActiveIndex: 2,
        // onTap: (int i) => print('click index=$i'),
        onTap: (int i) {
          print('click index=$i');
          switch (i) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              Navigator.pop(context);
              break;
            case 2:
              break;

            default:
              break;
          }
        },
      ),
    );
  }
}
