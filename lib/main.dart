import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        // useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

Future<int> runHeavyTaskIWithIsolate(int count) async {
  final ReceivePort receivePort = ReceivePort();
  int result = 0;
  try {
    await Isolate.spawn(useIsolate, [receivePort.sendPort, count]);
    result = await receivePort.first;
  } on Object catch (e, stackTrace) {
    debugPrint('Isolate Failed: $e');
    debugPrint('Stack Trace: $stackTrace');
    receivePort.close();
  }
  return result;
}

void useIsolate(List<dynamic> args) {
  SendPort resultPort = args[0];
  int value = 0;
  for (var i = 0; i < args[1]; i++) {
    value += i;
  }
  resultPort.send(value);
}

int runHeavyTaskWithOutIsolate(int count) {
  int value = 0;
  for (var i = 0; i < count; i++) {
    value += i;
  }
  return value;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _periodicTimer;
  int _timerValue = 0;
  int _heavyComputationValueWithIsolate = 0;
  int _heavyComputationValueWithoutIsolate = 0;
  var color =
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  startTimer() {
    const oneSecond = Duration(microseconds: 1);
    _periodicTimer = Timer.periodic(oneSecond, (Timer timer) {
      setState(() {
        _timerValue++;
        color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1.0);
      });
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(44),
                child: Text(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    'Starting a timer and performing the following computation will result in lag without using \'isolate\' option. Smooth rendering is achieved with isolation.'),
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 60)),
            const Divider(),
            Text('$_timerValue'),
            const Divider(),
            TextButton(
                // style: TextButton.styleFrom(
                //     iconColor: _timerValue == 0 ? Colors.red : Colors.blue,
                //     textStyle: TextStyle(
                //         color: _timerValue == 0 ? Colors.red : Colors.blue)),
                onPressed: _timerValue == 0 ? startTimer : () {},
                child: Text(
                  'Start Timer',
                  style: TextStyle(
                      color: _timerValue == 0 ? Colors.blue : Colors.grey),
                )),
            TextButton(
                onPressed: () {
                  _periodicTimer?.cancel();
                  setState(() {
                    _timerValue = 0;
                  });
                },
                child: const Text(
                  'Stop Timer',
                  style: TextStyle(color: Colors.blue),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Heavy Computation value with Isolate : $_heavyComputationValueWithIsolate'),
                    Text(
                        'Heavy Computation value without Isolate : $_heavyComputationValueWithoutIsolate'),
                  ],
                ),
                const Divider(
                  height: 30,
                  thickness: 1,
                  indent: 1,
                  color: Colors.red,
                  endIndent: 30,
                ),
                _timerValue == 0
                    ? Container()
                    : CircularProgressIndicator(
                        color: color,
                      ),
              ],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                    onPressed: () async {
                      int value1 = await runHeavyTaskIWithIsolate(
                          Random().nextInt(1000000000) + 500000000);
                      setState(() {
                        _heavyComputationValueWithIsolate = value1;
                      });
                    },
                    child: const Text('Start Heavy Computation With Isolate')),
                TextButton(
                    onPressed: () {
                      int value1 = runHeavyTaskWithOutIsolate(
                          Random().nextInt(1000000000) + 500000000);
                      setState(() {
                        _heavyComputationValueWithoutIsolate = value1;
                      });
                    },
                    child:
                        const Text('Start Heavy Computation Without Isolate')),
              ],
            ),
            TextButton(
                onPressed: () async {
                  setState(() {
                    _heavyComputationValueWithoutIsolate = 0;
                    _heavyComputationValueWithIsolate = 0;
                  });
                },
                child: const Text('Clear Computation')),
          ],
        ),
      ),
    );
  }
}
