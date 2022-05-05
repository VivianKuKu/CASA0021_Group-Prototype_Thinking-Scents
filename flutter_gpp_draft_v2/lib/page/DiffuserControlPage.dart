import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';
// import 'package:fluent_ui/fluent_ui.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  // =============
  bool _switch1Toggle = false;
  bool _switch2Toggle = false;
  bool _switch3Toggle = false;

  String enableSwitch1 = '#s1e';
  String enableSwitch2 = '#s2e';
  String enableSwitch3 = '#s3e';
  String disableSwitch1 = '#s1d';
  String disableSwitch2 = '#s2d';
  String disableSwitch3 = '#s3d';

  _Message msgTin = _Message(0, '0.000');
  _Message msgHin = _Message(0, '0.000');
  bool msgTinFlag = false;
  bool msgHinFlag = false;
  bool identifierLoop = false;

  double valSwitch1 = 100.0;
  double valSwitch2 = 100.0;
  double valSwitch3 = 100.0;

  String changeValueSwitch1 = '#s1v';
  String changeValueSwitch2 = '#s2v';
  String changeValueSwitch3 = '#s3v';

  String setAutoMode = '%A';
  String setManualMode = '%M';
  String setShareMode = '%S';

  // bool isMixPwmOn = false;
  ValueNotifier<bool> isMixPwmOn = ValueNotifier<bool>(false);
  int toggleLabel = 0;
  int modeLabel = 0;

  bool isAutoOn = false;
  bool isShareOn = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Icon(
                Icons.house_rounded,
                color: Color(0xffEDD5B3),
                size: 100.0,
              ),
            ),
            ToggleSwitch(
              minWidth: 90.0,
              initialLabelIndex: modeLabel,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 3,
              labels: const ['Auto', 'Manual', 'Share'],
              icons: const [
                Icons.brightness_auto_outlined,
                Icons.handyman_outlined,
                Icons.connect_without_contact_outlined
              ],
              activeBgColors: const [
                [Color(0xaaF5E0C3)],
                [Color(0xff6D42CE)],
                [Color(0xffEDD5B3)]
              ],
              onToggle: (index) {
                if (index == 0) {
                  modeLabel = 0;
                  _sendMessage(setAutoMode);
                } else if (index == 1) {
                  modeLabel = 1;
                  _sendMessage(setManualMode);
                } else if (index == 2) {
                  modeLabel = 2;
                  _sendMessage(setShareMode);
                }
                print('switched to: $index');
              },
            ),
            Container(
              alignment: Alignment.center,
              height: 70,
              width: 220,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        "Temperature: ",
                        style: TextStyle(
                            color: Color(0xff936F3E),
                            fontSize: 23,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        (text, whom) {
                          return whom == 0 ? '' : text;
                        }(msgTin.text.trim(), msgTin.whom),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Text(
                        "Humidity: ",
                        style: TextStyle(
                            color: Color(0xff936F3E),
                            fontSize: 23,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        (text, whom) {
                          return whom == 0 ? '' : text;
                        }(msgHin.text.trim(), msgHin.whom),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ToggleSwitch(
              minWidth: 150.0,
              initialLabelIndex: toggleLabel,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              labels: const ['Standard', 'Percentage'],
              icons: [Icons.alarm, Icons.lightbulb_outline],
              activeBgColors: const [
                [Color(0xffEDD5B3)],
                [Color(0xffEDD5B3)]
              ],
              onToggle: (index) {
                if (index == 0) {
                  isMixPwmOn.value = false;
                  toggleLabel = 0;
                  _sendMessage(changeValueSwitch1 + '100.0');
                  _sendMessage(changeValueSwitch2 + '100.0');
                  _sendMessage(changeValueSwitch3 + '100.0');
                } else if (index == 1) {
                  isMixPwmOn.value = true;
                  toggleLabel = 1;
                  _sendMessage(changeValueSwitch1 + valSwitch1.toString());
                  _sendMessage(changeValueSwitch2 + valSwitch2.toString());
                  _sendMessage(changeValueSwitch3 + valSwitch3.toString());
                }
                print('switched to: $index');
              },
            ),
            Container(
              alignment: Alignment.center,
              height: 400,
              width: 280,
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('Switch 1'),
                    value: _switch1Toggle,
                    activeColor: const Color(0xffEDD5B3),
                    onChanged: (bool value) {
                      // Do the request and update with the true value then
                      // future() async {
                      // async lambda seems to not working

                      setState(() {
                        _switch1Toggle = value;
                      });

                      if (value) {
                        _sendMessage(enableSwitch1);
                      } else {
                        _sendMessage(disableSwitch1);
                      }
                    },
                    secondary: const Icon(Icons.lightbulb_outline),
                  ),
                  ValueListenableBuilder(
                      valueListenable: isMixPwmOn,
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        return SfSliderTheme(
                          data: SfSliderThemeData(
                            activeTickColor: const Color(0xffEDD5B3),
                            inactiveTickColor: Colors.grey[600],
                            activeMinorTickColor: const Color(0xffEDD5B3),
                            inactiveMinorTickColor: Colors.grey[600],
                            tickSize: Size(2.0, 8.0),
                            minorTickSize: Size(2.0, 6.0),
                            tooltipBackgroundColor: const Color(0xffEDD5B3),
                            tooltipTextStyle: const TextStyle(
                                color: Color(0xffB28E5E),
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                            activeLabelStyle: const TextStyle(
                                color: const Color(0xffEDD5B3),
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                            inactiveLabelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                          ),
                          child: SfSlider(
                            min: 0.0,
                            max: 100.0,
                            interval: 20.0,
                            minorTicksPerInterval: 1,
                            stepSize: 10.0,
                            showTicks: true,
                            showLabels: true,
                            enableTooltip: true,
                            tooltipShape: const SfPaddleTooltipShape(),
                            value: valSwitch1,
                            onChanged: value
                                ? (dynamic newValue) {
                                    setState(() {
                                      valSwitch1 = newValue;
                                    });
                                  }
                                : null,
                            onChangeEnd: (dynamic endValue) {
                              print('Interaction ended');
                              _sendMessage(
                                  changeValueSwitch1 + (endValue).toString());
                            },
                          ),
                        );
                      }),
                  const Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
                  SwitchListTile(
                    title: const Text('Switch 2'),
                    value: _switch2Toggle,
                    activeColor: const Color(0xffEDD5B3),
                    onChanged: (bool value) {
                      setState(() {
                        _switch2Toggle = value;
                      });

                      if (value) {
                        _sendMessage(enableSwitch2);
                      } else {
                        _sendMessage(disableSwitch2);
                      }
                    },
                    secondary: const Icon(Icons.lightbulb_outline),
                  ),
                  ValueListenableBuilder(
                      valueListenable: isMixPwmOn,
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        return SfSliderTheme(
                          data: SfSliderThemeData(
                            activeTickColor: const Color(0xffEDD5B3),
                            inactiveTickColor: Colors.grey[600],
                            activeMinorTickColor: const Color(0xffEDD5B3),
                            inactiveMinorTickColor: Colors.grey[600],
                            tickSize: Size(2.0, 8.0),
                            minorTickSize: Size(2.0, 6.0),
                            tooltipBackgroundColor: const Color(0xffEDD5B3),
                            tooltipTextStyle: const TextStyle(
                                color: Color(0xffB28E5E),
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                            activeLabelStyle: const TextStyle(
                                color: const Color(0xffEDD5B3),
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                            inactiveLabelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                          ),
                          child: SfSlider(
                            min: 0.0,
                            max: 100.0,
                            interval: 20.0,
                            minorTicksPerInterval: 1,
                            stepSize: 10.0,
                            showTicks: true,
                            showLabels: true,
                            enableTooltip: true,
                            tooltipShape: const SfPaddleTooltipShape(),
                            value: valSwitch2,
                            onChanged: value
                                ? (dynamic newValue) {
                                    setState(() {
                                      valSwitch2 = newValue;
                                    });
                                  }
                                : null,
                            onChangeEnd: (dynamic endValue) {
                              print('Interaction ended');
                              _sendMessage(
                                  changeValueSwitch2 + endValue.toString());
                            },
                          ),
                        );
                      }),
                  const Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
                  SwitchListTile(
                    title: const Text('Switch 3'),
                    value: _switch3Toggle,
                    activeColor: const Color(0xffEDD5B3),
                    onChanged: (bool value) {
                      setState(() {
                        _switch3Toggle = value;
                      });

                      if (value) {
                        _sendMessage(enableSwitch3);
                      } else {
                        _sendMessage(disableSwitch3);
                      }
                    },
                    secondary: const Icon(Icons.lightbulb_outline),
                  ),
                  ValueListenableBuilder(
                      valueListenable: isMixPwmOn,
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        return SfSliderTheme(
                          data: SfSliderThemeData(
                            activeTickColor: const Color(0xffEDD5B3),
                            inactiveTickColor: Colors.grey[600],
                            activeMinorTickColor: const Color(0xffEDD5B3),
                            inactiveMinorTickColor: Colors.grey[600],
                            tickSize: Size(2.0, 8.0),
                            minorTickSize: Size(2.0, 6.0),
                            tooltipBackgroundColor: const Color(0xffEDD5B3),
                            tooltipTextStyle: const TextStyle(
                                color: Color(0xffB28E5E),
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                            activeLabelStyle: const TextStyle(
                                color: const Color(0xffEDD5B3),
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                            inactiveLabelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                          ),
                          child: SfSlider(
                            min: 0.0,
                            max: 100.0,
                            interval: 20.0,
                            minorTicksPerInterval: 1,
                            stepSize: 10.0,
                            showTicks: true,
                            showLabels: true,
                            enableTooltip: true,
                            tooltipShape: const SfPaddleTooltipShape(),
                            value: valSwitch3,
                            onChanged: value
                                ? (dynamic newValue) {
                                    setState(() {
                                      valSwitch3 = newValue;
                                    });
                                  }
                                : null,
                            onChangeEnd: (dynamic endValue) {
                              print('Interaction ended');
                              _sendMessage(
                                  changeValueSwitch3 + endValue.toString());
                            },
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;

    debugPrint('value: $data');

    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);

    // debugPrint('value: ${buffer}');

    int bufferIndex = buffer.length;
    debugPrint('value: ${bufferIndex}');
    // Apply backspace control character
    backspacesCounter = 0;
    debugPrint('ready to loop');
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
          // debugPrint('value: ${data} ------- [$i]');
        }
      }

      // debugPrint('backspacesCounter [$backspacesCounter]');
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);

    debugPrint('dataString: ${dataString}');

    if (dataString == 't') {
      msgTinFlag = true;
      identifierLoop = true;
    }

    if (dataString == 'h') {
      msgHinFlag = true;
      identifierLoop = true;
    }

    debugPrint('_messageBuffer-----$_messageBuffer');
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        if (!identifierLoop) {
          if (msgTinFlag) {
            msgTin = _Message(
              1,
              backspacesCounter > 0
                  ? _messageBuffer.substring(
                      0, _messageBuffer.length - backspacesCounter)
                  : dataString.substring(0, index),
              // : _messageBuffer + dataString.substring(0, index),
            );
            _messageBuffer = dataString.substring(index);

            msgTinFlag = false;
          } else if (msgHinFlag) {
            msgHin = _Message(
              1,
              backspacesCounter > 0
                  ? _messageBuffer.substring(
                      0, _messageBuffer.length - backspacesCounter)
                  : dataString.substring(0, index),
              // : _messageBuffer + dataString.substring(0, index),
            );
            _messageBuffer = dataString.substring(index);
            msgHinFlag = false;
          }

          identifierLoop = true;
        }
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);

      // debugPrint('value: ${_messageBuffer} ------- [$index]---in else');
    }

    identifierLoop = false;
    // inspect(msgTin);
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        // connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
