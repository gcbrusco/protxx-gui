import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

import 'data.dart';
import 'new_test.dart';
import 'compare.dart';
import 'power.dart';
import 'graph.dart';
import 'compare_menu.dart';
import 'home.dart';
import 'data_page.dart';
import 'test.dart';
import 'time.dart';

class TestPage1 extends StatefulWidget {
  Test1 createState() => Test1();
}

class Test1 extends State<TestPage1> {
  int selection;
  int length;
  DateTime time = DateTime.now();
  List<Data> chartDataOpen;
  List<Data> chartDataClosed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selection = ModalRoute.of(context).settings.arguments;
    length = ModalRoute.of(context).settings.arguments;
  }


  List<Data> getChartData() {
    //TODO: Make sure the data list has the # of element because right now it only works with 10 sec tests
    //find accelerometer data
    int numData = (10 * selection) + 1;
    List<Data> chartData = new List(numData);
    UserAccelerometerEvent event;
    Timer timer;
    StreamSubscription accel;

    double vx;
    double vy;
    double vz;
    double powerX;
    double powerY;
    double powerZ;

    int count = 0;
    if (accel == null) {
      accel = userAccelerometerEvents.listen((UserAccelerometerEvent eve) {
        setState(() {
          event = eve;
        });
      });
    } else {
      accel.resume();
    }
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 100), (_) {
        if (count == numData) {
          timer.cancel();
          accel.pause();
        } else {
          chartData[count] =
              Data(count.toDouble()/10, event.x, event.y, event.z, 0);

          if (count <= 4) {
            vx = 0;
            vy = 0;
            vz = 0;
          } else {
            vx = (chartData[count].x - chartData[count - 4].x) * .4;
            vy = (chartData[count].y - chartData[count - 4].y) * .4;
            vz = (chartData[count].z - chartData[count - 4].z) * .4;
          }
          powerX = (vx * chartData[count].x).abs()*.145;
          powerY = (vy * chartData[count].y).abs()*.145;
          powerZ = (vz * chartData[count].z).abs()*.145;
          chartData[count].power = (powerX + powerY + powerZ) / 3;

          count++;
        }
      });
    }
    return chartData;
  }

  Timer _timer;

  void _startTimer() {
    chartDataOpen = getChartData();
    testsOpen[time] = chartDataOpen;

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (selection > 0) {
          selection--;
        } else {
          FlutterRingtonePlayer.playNotification();
          Vibration.vibrate();
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/new': (BuildContext context) => NewTest(), //new test page
        '/data': (BuildContext context) => DataPage(), //past data page
        '/time': (BuildContext context) => TimePage(), //page to select time
        '/test1': (BuildContext context) => TestPage1(), //first testing screen
        '/test2': (BuildContext context) => TestPage2(), //second testing screen
        '/compareMenu': (BuildContext context) => CompareMenuPage(), //select metrics to compare to
        '/graph': (BuildContext context) => GraphPage(), //page displaying graphs
        '/compare': (BuildContext context) => ComparePage(), //page comparing graphs
        '/power': (BuildContext context) => PowerPage(), //page displaying power graphs
      },
      theme: new ThemeData(scaffoldBackgroundColor: const Color(0xFFFF)),
      home: Scaffold(
        appBar: AppBar(
            title: Text('Eyes Open Test'),
            backgroundColor: Colors.red,
            actions: <Widget>[
              if(selection == length)
                IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/");
                    }),
            ]),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  "Keep your eyes open for this test.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
              (selection > 0)
                  ? Text("")
                  : Text(
                "DONE!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              Text(
                '$selection',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              if(selection == length)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    minimumSize: Size(30, 30),
                  ),
                  onPressed: () => _startTimer(),
                  child: Text("Begin Test 1"),
                )
              else if (selection <= 0)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    minimumSize: Size(30, 30),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/test2',
                      arguments: {'Time': time, 'Selection': length, 'orig_Selection': length},
                    );
                  },
                  child: Text("Take Test 2"),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class TestPage2 extends StatefulWidget {
  @override
  Test2 createState() => Test2();
}

class Test2 extends State<TestPage2> {
  List<Data> chartDataClosed;

  Map info = {};

  @override
  List<Data> getChartData() {
    //find accelerometer data
    int numData = (10 * info['Selection']) + 1;
    List<Data> chartData = new List(numData);
    UserAccelerometerEvent event;
    Timer timer;
    StreamSubscription accel;

    double vx;
    double vy;
    double vz;
    double powerX;
    double powerY;
    double powerZ;

    int count = 0;
    if (accel == null) {
      accel = userAccelerometerEvents.listen((UserAccelerometerEvent eve) {
        setState(() {
          event = eve;
        });
      });
    } else {
      accel.resume();
    }
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 100), (_) {
        if (count == numData) {
          timer.cancel();
          accel.pause();
        } else {
          chartData[count] =
              Data(count.toDouble()/10, event.x, event.y, event.z, 0);

          if (count <= 4) {
            vx = 0;
            vy = 0;
            vz = 0;
          } else {
            vx = (chartData[count].x - chartData[count - 4].x) * .4;
            vy = (chartData[count].y - chartData[count - 4].y) * .4;
            vz = (chartData[count].z - chartData[count - 4].z) * .4;
          }
          powerX = (vx * chartData[count].x).abs()*.145;
          powerY = (vy * chartData[count].y).abs()*.145;
          powerZ = (vz * chartData[count].z).abs()*.145;
          chartData[count].power = (powerX + powerY + powerZ) / 3;
          print(chartData[count].power);

          count++;
        }
      });
    }
    return chartData;
  }

  Timer _timer;

  void _startTimer() {
    chartDataClosed = getChartData();
    testsClosed[info['Time']] = chartDataClosed;

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (info['Selection'] > 0) {
          info['Selection']--;
        } else {
          FlutterRingtonePlayer.playNotification();
          Vibration.vibrate();
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    info = ModalRoute.of(context).settings.arguments;

    int choice = info['Selection'];
    int length = info['const_Selection'];

    return MaterialApp(
      routes: {
        '/new': (BuildContext context) => NewTest(), //new test page
        '/data': (BuildContext context) => DataPage(), //past data page
        '/time': (BuildContext context) => TimePage(), //page to select time
        '/test1': (BuildContext context) => TestPage1(), //first testing screen
        '/test2': (BuildContext context) => TestPage2(), //second testing screen
        '/compareMenu': (BuildContext context) => CompareMenuPage(), //select metrics to compare to
        '/graph': (BuildContext context) => GraphPage(), //page displaying graphs
        '/compare': (BuildContext context) => ComparePage(), //page comparing graphs
        '/power': (BuildContext context) => PowerPage(), //page displaying power graphs
      },
      theme: new ThemeData(scaffoldBackgroundColor: const Color(0xFFFF)),
      home: Scaffold(
        appBar: AppBar(
            title: Text('Eyes Closed Test'),
            backgroundColor: Colors.red,
            actions: <Widget>[
            ]),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  "Keep your eyes closed for this test.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
              (info['Selection'] > 0)
                  ? Text("")
                  : Text(
                "DONE!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              Text(
                '$choice',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
              if (info['Selection'] == info['orig_Selection'])
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    minimumSize: Size(30, 30),
                  ),
                  onPressed: () => _startTimer(),
                  child: Text("Begin Test 2"),
                )
              else if (info['Selection'] <= 0)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    minimumSize: Size(30, 30),
                  ),
                  onPressed: () {
                    //TODO: CHANGE TO PREVIOUS TEST PAGE
                    Navigator.of(context).pushNamed(
                      '/graph',
                      arguments: info['Time'],
                    );
                  },
                  child: Text("See Results"),
                ),

            ],
          ),
        ),
      ),
    );
  }
}