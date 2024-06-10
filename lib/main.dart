import 'package:flutter/services.dart';
import 'package:onetool/logs.dart';
import 'package:onetool/numbercheck.dart';
import 'package:onetool/servers.dart';
import 'package:onetool/settings.dart';
import 'package:onetool/users.dart';
import 'package:onetool/engine.dart';
import 'package:onetool/voiso.dart';
import 'labels.dart';
import 'package:intl/intl.dart' as intl;
import 'package:window_manager/window_manager.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(750, 600));
  // WindowManager.instance.setMaximumSize(const Size(775, 525));


  runApp(ChangeNotifierProvider(
    create: (context) => fastEngine(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}
class MyAppState extends State<MyApp> {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<fastEngine>(context, listen: false).launch();
    });
  }
  Future<String?> getClipboardData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  @override
  Widget build(BuildContext aTopContext) {
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
          return LayoutBuilder(builder: (BuildContext uTopContext, BoxConstraints constraints) {
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
                        const NavigationRailDestination(
                          label: Text("Home", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.home_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.domainsLoading,
                          label: const Text("Emails", style: TextStyle(fontSize: 18)),
                          icon: const Icon(Icons.alternate_email_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.domainsLoading,
                          label: const Text("Servers", style: TextStyle(fontSize: 18)),
                          icon: const Icon(Icons.dns_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.domainsLoading,
                          label: const Text("Labels", style: TextStyle(fontSize: 18)),
                          icon: const Icon(Icons.label_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.voisoClusters.isEmpty,
                          label: const Text("Voiso Users", style: TextStyle(fontSize: 18)),
                          icon: const Icon(Icons.dialer_sip_rounded),
                        ),
                        const NavigationRailDestination(
                          // disabled: engine.voisoLoading,
                          label: Text("Voiso Clusters", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.sip_rounded),
                        ),
                        const NavigationRailDestination(
                          // disabled: engine.voisoLoading,
                          label: Text("Numbercheck", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.dialpad_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.voisoLoading,
                          label: const Text("CDR", style: TextStyle(fontSize: 18)),
                          icon: const Icon(Icons.list_alt_rounded),
                        ),
                        NavigationRailDestination(
                          disabled: engine.domainsLoading,
                          label: const Text("Logs", style: TextStyle(fontSize: 18)),
                          icon: const Icon(Icons.history_rounded),
                        ),
                        const NavigationRailDestination(
                          label: Text("Settings", style: TextStyle(fontSize: 18)),
                          icon: Icon(Icons.settings_rounded),
                        ),
                      ],
                      selectedIndex: engine.screenIndex,
                      useIndicator: true,
                      onDestinationSelected: (int index) {
                        setState(() {
                          engine.screenIndex = index;
                        });
                      },
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Container(
                      width: scaffoldWidth - 81,
                      height: scaffoldHeight,
                      child: Builder(
                        builder: (context) {
                          Widget metricCard(name, amount, page, button){
                            return Expanded(
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                elevation: 2,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      engine.screenIndex = page;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${amount.toString()} $name",
                                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                ),
                                                Text(
                                                  "Go to $name",
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: button,
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
                          switch (engine.screenIndex) {
                            case 0:
                              DateTime time = DateTime.fromMillisecondsSinceEpoch(engine.lastUpdateTime);
                              return Container(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        metricCard(
                                            "emails",
                                            engine.users.length,
                                            1,
                                            engine.domainsLoading?const Icon(Icons.cloud_sync_rounded,color: Colors.grey,):IconButton(
                                                onPressed: () {
                                                  engine.toOpenUCM = true;
                                                  setState(() {
                                                    engine.screenIndex = 1;
                                                  });
                                                },
                                                icon: const Icon(Icons.add_rounded)
                                            )
                                        ),
                                        metricCard(
                                            "servers",
                                            engine.domains.length,
                                            2,
                                            engine.domainsLoading?const Icon(Icons.cloud_sync_rounded,color: Colors.grey,):IconButton(
                                                onPressed: () {
                                                  engine.toOpenDCM = true;
                                                  setState(() {
                                                    engine.screenIndex = 2;
                                                  });
                                                },
                                                icon: const Icon(Icons.add_rounded)
                                            )
                                        ),
                                        metricCard(
                                            "labels",
                                            engine.labels.length,
                                            3,
                                            engine.domainsLoading?const Icon(Icons.cloud_sync_rounded,color: Colors.grey,):IconButton(
                                                onPressed: () {
                                                  engine.toOpenLCM = true;
                                                  setState(() {
                                                    engine.screenIndex = 3;
                                                  });
                                                },
                                                icon: const Icon(Icons.add_rounded)
                                            )
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
                                                  engine.screenIndex = 4;
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              "Voiso agents",
                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                            ),
                                                            Text(
                                                              engine.balance == 0? "Not configured"
                                                                  :engine.voisoUserCount == 0? "Loading agents..."
                                                                  :"${engine.voisoUserCount.toString()} agents",
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const Padding(
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
                                                  engine.screenIndex = 5;
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "${engine.voisoClusters.length} voiso cluster${engine.voisoClusters.length%10==1?"":"s"}",
                                                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                            ),
                                                            Text(
                                                              engine.balance == 0? "Not configured"
                                                                  :"${engine.balance.toString()}\$ total",
                                                              style: TextStyle(
                                                                fontFamily: engine.demoMode?"Flow":null
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(left: 9),
                                                      child: Icon(Icons.keyboard_arrow_right),
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
                                                  engine.screenIndex = 6;
                                                });
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "HLR",
                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                            ),
                                                            Text(
                                                              "Validate numbers",
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
                                                  engine.screenIndex = 7;
                                                });
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "CDR",
                                                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                            ),
                                                            Text(
                                                              "Check call history",
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
                                      ],
                                    ),
                                    !engine.loadOnLaunch
                                        ?Card(
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Loading...",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                                Text(
                                                  engine.action,
                                                )
                                              ],
                                            ),
                                            CircularProgressIndicator(
                                              value: engine.loadPercent,
                                              backgroundColor: Colors.transparent,
                                              strokeCap: StrokeCap.round,
                                              color: Theme.of(context).colorScheme.primary,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                        :Row(
                                      children: [
                                        Expanded(
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
                                                        (DateTime.now().millisecondsSinceEpoch - engine.lastUpdateTime)/10000 > 1?engine.updateStatus:"Updated!",
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                      ),
                                                      Text(
                                                        (DateTime.now().millisecondsSinceEpoch - engine.lastUpdateTime)/10000 > 1?"Started updating ${time.add(const Duration(seconds: 10)).timeAgo(numericDates: false)}":"Updated ${time.timeAgo(numericDates: false)}",
                                                      )
                                                    ],
                                                  ),
                                                  CircularProgressIndicator(
                                                    value: (DateTime.now().millisecondsSinceEpoch - engine.lastUpdateTime)/10000 > 1?engine.updatePercent:(DateTime.now().millisecondsSinceEpoch - engine.lastUpdateTime)/10000,
                                                    backgroundColor: Colors.transparent,
                                                    strokeCap: StrokeCap.round,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        engine.recentRemoteCreate.isEmpty?Container(width: 0,):Expanded(child: Card(
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
                                                      "Recently ${engine.recentRemoteCreate["action"].toLowerCase().replaceAll("ing","ed")}",
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                    ),
                                                    Container(
                                                      constraints: BoxConstraints(
                                                          maxWidth: scaffoldWidth / 2 - 80
                                                      ),
                                                      child: Text(
                                                        engine.recentRemoteCreate["name"],
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontFamily: engine.demoMode?"Flow":null
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                      ],
                                    ),
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
                                            engine.screenIndex = 2;
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
                                                  const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.warning_rounded)),
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
                                                  const Icon(Icons.keyboard_arrow_right_rounded)
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            );
                            case 1: return const UsersPage(); // FastPanel Mailboxes
                            case 2: return const ServersPage(); // FastPanel Instances
                            case 3: return const LabelsPage(); // FastPanel Instances
                            case 4: return const AgentsPage(); // Voiso Agents
                            case 5: return const VoisoClusters(); // Voiso Clusters
                            case 6: return const NumberCheckPage(); // Numbercheck
                            case 7: return const CDRPage(); // CDR
                            case 8: return const LogsPage(); // Logs
                            default: return const SettingsPage(); // App Settings
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
