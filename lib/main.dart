import 'dart:io';
import 'package:onetool/servers.dart';
import 'package:onetool/settings.dart';
import 'package:onetool/users.dart';
import 'package:window_manager/window_manager.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:onetool/engine.dart';
import 'agents.dart';
import 'network.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(600, 475));
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
      // Provider.of<fastEngine>(context, listen: false).launch();
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
                child: !engine.loggedIn
                  ? Center(
                    child: Container(
                        width: 420,
                        child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Authentication",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  Text(
                                    "Please, log in using your passkey",
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top:10),
                                    child: TextField(
                                      controller: TextEditingController(),
                                      autofocus: true,
                                      obscureText: true,
                                      onChanged: (value) async {
                                        await engine.checkPassword(value).then((value){
                                          if(value){
                                            engine.loggedIn = true;
                                            engine.launch();
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.password_rounded),
                                        labelText: 'Passkey',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  ExpansionTileTheme(
                                      data: ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5)),
                                      child: Theme(
                                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                          child: ExpansionTile(
                                            title: Text("Forgot passkey?"),
                                            children: [
                                              Card(
                                                elevation: 10,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(15),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "Erase database",
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                          ),
                                                          Text(
                                                            "If you have forgot your passkey",
                                                          )
                                                        ],
                                                      ),
                                                      FilledButton(
                                                          onPressed: () {
                                                            showDialog<String>(
                                                              context: context,
                                                              builder: (BuildContext context) => AlertDialog(
                                                                icon: Icon(Icons.delete_rounded),
                                                                title: const Text('Clear data?'),
                                                                content: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Text('You are about to clear all known servers and settings.\nPlease confirm this action'),
                                                                  ],
                                                                ),
                                                                actions: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      FilledButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)),
                                                                          child: Text(
                                                                            'Cancel',
                                                                            style: TextStyle(color: Theme.of(context).colorScheme.background),
                                                                          )
                                                                      ),
                                                                      FilledButton(
                                                                          onPressed: () async {
                                                                            engine.clearDB();
                                                                            engine.launch();
                                                                            engine.loggedIn = true;
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: const Text('Confirm')
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          style: ButtonStyle(
                                                              backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)
                                                          ),
                                                          child: Text(
                                                            'Erase',
                                                            style: TextStyle(color: Theme.of(context).colorScheme.background),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      )
                                  )
                                ],
                              ),
                            )
                        )
                    )
                )
                : engine.globalPassword.isEmpty
                    ? Center(
                    child: Container(
                        width: 420,
                        child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Set up your passkey",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          Text(
                                            "Enter desired passkey for the app",
                                          )
                                        ],
                                      ),
                                      FilledButton(
                                          onPressed: () async {
                                            engine.clearDB();
                                            engine.setPassword(engine.globeP.text);
                                            engine.loggedIn = true;
                                            engine.launch();
                                          },
                                          child: const Text('Save')
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top:10),
                                    child: TextField(
                                      controller: engine.globeP,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.password_rounded),
                                        labelText: 'Passkey',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        )
                    )
                )
                :engine.loading ?
                Center(
                  child: Container(
                    height: 85,
                    width: 450,
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
                                  "Loading...",
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
                      extended: false,
                      destinations: const [
                        NavigationRailDestination(
                          label: Text("Users", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.person_rounded),
                        ),
                        NavigationRailDestination(
                          label: Text("Servers", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.dns_rounded),
                        ),
                        NavigationRailDestination(
                          label: Text("Voiso Users", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.dialer_sip_rounded),
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
                      width: scaffoldWidth - 81,
                      height: scaffoldHeight,
                      child: Builder(
                        builder: (context) {
                          switch (screenIndex) {
                            case 0: return UsersPage(); // FastPanel Mailboxes
                            case 1: return ServersPage(); // FastPanel Instances
                            case 2: return AgentsPage(); // Voiso Agents
                            case 3: return SettingsPage(); // App Settings
                            default: return Container();
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
