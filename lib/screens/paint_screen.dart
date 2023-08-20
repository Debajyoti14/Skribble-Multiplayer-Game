import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_clone/screens/waiting_lobby_screen.dart';
import 'package:skribbl_clone/sidebar/player_scoreboard_drawer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/my_custom_paints.dart';
import '../models/touch_points.dart';
import 'final_leaderboard.dart';
import 'home_screen.dart';

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
  List<Widget> textBlankWidget = [];
  final ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  List<Map> messages = [];
  int guessedUserCtr = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderboard = false;

  @override
  void initState() {
    super.initState();
    connect();
    print(widget.data);
  }

  void startTimer() {
    if (dataOfRoom.isNotEmpty) {
      const oneSec = Duration(seconds: 1);
      _timer = Timer.periodic(oneSec, (Timer time) {
        if (_start == 0) {
          _socket.emit('change-turn', dataOfRoom['name']);
          setState(() {
            _timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      });
    }
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(
        const Text('_', style: TextStyle(fontSize: 30)),
      );
    }
  }

  //Socket io Connection
  void connect() {
    print("calling socket connect");
    _socket = IO.io('http://192.168.0.102:3000', <String, dynamic>{
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
        print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
          print('----------------------');
          print(dataOfRoom);
          print('----------------------');
        });

        if (roomData['isJoin'] != true) {
          //Start the Timer
          startTimer();
        }
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString(),
            });
          });
        }
      });

      _socket.on(
          'notCorrectGame',
          (data) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false));

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
      _socket.on('msg', (msgData) {
        setState(() {
          messages.add(msgData);
          guessedUserCtr = msgData['guessedUserCtr'];
        });
        if (guessedUserCtr == dataOfRoom['players'].length - 1) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 40,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });

      _socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  dataOfRoom = data;
                  renderTextBlank(data['word']);
                  isTextInputReadOnly = false;
                  guessedUserCtr = 0;
                  _start = 60;
                  points.clear();
                });
                Navigator.of(context).pop();
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                  title: Center(child: Text('Word was $oldWord')));
            });
      });

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        setState(() {
          selectedColor = otherColor;
        });
      });

      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      _socket.on('clear-screen', (data) {
        setState(() {
          points.clear();
        });
      });

      _socket.on('closeInput', (_) {
        _socket.emit('updateScore', widget.data['name']);
        setState(() {
          isTextInputReadOnly = true;
        });
      });

      _socket.on('updateScore', (roomData) {
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });

      _socket.on('show-leaderboard', (roomPlayers) {
        scoreboard.clear();
        for (int i = 0; i < roomPlayers.length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomPlayers[i]['nickname'],
              'points': roomPlayers[i]['points'].toString()
            });
          });
          if (maxPoints < int.parse(scoreboard[i]['points'])) {
            winner = scoreboard[i]['username'];
            maxPoints = int.parse(scoreboard[i]['points']);
          }
        }
        setState(() {
          _timer.cancel();
          isShowFinalLeaderboard = true;
        });
      });

      _socket.on('user-disconnected', (data) {
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],
              'points': data['players'][i]['points'].toString()
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
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
      key: scaffoldKey,
      drawer: PlayerScoreDrawer(userData: scoreboard),
      backgroundColor: Colors.white,
      body: dataOfRoom.isNotEmpty
          ? dataOfRoom['isJoin'] != true
              ? !isShowFinalLeaderboard
                  ? Stack(
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
                                  dataOfRoom['turn']['nickname'] ==
                                          widget.data['nickname']
                                      ? _socket.emit('paint', {
                                          'details': {
                                            'dx': details.localPosition.dx,
                                            'dy': details.localPosition.dy,
                                          },
                                          'roomName': widget.data['name']
                                        })
                                      : null;
                                },
                                onPanStart: (details) {
                                  dataOfRoom['turn']['nickname'] ==
                                          widget.data['nickname']
                                      ? _socket.emit('paint', {
                                          'details': {
                                            'dx': details.localPosition.dx,
                                            'dy': details.localPosition.dy,
                                          },
                                          'roomName': widget.data['name']
                                        })
                                      : null;
                                },
                                onPanEnd: (details) {
                                  dataOfRoom['turn']['nickname'] ==
                                          widget.data['nickname']
                                      ? _socket.emit('paint', {
                                          'details': null,
                                          'roomName': widget.data['name'],
                                        })
                                      : null;
                                },
                                child: SizedBox.expand(
                                    child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      size: Size.infinite,
                                      painter:
                                          MyCustomPainter(pointsList: points),
                                    ),
                                  ),
                                )),
                              ),
                            ),
                            Visibility(
                              visible: dataOfRoom['turn']['nickname'] ==
                                  widget.data['nickname'],
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.color_lens,
                                        color: selectedColor),
                                    onPressed: selectColor,
                                  ),
                                  Expanded(
                                    child: Slider(
                                        activeColor: Colors.green,
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
                                    icon: Icon(Icons.layers_clear,
                                        color: selectedColor),
                                    onPressed: () {
                                      _socket.emit(
                                          'clean-screen', dataOfRoom['name']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            dataOfRoom['turn']['nickname'] !=
                                    widget.data['nickname']
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: textBlankWidget,
                                  )
                                : Center(
                                    child: Text(
                                      dataOfRoom['word'],
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                  ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      var msg = messages[index].values;
                                      return ListTile(
                                        title: Text(
                                          msg.elementAt(0),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          msg.elementAt(1),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }))
                          ],
                        ),
                        dataOfRoom['turn']['nickname'] !=
                                widget.data['nickname']
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: TextField(
                                      readOnly: isTextInputReadOnly,
                                      controller: controller,
                                      autocorrect: false,
                                      onSubmitted: (value) {
                                        if (value.trim().isNotEmpty) {
                                          Map map = {
                                            'username': widget.data['nickname'],
                                            'msg': value.trim(),
                                            'word': dataOfRoom['word'],
                                            'roomName': dataOfRoom['name'],
                                            'guessedUserCtr': guessedUserCtr,
                                            'totalTime': 60,
                                            'timeTaken': 60 - _start,
                                          };
                                          _socket.emit('msg', map);
                                          controller.clear();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 14),
                                        filled: true,
                                        fillColor: const Color(0xffF5F5FA),
                                        hintText: 'Your Guess',
                                        hintStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        SafeArea(
                          child: IconButton(
                            onPressed: () =>
                                scaffoldKey.currentState!.openDrawer(),
                            icon: const Icon(Icons.menu),
                          ),
                        )
                      ],
                    )
                  : FinalLeaderboard(scoreboard, winner)
              : WaitingLobbyScreen(
                  occupancy: dataOfRoom['occupancy'],
                  noOfPlayers: dataOfRoom['players'].length,
                  lobbyName: dataOfRoom['name'],
                  players: dataOfRoom['players'],
                )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            '$_start',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}
