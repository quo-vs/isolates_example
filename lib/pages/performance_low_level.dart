import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isolates_sample/models/thread_params.dart';

class PerformanceLowLevelPage extends StatefulWidget {
  const PerformanceLowLevelPage({Key? key}) : super(key: key);

  @override
  _PerformanceLowLevelPageState createState() =>
      _PerformanceLowLevelPageState();
}

class _PerformanceLowLevelPageState extends State<PerformanceLowLevelPage> {
  Isolate? _isolate;
  bool _running = false;
  bool _paused = false;
  String _message = '';
  String _threadStatus = '';
  ReceivePort? _receivePort;
  Capability? _capability;

  void _start() async {
    if (_running) {
      return;
    }
    setState(() {
      _running = true;
      _message = 'Starting...';
      _threadStatus = 'Running...';
    });
    _receivePort = ReceivePort();
    ThreadParams threadParams = ThreadParams(2000, _receivePort!.sendPort);
    _isolate = await Isolate.spawn(_isolateHandler, threadParams);
    _receivePort!.listen(_handleMessage, onDone: () {
      setState(() {
        _threadStatus = 'Stopped';
      });
    });
  }

  void _pause() {
    if (_isolate != null) {
      _paused
          ? _isolate!.resume(_capability!)
          : _capability = _isolate!.pause();
      setState(() {
        _paused = !_paused;
        _threadStatus = _paused ? 'Paused' : 'Resumed';
      });
    }
  }

  void _stop() {
    if (_isolate != null) {
      setState(() {
        _running = false;
      });
      _receivePort!.close();
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  void _handleMessage(dynamic data) {
    setState(() {
      _message = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          !_running
              ? OutlinedButton(
                  onPressed: () {
                    _start();
                  },
                  child: const Text('Start Isolate'),
                )
              : const SizedBox(),
          _running
              ? OutlinedButton(
                  onPressed: () {
                    _pause();
                  },
                  child: Text(_paused ? 'Resume Isolate' : 'Pause Isolate'),
                )
              : const SizedBox(),
          _running
              ? OutlinedButton(
                  onPressed: () {
                    _stop();
                  },
                  child: const Text('Stop Isolate'),
                )
              : const SizedBox(),
          const SizedBox(
            height: 20,
          ),
          Text(
            _threadStatus,
            style: const TextStyle(fontSize: 20.0),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            _message,
            style: const TextStyle(fontSize: 20.0, color: Colors.green),
          )
        ],
      ),
    );
  }

  static void heavyOperation(ThreadParams threadParams) async {
    int count = 10000;
    while (true) {
      int sum = 0;
      for (int i = 0; i < count; i++) {
        sum += await computeSum(1000);
      }
      count += threadParams.value;
      threadParams.sendPort.send(sum.toString());
    }
  }

  
  static Future<int> computeSum(int num) {
    Random random = Random();
    return Future(() {
      int sum = 0;
      for (int i = 0; i < num; i++) {
        sum += random.nextInt(100);
      }
      return sum;
    });
  }

  static void _isolateHandler(ThreadParams threadParams) async {
    heavyOperation(threadParams);
  }
}
