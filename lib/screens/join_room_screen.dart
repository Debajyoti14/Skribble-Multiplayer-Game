import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';
import 'paint_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => JoinRoomScreenState();
}

class JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _roomNameController.dispose();
  }

  void joinRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text
      };

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaintScreen(data: data, screenFrom: 'joinRoom'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Join Room!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: _nameController,
              hintText: "Enter your name",
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: _roomNameController,
              hintText: "Enter your room name",
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: joinRoom,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              textStyle: MaterialStateProperty.all(
                const TextStyle(
                  color: Colors.white,
                ),
              ),
              minimumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 2.5, 50),
              ),
            ),
            child: const Text(
              "Join",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
