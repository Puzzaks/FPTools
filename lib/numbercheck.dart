import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'engine.dart';
import 'network.dart';

class NumberCheckPage extends StatefulWidget {
  const NumberCheckPage({super.key});
  @override
  NumberCheckPageState createState() => NumberCheckPageState();
}

class NumberCheckPageState extends State<NumberCheckPage> {
  @override
  @override
  void initState() {
    super.initState();
  }
  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  @override
  Widget build(BuildContext context) {
    final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: Consumer<fastEngine>(builder: (context, engine, child) {
          return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double scaffoldHeight = constraints.maxHeight;
                double scaffoldWidth = constraints.maxWidth;
                return Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("numcheck")
                      ],
                    ),
                  ),
                );
              }
          );
        }),
      );
    });
  }
}