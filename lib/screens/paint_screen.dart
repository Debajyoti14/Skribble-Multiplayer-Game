import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  const PaintScreen({Key? key, required this.screenFrom, required this.data})
      : super(key: key);

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  String dataOfRoom = "";

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("paint Screen"),
      ),
    );
  }
}
