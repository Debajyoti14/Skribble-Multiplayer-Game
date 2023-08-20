import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skribbl_clone/screens/join_room_screen.dart';

import '../widgets/custom_button.dart';
import 'create_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Skribble',
          style: TextStyle(
            fontFamily: GoogleFonts.pressStart2p(fontWeight: FontWeight.w700)
                .fontFamily,
            fontSize: 46,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Create / join a room to play!',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomNeoPopButton(
              labelText: 'Create Room',
              onPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const CreateRoomScreen()),
                );
              },
            ),
            CustomNeoPopButton(
              labelText: 'Join Room',
              onPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const JoinRoomScreen()),
                );
              },
            ),
          ],
        )
      ],
    ));
  }
}
