import 'dart:isolate';

class ThreadParams {
  int value;
  SendPort sendPort;

  ThreadParams(this.value, this.sendPort);
}