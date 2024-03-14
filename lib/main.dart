import 'dart:io';
import 'package:voisoassistant/servers.dart';
import 'package:voisoassistant/settings.dart';
import 'package:voisoassistant/users.dart';
import 'package:window_manager/window_manager.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:voisoassistant/engine.dart';
import 'network.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(775, 525));
    // WindowManager.instance.setMaximumSize(const Size(775, 525));
  }

  runApp(ChangeNotifierProvider(
    create: (context) => fastEngine(),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int screenIndex = 0;
  void initState() {
    // SharedPreferences.setMockInitialValues({});
    WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<fastEngine>(context, listen: false).launch();
    });
  }


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
        title: 'FastPanel Toolkit',
        home: Consumer<fastEngine>(builder: (context, engine, child) {
          return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            double scaffoldHeight = constraints.maxHeight;
            double scaffoldWidth = constraints.maxWidth;
            return Scaffold(
              body: Container(
                width: scaffoldWidth,
                height: scaffoldHeight,
                child: engine.loading ?
                Center(
                  child: Container(
                    height: 85,
                    width: 420,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Loading",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                Text(
                                  engine.action,
                                )
                              ],
                            ),
                            CircularProgressIndicator(
                              backgroundColor: Colors.transparent,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ) :
                Row(
                  children: [
                    NavigationRail(
                      elevation: 5,
                      extended: true,
                      destinations: const [
                        NavigationRailDestination(
                          label: Text("Home", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.home_rounded),
                        ),
                        NavigationRailDestination(
                          label: Text("Users", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.person_rounded),
                        ),
                        NavigationRailDestination(
                          label: Text("Servers", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.dns_rounded),
                        ),
                        NavigationRailDestination(
                          label: Text("Settings", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.settings_rounded),
                        ),
                      ],
                      selectedIndex: screenIndex,
                      useIndicator: true,
                      onDestinationSelected: (int index) {
                        setState(() {
                          screenIndex = index;
                        });
                      },
                    ),
                    VerticalDivider(thickness: 1, width: 1),
                    Container(
                      width: scaffoldWidth - 257,
                      height: scaffoldHeight,
                      child: Builder(
                        builder: (context) {
                          switch (screenIndex) {
                            case 1:
                              return UsersPage(); //users
                            case 2:
                              return ServersPage(); //brands
                            case 3:
                              return SettingsPage(); //settings
                            default:
                              return Container();
                          }
                        },
                      ),
                    )
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
