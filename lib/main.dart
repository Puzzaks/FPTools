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
import 'labels.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(700, 475));
  // WindowManager.instance.setMaximumSize(const Size(775, 525));


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
                          label: Text("Home", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.home_rounded),
                        ),
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
                          padding: EdgeInsets.only(top: scaffoldHeight - 320),
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
                          Widget metricCard(name, amount, page, icon){
                            return Expanded(
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                elevation: 2,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      screenIndex = page;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(right:9),
                                              child: icon,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${amount.toString()} $name",
                                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                ),
                                                Text(
                                                  "Go to $name",
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 9),
                                          child: Icon(Icons.keyboard_arrow_right),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          List unavailables = [];
                          for(int i=0;i<engine.availables.length;i++){
                            if(!engine.availables[engine.availables.keys.toList()[i]]){
                              unavailables.add(engine.availables.keys.toList()[i]);
                            }
                          }
                          if(!engine.domainsLoading){
                            for(int i=0;i<engine.domains.length;i++){
                              for(int a=0;a<engine.domains[engine.domains.keys.toList()[i]].length;a++){
                                var curDomain = engine.domains[engine.domains.keys.toList()[i]][a];
                                curDomain["server"] = engine.domains.keys.toList()[i];
                                if(engine.known.containsKey(engine.domains.keys.toList()[i])){
                                  if(!engine.creationDomains.contains(curDomain)){
                                    engine.creationDomains.add(curDomain);
                                  }
                                }
                              }
                            }
                          }
                          switch (screenIndex) {
                            case 0: return Container(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    !engine.loadOnLaunch?Card(
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
                                    ):Container(),
                                    unavailables.isNotEmpty ? Card(
                                      color: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.errorContainer),
                                      clipBehavior: Clip.hardEdge,
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if(unavailables.length == 1){
                                              engine.serverSearch.text = engine.known[unavailables[0]]["name"];
                                              engine.filterServers();
                                            }
                                            screenIndex = 2;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.warning_rounded)),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: scaffoldWidth - 177,
                                                        child: Text(
                                                          "${unavailables.length==1?"Domain is unavailable: ${engine.known[unavailables[0]]["name"]}":"Some domains are not available: ${unavailables.map((e){return "$e";})}"}.",
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Icon(Icons.keyboard_arrow_right_rounded)
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ) : Container(),
                                    Row(
                                      children: [
                                        metricCard("users", engine.allUsers.length, 1, Icon(Icons.person_rounded)),
                                        metricCard("domains", engine.creationDomains.length, 2, Icon(Icons.dns_rounded)),
                                        metricCard("labels", engine.labels.length, 2, Icon(Icons.label_rounded)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            elevation: 2,
                                            child: InkWell(
                                              onTap: () {
                                                screenIndex = 1;
                                                engine.multiUserCreate = false;
                                                engine.glowDomains = {};
                                                engine.selectedLabels.clear();
                                                engine.userDomains.clear();
                                                engine.userErrors = [];
                                                engine.creationDomains = [];
                                                engine.userL.text = "";
                                                engine.userP.text = "";
                                                engine.userErrors.add("Enter valid username");
                                                engine.userErrors.add("No domains selected");
                                                for(int i=0;i<engine.domains.length;i++){
                                                  for(int a=0;a<engine.domains[engine.domains.keys.toList()[i]].length;a++){
                                                    var curDomain = engine.domains[engine.domains.keys.toList()[i]][a];
                                                    curDomain["server"] = engine.domains.keys.toList()[i];
                                                    if(engine.known.containsKey(engine.domains.keys.toList()[i])){
                                                      engine.creationDomains.add(curDomain);
                                                    }
                                                  }
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => NewUserPage()),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(right:9),
                                                          child: Icon(Icons.person_outline_rounded),
                                                        ),
                                                        Text(
                                                          "Add user",
                                                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 9),
                                                      child: Icon(Icons.add_rounded),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            elevation: 2,
                                            child: InkWell(
                                              onTap: () {
                                                screenIndex = 2;
                                                engine.tempL.text = "";
                                                engine.tempA.text = "";
                                                engine.tempU.text = "";
                                                engine.tempP.text = "";
                                                engine.tempPanelAddReady = false;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => NewServerPage()),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(right:9),
                                                          child: Icon(Icons.dns_outlined),
                                                        ),
                                                        Text(
                                                          "Add server",
                                                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 9),
                                                      child: Icon(Icons.add_rounded),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            elevation: 2,
                                            child: InkWell(
                                              onTap: () {
                                                screenIndex = 3;
                                                engine.creationDomains.clear();
                                                engine.tempLabel.clear();
                                                engine.labelName.text = "";
                                                for(int i=0;i<engine.domains.length;i++){
                                                  for(int a=0;a<engine.domains[engine.domains.keys.toList()[i]].length;a++){
                                                    var curDomain = engine.domains[engine.domains.keys.toList()[i]][a];
                                                    curDomain["server"] = engine.domains.keys.toList()[i];
                                                    if(engine.known.containsKey(engine.domains.keys.toList()[i])){
                                                      engine.creationDomains.add(curDomain);
                                                    }
                                                  }
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => EditLabelPage()),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(right:9),
                                                          child: Icon(Icons.label_outline_rounded),
                                                        ),
                                                        Text(
                                                          "Add label",
                                                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 9),
                                                      child: Icon(Icons.add_rounded),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            elevation: 2,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  screenIndex = 6;
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(right:9),
                                                          child: Icon(Icons.vpn_lock_rounded),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "Proxy",
                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                            ),
                                                            Text(
                                                              engine.proxyStatus,
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 9),
                                                      child: Icon(Icons.keyboard_arrow_right),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            elevation: 2,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  screenIndex = 6;
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(right:9),
                                                          child: Icon(Icons.dialer_sip_rounded),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "Voiso",
                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                            ),
                                                            Text(
                                                              (engine.voisoKeyCenter.text.isEmpty&&engine.voisoKeyUser.text.isEmpty&&engine.voisoCluster.text.isEmpty)
                                                                  ?"Not configured"
                                                                  :"${engine.voisoCluster.text}, ${engine.balance.toString()}\$",
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 9),
                                                      child: Icon(Icons.keyboard_arrow_right),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                            case 1: return UsersPage(); // FastPanel Mailboxes
                            case 2: return ServersPage(); // FastPanel Instances
                            case 3: return LabelsPage(); // FastPanel Instances
                            case 4: return AgentsPage(); // Voiso Agents
                            case 5: return LogsPage(); // Logs
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
