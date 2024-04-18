import 'dart:io';
import 'package:onetool/logs.dart';
import 'package:onetool/servers.dart';
import 'package:onetool/settings.dart';
import 'package:onetool/users.dart';
import 'package:window_manager/window_manager.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:onetool/engine.dart';
import 'agents.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'labels.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    print("Get webbed");
  } else if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(700, 475));
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
        home: Consumer<fastEngine>(builder: (context, engine, child) {
          return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            double scaffoldHeight = constraints.maxHeight;
            double scaffoldWidth = constraints.maxWidth;
            return Scaffold(
              body: Container(
                width: scaffoldWidth,
                height: scaffoldHeight,
                child: Row(
                  children: [
                    NavigationRail(
                      elevation: 5,
                      extended: false,
                      destinations: [
                        NavigationRailDestination(
                          disabled: engine.domainsLoading,
                          label: Text("Users", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.person_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.domainsLoading,
                          label: Text("Servers", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.dns_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.domainsLoading,
                          label: Text("Labels", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.label_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.voisoLoading,
                          label: Text("Voiso Users", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.dialer_sip_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.domainsLoading,
                          label: Text("Logs", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.history_rounded),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(top: scaffoldHeight - 280),
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
                      width: scaffoldWidth - 81,
                      height: scaffoldHeight,
                      child: Builder(
                        builder: (context) {
                          switch (screenIndex) {
                            case 0: return UsersPage(); // FastPanel Mailboxes
                            case 1: return ServersPage(); // FastPanel Instances
                            case 2: return LabelsPage(); // FastPanel Instances
                            case 3: return AgentsPage(); // Voiso Agents
                            case 4: return LogsPage(); // Logs
                            default: return SettingsPage(); // App Settings
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
