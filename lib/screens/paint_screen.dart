import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  const PaintScreen({Key? key}) : super(key: key);

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    connect();
  }

  //Socket io Connection
  void connect() {
    _socket = IO.io('http://192.168.0.106:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    //Listen to Socket
    _socket.onConnect((data) {
      print("connected");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("paint Screen"),
    );
  }
}
