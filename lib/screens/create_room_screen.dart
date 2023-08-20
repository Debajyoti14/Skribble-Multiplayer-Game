import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skribbl_clone/widgets/custom_button.dart';

import '../utils.dart';
import '../widgets/custom_text_field.dart';
import 'paint_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  String? _maxRoundsValue;
  String? _roomSizeValue;
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _roomNameController.dispose();
  }

  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _roomSizeValue != null &&
        _maxRoundsValue != null) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text,
        "occupancy": _roomSizeValue!,
        "maxRounds": _maxRoundsValue!
      };
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PaintScreen(data: data, screenFrom: "createRoom"),
        ),
      );
    } else {
      Utils.toastMessage("Invalid Round or Size");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Create a room',
            style: TextStyle(
              fontFamily: GoogleFonts.pressStart2p(fontWeight: FontWeight.w700)
                  .fontFamily,
              fontSize: 30,
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
          const SizedBox(height: 20),
          DropdownButton<String>(
            focusColor: const Color(0xffF5F6FA),
            items: <String>["2", "5", "10", "15"]
                .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black),
                        )))
                .toList(),
            hint: Text(
              _maxRoundsValue != null
                  ? '$_maxRoundsValue Rounds'
                  : 'Select No. of Rounds',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: (String? value) {
              setState(() {
                _maxRoundsValue = value!;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          DropdownButton<String>(
            focusColor: const Color(0xffF5F6FA),
            items: <String>["2", "3", "4", "5", "6", "7", "8"]
                .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black),
                        )))
                .toList(),
            hint: Text(
              _roomSizeValue == null
                  ? 'Select Room Size'
                  : '$_roomSizeValue People',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: (String? value) {
              setState(() {
                _roomSizeValue = value!;
              });
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2.5,
            child: CustomNeoPopButton(
              labelText: "Create",
              onPress: createRoom,
            ),
          ),
        ],
      ),
    );
  }
}
