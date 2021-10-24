import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isolates_sample/widgets/animation_widget.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({Key? key}) : super(key: key);

  @override
  _PerformancePageState createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  Future<void> computeFuture = Future.value();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimationWidget(),
            mainIsolateButton(),
            secondaryIsolateButton(),
          ],
        ),
      ),
    );
  }

  mainIsolateButton() {
    return FutureBuilder<void>(
      future: computeFuture,
      builder: (context, snapshot) {
        return OutlinedButton(
            onPressed: createMainIsolateCallback(context, snapshot),
            child: const Text('Main Isolate'));
      },
    );
  }

  secondaryIsolateButton() {
    return FutureBuilder(
      future: computeFuture,
      builder: (context, snapshot) {
        return OutlinedButton(
          onPressed: createSecondaryIsolateCallback(context, snapshot),
          child: const Text('Secondary Isolate'),
        );
      },
    );
  }

  VoidCallback? createMainIsolateCallback(
      BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return () {
        setState(() {
          computeFuture = computeOnMainIsolate().then((val) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Main Isolate'),
              ),
            );
          });
        });
      };
    } else {
      return null;
    }
  }

  VoidCallback? createSecondaryIsolateCallback(
      BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return () {
        setState(() {
          computeFuture = computeOnSecondaryIsolate().then((val) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Secondary Isolate'),
              ),
            );
          });
        });
      };
    } else {
      return null;
    }
  }

  Future<int> computeOnMainIsolate() async {
    return await Future.delayed(
        const Duration(milliseconds: 100), () => fib(40));
  }

  Future<int> computeOnSecondaryIsolate() async {
    return await compute(fib, 40);
  }
}

int fib(int n) {
  int number1 = n - 1;
  int number2 = n - 2;
  if (0 == n) {
    return 0;
  } else if (1 == n) {
    return 1;
  } else {
    return (fib(number1) + fib(number2));
  }
}
