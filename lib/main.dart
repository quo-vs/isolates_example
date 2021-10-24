import 'package:flutter/material.dart';
import 'package:isolates_sample/pages/performance_low_level.dart';
import 'package:isolates_sample/pages/performance_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolates demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Isolates with compute()'),
                Tab(text: 'Low level isolates'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              PerformancePage(),
              PerformanceLowLevelPage()
            ],
          ),
        ),
      ),
    );
  }
}
