import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerScoreDrawer extends StatelessWidget {
  final List<Map> userData;
  const PlayerScoreDrawer({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Drawer(
      child: Center(
          child: SizedBox(
        height: double.maxFinite,
        child: Column(
          children: [
            SizedBox(height: size.height * 0.1),
            Text(
              'Scoreboard',
              style: TextStyle(
                fontFamily:
                    GoogleFonts.pressStart2p(fontWeight: FontWeight.w700)
                        .fontFamily,
                fontSize: 14,
              ),
            ),
            ListView.builder(
                itemCount: userData.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var data = userData[index].values;
                  return ListTile(
                    title: Text(data.elementAt(0),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 23)),
                    trailing: Text(data.elementAt(1),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  );
                }),
          ],
        ),
      )),
    );
  }
}
