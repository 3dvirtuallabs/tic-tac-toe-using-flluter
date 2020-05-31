import 'package:flutter/material.dart';
import 'dart:math' as math;

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class ScreenObjects {
  final String playAs;

  ScreenObjects({this.playAs});
}

class _GameState extends State<Game> {
  List<String> grid = new List<String>(9);
  bool player2Trun = false;
  bool _gameStarted = true;
  int emptySlot = 9;
  List<List<int>> canMatch = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];
  String _chooseOption = 'X';
  bool _draw = false;
  String _winner;

  bool checkWinner() {
    bool stopGame = false;
    for (int i = 0; i < canMatch.length; i++) {
      int a = canMatch[i][0];
      int b = canMatch[i][1];
      int c = canMatch[i][2];
      bool notNull = grid[a] != null && grid[b] != null && grid[c] != null;
      if (grid[a] == grid[b] && grid[b] == grid[c] && notNull) {
        print('${grid[a]}=${grid[b]}=${grid[c]}');
        stopGame = true;
        _winner = grid[a];
        break;
      }
    }
    if (stopGame) {
      return true;
    } else {
      if (grid.where((element) => element != null).length == 9) {
        setState(() {
          _draw = true;
        });
      }
      return false;
    }
  }

  void fill2ndPlayer() {
    int n = new math.Random().nextInt(9);
    if (grid[n] == null || grid[n] == "") {
      setState(() {
        grid[n] = _chooseOption == "X" ? "O" : "X";
        player2Trun = false;
        checkWinner();
      });
    } else {
      if (grid.where((element) => element == null).length > 0 && !checkWinner())
        fill2ndPlayer();
    }
  }

  GestureDetector t(i, e) {
    return GestureDetector(
      onTap: () {
        //let user click only if its their turn
        if (player2Trun || grid[i] != null || _winner != null) {
          return;
        }
        //let user click only if there is empty slow or no winner
        if (grid.where((element) => element == null).length > 0 &&
            !_draw &&
            !player2Trun) {
          //update state
          setState(() {
            grid[i] = _chooseOption;
            player2Trun = true;
            checkWinner();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 1)),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            e == null ? "" : e.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenObjects screenObjects = ModalRoute.of(context).settings.arguments;
    _chooseOption = screenObjects.playAs;
    if (player2Trun) {
      Future.delayed(new Duration(seconds: 1), () {
        if (_winner == null) fill2ndPlayer();
        setState(() {
          player2Trun = false;
        });
      });
      //fill2ndPlayer();
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Tik Tak Toe'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil("/", (route) => false),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          player2Trun && _winner == null
              ? CircularProgressIndicator()
              : Container(),
          GridView(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0),
            children: grid
                .asMap()
                .map(
                  (i, e) => MapEntry(
                    i,
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: t(i, e),
                    ),
                  ),
                )
                .values
                .toList(),
          ),
          _draw
              ? SizedBox(
                  height: 50,
                  child: Text('Match Draw'),
                )
              : Container(),
          _winner != null
              ? SizedBox(
                  height: 50,
                  child: Text('Winner is $_winner'),
                )
              : Container(),
          _winner != null
              ? RaisedButton(
                  child: Text('Start Game'),
                  onPressed: () {
                    setState(() {
                      _winner = null;
                      _draw = false;
                      grid = new List<String>(9);
                    });
                  },
                )
              : RaisedButton(
                  child: Text('Restart Game'),
                  onPressed: () {
                    if (_gameStarted) {
                      showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: Text("Are you sure?"),
                              content: Text(
                                  'if you click then other person will win by default'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Discard'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                FlatButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    setState(() {
                                      _winner = null;
                                      _draw = false;
                                      grid = new List<String>(9);
                                    });
                                    Navigator.of(ctx).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }
                  },
                )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
