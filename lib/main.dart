import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double> _accelerometerValues;
  String _document = 'android';

  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();

    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));

    setState(() {
      if (Platform.isAndroid) {
        _document = 'android';
        print('--> Platform is Android');
      } else {
        _document = 'iphone';
        print('--> Platform is iOS');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> am;
    if (_accelerometerValues == null) {
      am = ['0', '0', '0'];
    } else {
      am = _accelerometerValues
          ?.map((double v) => v.toStringAsFixed(0))
          ?.toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
//                Text('Flutter Phone Orientation'),
                Text('Flutter Phone Orientation:'),
                Text('x : ${am[0]}'),
                Text('y : ${am[1]}'),
                Text('z : ${am[2]}'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          RaisedButton(
            child: const Text('Update database in the sky'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: () {
              print('Updating document $_document');
              Firestore.instance
                  .collection('accelerometerValues')
                  .document(_document)
                  .setData({
                    'x': am[0],
                    'y': am[1],
                    'z': am[2],
                  });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
