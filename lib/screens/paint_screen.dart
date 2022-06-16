import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/my_custom_paints.dart';
import '../models/touch_points.dart';

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  PaintScreen({Key? key, required this.data, required this.screenFrom})
      : super(key: key);

  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;

  @override
  void initState() {
    super.initState();
    connect();
    print(widget.data);
  }

  //Socket io Connection
  void connect() {
    _socket = IO.io('http://192.168.0.106:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    //Listen to Socket
    _socket.onConnect((data) {
      print("connected");
      _socket.on('updateRoom', (roomData) {
        setState(() {
          dataOfRoom = roomData;
        });

        if (roomData['isJoin'] != true) {
          //Start the Timer
        }
      });

      _socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                points: Offset((point['details']['dx']).toDouble(),
                    (point['details']['dy']).toDouble()),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        }
      });

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color otherColor = new Color(value);
        setState(() {
          selectedColor = otherColor;
        });
      });

      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      _socket.on('clean-screen', (data) {
        setState(() {
          points.clear();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Choose Color'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        String colorString = color.toString();
                        String valueString =
                            colorString.split('(0x')[1].split(')')[0];
                        print(colorString);
                        print(valueString);
                        Map map = {
                          'color': valueString,
                          'roomName': dataOfRoom['name'],
                        };
                        _socket.emit('color-change', map);
                      }),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('close'),
                  )
                ],
              ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                height: height * 0.55,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    print(details.localPosition.dx);
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name']
                    });
                  },
                  onPanStart: (details) {
                    print(details.localPosition.dx);
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name']
                    });
                  },
                  onPanEnd: (details) {
                    _socket.emit('paint', {
                      'details': null,
                      'roomName': widget.data['name'],
                    });
                  },
                  child: SizedBox.expand(
                      child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: MyCustomPainter(pointsList: points),
                      ),
                    ),
                  )),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.color_lens, color: selectedColor),
                    onPressed: selectColor,
                  ),
                  Expanded(
                    child: Slider(
                        min: 1.0,
                        max: 10,
                        label: "StrokeWidth $strokeWidth",
                        value: strokeWidth,
                        onChanged: (double value) {
                          Map map = {
                            'value': value,
                            'roomName': dataOfRoom['name'],
                          };
                          _socket.emit('stroke-width', map);
                        }),
                  ),
                  IconButton(
                    icon: Icon(Icons.layers_clear, color: selectedColor),
                    onPressed: () {
                      _socket.emit('clean-screen', dataOfRoom['name']);
                    },
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
