import 'package:flutter/material.dart';
import 'package:skrible/models/my_custom_paints.dart';
import 'package:skrible/models/touch_points.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  const PaintScreen({Key? key, required this.data, required this.screenFrom})
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
        if (mounted) {
          setState(() {
            dataOfRoom = roomData;
          });
        }
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
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
                    _socket.emit('paint',
                        {'details': null, 'roomName': widget.data['name']});
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
              )
            ],
          )
        ],
      ),
    );
  }
}
