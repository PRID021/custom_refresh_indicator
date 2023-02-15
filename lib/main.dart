import 'package:custom_indicator/custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:monkey_lib/utils/pretty_json.dart';

import 'custom_refresh_indicator/custom_refresh_indicator_controller.dart';
import 'custom_refresh_indicator/delegates/default_indicator_builder_delegate.dart';
import 'custom_refresh_indicator/delegates/material_indicator_delegate.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: CustomRefreshIndicator(
          leadingScrollIndicatorVisible: true,
          trailingScrollIndicatorVisible: true,
          // builderDelegate: DefaultIndicatorBuilderDelegate(),
          builderDelegate: MaterialIndicatorDelegate(builder:
              (BuildContext context,
                  CustomRefreshIndicatorController controller) {
            return Container(
              child: Icon(Icons.ac_unit),
              width: 100,
              height: 100,
            );
          }),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Item $index"),
              );
            },
            itemCount: 30,
          ),
        ),
      ),
    );
  }
}
