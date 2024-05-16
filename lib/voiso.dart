import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:onetool/logs.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'engine.dart';

class VoisoClusters extends StatefulWidget {
  const VoisoClusters({super.key});
  @override
  VoisoClustersState createState() => VoisoClustersState();
}

class VoisoClustersState extends State<VoisoClusters> {
  @override
  void initState() {
    super.initState();
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
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  engine.voisoCluster.text = "";
                  engine.voisoKeyCenter.text = "";
                  engine.voisoKeyUser.text = "";
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditVoisoCluster()),
                  );
                },
                tooltip: "Add cluster",
                child: const Icon(Icons.add_rounded),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: engine.voisoClusters.isEmpty ? null : scaffoldHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          children: engine.allClusters.keys.map((clustername) {
                        return Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${engine.allClusters[clustername]} $clustername",
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                            Text(
                                              engine.voisoBalances.containsKey(clustername)
                                                  ? engine.voisoBalances[clustername] == 0
                                                      ? "Error getting balance"
                                                      : "${engine.voisoBalances[clustername].toString()}\$"
                                                  : "Error getting balance",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              if(engine.allClusters[clustername] == "Voiso") {
                                                engine.voisoCluster.text = clustername;
                                                engine.voisoKeyCenter.text = engine.voisoClusters[clustername]["center"];
                                                engine.voisoKeyUser.text = engine.voisoClusters[clustername]["user"];
                                              }else if(engine.allClusters[clustername] == "CP"){}
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const EditVoisoCluster()),
                                              );
                                            },
                                            icon: const Icon(Icons.edit_rounded)),
                                        IconButton(
                                            onPressed: () {
                                              engine.voisoClusters.remove(clustername);
                                              engine.updateVoisoData();
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.delete_rounded)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList()),
                    ),
                  )
                ],
              ),
            );
          });
        }),
      );
    });
  }
}

class EditVoisoCluster extends StatefulWidget {
  const EditVoisoCluster({super.key});
  @override
  EditVoisoClusterState createState() => EditVoisoClusterState();
}

class EditVoisoClusterState extends State<EditVoisoCluster> {
  @override
  void initState() {
    super.initState();
  }

  bool ccKeyCorrect = false;
  bool uKeyCorrect = false;
  bool clusterCorrect = false;
  bool ccKeyLoading = false;
  bool uKeyLoading = false;
  bool clusterLoading = false;
  String selector = "Voiso";
  bool voisoChecked = false;
  @override
  Widget build(BuildContext topContext) {
    ServicesBinding.instance.keyboard.addHandler((KeyEvent event) {
      if (event is KeyUpEvent && event.logicalKey.keyLabel == "Escape") {
        Navigator.pop(this.context);
        return true;
      }
      return false;
    });
    final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        double scaffoldHeight = constraints.maxHeight;
        double scaffoldWidth = constraints.maxWidth;
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
            if (!voisoChecked && engine.voisoCluster.text.isNotEmpty && engine.voisoKeyUser.text.isNotEmpty && engine.voisoKeyCenter.text.isNotEmpty) {
              Future.delayed(Duration.zero, () {
                clusterLoading = true;
                engine.checkVoisoCluster(engine.voisoCluster.text).then((value) {
                  setState(() {
                    clusterLoading = false;
                    clusterCorrect = value;
                  });
                });
                uKeyLoading = true;
                engine.checkVoisoUKey(engine.voisoCluster.text, engine.voisoKeyUser.text).then((value) {
                  setState(() {
                    uKeyLoading = false;
                    uKeyCorrect = value;
                  });
                });
                ccKeyLoading = true;
                engine.checkVoisoCCKey(engine.voisoCluster.text, engine.voisoKeyCenter.text).then((value) {
                  setState(() {
                    ccKeyLoading = false;
                    ccKeyCorrect = value;
                  });
                });
                voisoChecked = true;
              });
            }
            return Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 300,
                        child: Padding(
                          padding: EdgeInsets.all((engine.voisoClusters.containsKey(engine.voisoCluster.text))?0:15),
                          child: (engine.voisoClusters.containsKey(engine.voisoCluster.text) || engine.availCPs.containsKey(engine.cpCluster.text))?null:SegmentedButton(
                            segments: const [
                              ButtonSegment(
                                value: "Voiso",
                                label: Text('Voiso'),
                              ),
                              ButtonSegment(
                                value: "CP",
                                label: Text('Commpeak'),
                              ),
                            ],
                            selected: {selector},
                            style: ButtonStyle(
                            ),
                            onSelectionChanged: (select) {
                              setState(() {
                                selector = select.elementAt(0);
                                print(select);
                              });
                            },
                          ),
                        ),
                      ),
                      selector == "Voiso"?Card(
                        elevation: 2,
                        child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${engine.voisoClusters.containsKey(engine.voisoCluster.text) ? "Edit" : "Add"} Voiso Cluster",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        Text(
                                          "${engine.voisoClusters.containsKey(engine.voisoCluster.text) ? "Edit" : "Enter"} credentials for Voiso cluster",
                                        )
                                      ],
                                    ),
                                    Container(
                                      width: 200,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                                        child: TextField(
                                          controller: engine.voisoCluster,
                                          onChanged: (value) {
                                            engine.checkVoisoCluster(engine.voisoCluster.text).then((value) {
                                              setState(() {
                                                clusterCorrect = value;
                                              });
                                            });
                                          },
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.dashboard),
                                            suffixIcon: clusterLoading
                                                ? const Icon(Icons.cloud_sync_outlined)
                                                : clusterCorrect
                                                ? const Icon(Icons.done_rounded)
                                                : const Icon(Icons.error_outline_rounded),
                                            labelText: 'Cluster ID',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      child: TextField(
                                        controller: engine.voisoKeyUser,
                                        onChanged: (value) {
                                          engine.checkVoisoUKey(engine.voisoCluster.text, engine.voisoKeyUser.text).then((value) {
                                            setState(() {
                                              uKeyCorrect = value;
                                            });
                                          });
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.person_rounded),
                                          suffixIcon: uKeyLoading
                                              ? const Icon(Icons.cloud_sync_outlined)
                                              : uKeyCorrect
                                              ? const Icon(Icons.done_rounded)
                                              : const Icon(Icons.error_outline_rounded),
                                          labelText: 'User Key',
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      child: TextField(
                                        controller: engine.voisoKeyCenter,
                                        onChanged: (value) {
                                          engine.checkVoisoCCKey(engine.voisoCluster.text, engine.voisoKeyCenter.text).then((value) {
                                            setState(() {
                                              ccKeyCorrect = value;
                                            });
                                          });
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.corporate_fare_rounded),
                                          suffixIcon: ccKeyLoading
                                              ? const Icon(Icons.cloud_sync_outlined)
                                              : ccKeyCorrect
                                              ? const Icon(Icons.done_rounded)
                                              : const Icon(Icons.error_outline_rounded),
                                          labelText: 'Center Key',
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )),
                      )
                      : Card(
                        elevation: 2,
                        child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${engine.availCPs.containsKey(engine.cpCluster.text) ? "Edit" : "Add"} CP Cluster",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        Text(
                                          "${engine.availCPs.containsKey(engine.cpCluster.text) ? "Edit" : "Enter"} credentials for Commpeak cluster",
                                        )
                                      ],
                                    ),
                                    Container(
                                      width: 200,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                                        child: TextField(
                                          controller: engine.cpCluster,
                                          onChanged: (value) {

                                          },
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.dashboard),
                                            suffixIcon: clusterLoading
                                                ? const Icon(Icons.cloud_sync_outlined)
                                                : clusterCorrect
                                                ? const Icon(Icons.done_rounded)
                                                : const Icon(Icons.error_outline_rounded),
                                            labelText: 'Cluster ID',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      child: TextField(
                                        controller: engine.voisoKeyCenter,
                                        onChanged: (value) {
                                          engine.checkVoisoCCKey(engine.voisoCluster.text, engine.voisoKeyCenter.text).then((value) {
                                            setState(() {
                                              ccKeyCorrect = value;
                                            });
                                          });
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.corporate_fare_rounded),
                                          suffixIcon: ccKeyLoading
                                              ? const Icon(Icons.cloud_sync_outlined)
                                              : ccKeyCorrect
                                              ? const Icon(Icons.done_rounded)
                                              : const Icon(Icons.error_outline_rounded),
                                          labelText: 'Key',
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      engine.voisoClusters.containsKey(engine.voisoCluster.text)
                          ? Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(right: 10),
                                              child: Icon(Icons.dangerous_rounded),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Forget this cluster",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        FilledButton(
                                            onPressed: () {
                                              engine.voisoClusters.remove(engine.voisoCluster.text);
                                              engine.updateVoisoData();
                                              Navigator.pop(this.context);
                                            },
                                            style:
                                                ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)),
                                            child: Text(
                                              'Forget',
                                              style: TextStyle(color: Theme.of(context).colorScheme.background),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilledButton(
                                onPressed: () {
                                  Navigator.pop(topContext);
                                },
                                style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Theme.of(context).colorScheme.background),
                                )),
                            FilledButton(
                                onPressed: (ccKeyCorrect && uKeyCorrect && clusterCorrect)
                                    ? () {
                                        engine.saveVoisoKeys(engine.voisoCluster.text, engine.voisoKeyUser.text, engine.voisoKeyCenter.text);
                                        Navigator.pop(topContext);
                                      }
                                    : null,
                                child: const Text("Save cluster")),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class AgentsPage extends StatefulWidget {
  const AgentsPage({super.key});
  @override
  AgentsPageState createState() => AgentsPageState();
}

class AgentsPageState extends State<AgentsPage> {
  @override
  void initState() {
    super.initState();
  }

  bool newScreen = true;
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
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add_rounded),
                onPressed: () {
                  launchUrlString("https://${engine.activeVoisoClusters.elementAt(0)}.voiso.com/users/new");
                },
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DropdownMenu(
                        controller: engine.userDropController,
                        initialSelection: engine.activeVoisoClusters.toList()[0],
                        onSelected: (cluster) {
                          engine.activeVoisoClusters.clear();
                          engine.activeVoisoClusters.add(cluster);
                        },
                        enableSearch: true,
                        label: const Text("Voiso Cluster"),
                        leadingIcon: const Icon(Icons.sip_rounded),
                        dropdownMenuEntries: engine.voisoClusters.keys.toList().map((cluster) {
                          return DropdownMenuEntry(value: cluster, label: cluster);
                        }).toList(),
                      ),
                      Container(
                        width: scaffoldWidth - 175,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: TextField(
                            controller: engine.voisoSearch,
                            onChanged: (value) {
                              engine.filterVoisoUsers();
                            },
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search_rounded),
                              labelText: 'Search agents',
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: engine.filteredVoisoAgents.isEmpty ? null : scaffoldHeight - 66,
                    child: engine.filteredVoisoAgents.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: engine.filteredVoisoAgents.map((agent) {
                                  return Card(
                                    elevation: 2,
                                    clipBehavior: Clip.hardEdge,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                        child: Stack(
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      agent["name"],
                                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                    ),
                                                    Wrap(
                                                      direction: Axis.horizontal,
                                                      spacing: -5,
                                                      runSpacing: 5,
                                                      children: agent["agent_in_teams"]
                                                          .split(", ")
                                                          .map((teamid) {
                                                            if (teamid == "") {
                                                              return Container();
                                                            }
                                                            return Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: Chip(
                                                                labelPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: -1),
                                                                padding: const EdgeInsets.all(0),
                                                                backgroundColor: Colors.transparent,
                                                                side: const BorderSide(color: Colors.transparent),
                                                                elevation: 5,
                                                                label: Text(
                                                                  engine.getTeamName(teamid),
                                                                  style: const TextStyle(
                                                                    height: 0.5,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                          .toList()
                                                          .cast<Widget>(),
                                                    )
                                                  ],
                                                ),
                                                Text(
                                                    "${agent["extension"] == null ? "" : "${agent["extension"]} • "}${agent["sag"] == "Supervisor" ? "Supervisor in ${agent["supervisor_in_teams"].split(", ").length} team${agent["supervisor_in_teams"].split(", ").length % 10 == 1 ? "" : "s"}" : agent["sag"]} • ${agent["email"]} • ${agent["timezone"]}")
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 3),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        engine.voisoUserEmail.text = agent["email"];
                                                        engine.voisoUserName.text = agent["name"];
                                                        engine.voisoUserExtension.text = agent["extension"] == null ? "" : agent["extension"];
                                                        engine.voisoUserPassword.text = "example password";
                                                        engine.voisoUser = agent;
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => const NewAgentPage()),
                                                        );
                                                      },
                                                      icon: const Icon(Icons.remove_red_eye_rounded)),
                                                  IconButton(
                                                      onPressed: () {
                                                        launchUrlString(
                                                            "https://${engine.activeVoisoClusters.elementAt(0)}.voiso.com/users/${agent["id"]}/edit");
                                                      },
                                                      icon: const Icon(Icons.open_in_new_rounded))
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                  );
                                }).toList()),
                          )
                        : !engine.loading
                            ? const Card(
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.warning_rounded)),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "No users found.",
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    color: Theme.of(context).colorScheme.primary,
                                  )
                                ],
                              ),
                  )
                ],
              ),
            );
          });
        }),
      );
    });
  }
}

class NewAgentPage extends StatefulWidget {
  const NewAgentPage({super.key});
  @override
  NewAgentPageState createState() => NewAgentPageState();
}

class NewAgentPageState extends State<NewAgentPage> {
  @override
  void initState() {
    super.initState();
  }

  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext topContext) {
    final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyUpEvent && event.logicalKey.keyLabel == "Escape") {
          Future.delayed(Duration.zero, () {
            Navigator.pop(this.context);
          });
        }
      },
      child: DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
        return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          double scaffoldHeight = constraints.maxHeight;
          double scaffoldWidth = constraints.maxWidth;
          bool album = false;
          print(scaffoldWidth);
          if (scaffoldWidth > 1250) {
            album = true;
          } else {
            album = false;
          }
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
              return Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: scaffoldWidth,
                      height: scaffoldHeight - 62,
                      child: SingleChildScrollView(
                        child: album
                            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        "Edit agent ${engine.voisoUser["id"]}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: TextField(
                                        controller: engine.voisoUserName,
                                        onChanged: null,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.person_rounded),
                                          labelText: 'Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: TextField(
                                        controller: engine.voisoUserEmail,
                                        onChanged: null,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.alternate_email_rounded),
                                          labelText: 'Email',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: TextField(
                                        controller: engine.voisoUserPassword,
                                        onChanged: null,
                                        readOnly: true,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.password_rounded),
                                          labelText: 'Password',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: album ? scaffoldWidth / 2 - 10 : scaffoldWidth,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: SegmentedButton(
                                              segments: [
                                                const ButtonSegment(value: "Admin", enabled: true, label: Text("Admin")),
                                                const ButtonSegment(value: "Agent", enabled: true, label: Text("Agent")),
                                                const ButtonSegment(value: "Analyst", enabled: true, label: Text("Analyst")),
                                                const ButtonSegment(value: "Hardware phone", enabled: true, label: Text("Hardware phone")),
                                                const ButtonSegment(value: "Supervisor", enabled: true, label: Text("Supervisor")),
                                              ],
                                              selected: {engine.voisoUser["sag"]},
                                              multiSelectionEnabled: false,
                                              emptySelectionAllowed: false,
                                              showSelectedIcon: false,
                                              style: SegmentedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7.6),
                                              ),
                                              onSelectionChanged: (va) {},
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: album ? scaffoldWidth / 2 - 62 : scaffoldWidth,
                                      child: Row(
                                        children: [
                                          Container(
                                              width: album ? scaffoldWidth / 4 - 10 : scaffoldWidth,
                                              child: Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: TextField(
                                                  controller: engine.voisoUserExtension,
                                                  onChanged: null,
                                                  readOnly: true,
                                                  decoration: const InputDecoration(
                                                    prefixIcon: Icon(Icons.numbers_rounded),
                                                    labelText: 'Extension',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              )),
                                          Container(
                                            width: album ? scaffoldWidth / 4 - 62 : scaffoldWidth,
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: DropdownMenu(
                                                controller: TextEditingController(text: engine.voisoUser["timezone"]),
                                                width: scaffoldWidth / (album ? 4 : 2),
                                                initialSelection: engine.voisoUser["timezone"],
                                                onSelected: null,
                                                enableSearch: true,
                                                label: const Text("Timezone"),
                                                leadingIcon: const Icon(Icons.travel_explore_rounded),
                                                dropdownMenuEntries: [
                                                  DropdownMenuEntry(value: engine.voisoUser["timezone"], label: engine.voisoUser["timezone"]),
                                                  const DropdownMenuEntry(value: "Neverland", label: "Neverland")
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                                const VerticalDivider(thickness: 1, width: 1),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Card(
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
                                                  "Agent in",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Container(
                                                    width: scaffoldWidth / 2 - 63,
                                                    child: Wrap(
                                                      direction: Axis.horizontal,
                                                      spacing: -5,
                                                      runSpacing: 5,
                                                      children: engine.voisoUser["agent_in_teams"]
                                                          .split(", ")
                                                          .map((teamid) {
                                                            if (teamid == "") {
                                                              return Container();
                                                            }
                                                            return Padding(
                                                              padding: const EdgeInsets.only(right: 10),
                                                              child: Chip(
                                                                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                                padding: const EdgeInsets.all(6),
                                                                backgroundColor: Colors.transparent,
                                                                side: const BorderSide(color: Colors.transparent),
                                                                elevation: 5,
                                                                label: Text(engine.getTeamName(teamid)),
                                                              ),
                                                            );
                                                          })
                                                          .toList()
                                                          .cast<Widget>(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Icon(Icons.arrow_forward_ios_rounded)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
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
                                                  "Supervisor in",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Container(
                                                    width: scaffoldWidth / 2 - 63,
                                                    child: Wrap(
                                                      direction: Axis.horizontal,
                                                      spacing: -5,
                                                      runSpacing: 5,
                                                      children: engine.voisoUser["supervisor_in_teams"]
                                                          .split(", ")
                                                          .map((teamid) {
                                                            if (teamid == "") {
                                                              return Container();
                                                            }
                                                            return Padding(
                                                              padding: const EdgeInsets.only(right: 10),
                                                              child: Chip(
                                                                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                                padding: const EdgeInsets.all(6),
                                                                backgroundColor: Colors.transparent,
                                                                side: const BorderSide(color: Colors.transparent),
                                                                elevation: 5,
                                                                label: Text(engine.getTeamName(teamid)),
                                                              ),
                                                            );
                                                          })
                                                          .toList()
                                                          .cast<Widget>(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Icon(Icons.arrow_forward_ios_rounded)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
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
                                                  "Skills",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                Text("${engine.voisoUser["assigned_skills"].length} asigned"),
                                              ],
                                            ),
                                            const Icon(Icons.arrow_forward_ios_rounded)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
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
                                                  "Queues",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                Text(engine.voisoUser["assigned_queues"]),
                                              ],
                                            ),
                                            const Icon(Icons.arrow_forward_ios_rounded)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ))
                              ])
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "Edit agent",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: TextField(
                                      controller: engine.voisoUserName,
                                      onChanged: null,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.person_rounded),
                                        labelText: 'Name',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: TextField(
                                      controller: engine.voisoUserEmail,
                                      onChanged: null,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.alternate_email_rounded),
                                        labelText: 'Email',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: TextField(
                                      controller: engine.voisoUserPassword,
                                      onChanged: null,
                                      readOnly: true,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.password_rounded),
                                        labelText: 'Password',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: SegmentedButton(
                                          segments: [
                                            const ButtonSegment(value: "Admin", enabled: true, label: Text("Admin")),
                                            const ButtonSegment(value: "Agent", enabled: true, label: Text("Agent")),
                                            const ButtonSegment(value: "Analyst", enabled: true, label: Text("Analyst")),
                                            const ButtonSegment(value: "Hardware phone", enabled: true, label: Text("Hardware phone")),
                                            const ButtonSegment(value: "Supervisor", enabled: true, label: Text("Supervisor")),
                                          ],
                                          selected: {engine.voisoUser["sag"]},
                                          multiSelectionEnabled: false,
                                          emptySelectionAllowed: false,
                                          showSelectedIcon: false,
                                          style: SegmentedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7.6),
                                          ),
                                          onSelectionChanged: (va) {},
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: TextField(
                                          controller: engine.voisoUserExtension,
                                          onChanged: null,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            prefixIcon: Icon(Icons.numbers_rounded),
                                            labelText: 'Extension',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      )),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: DropdownMenu(
                                            controller: TextEditingController(text: engine.voisoUser["timezone"]),
                                            width: scaffoldWidth / 2 - 10,
                                            initialSelection: engine.voisoUser["timezone"],
                                            onSelected: null,
                                            enableSearch: true,
                                            label: const Text("Timezone"),
                                            leadingIcon: const Icon(Icons.travel_explore_rounded),
                                            dropdownMenuEntries: [
                                              DropdownMenuEntry(value: engine.voisoUser["timezone"], label: engine.voisoUser["timezone"]),
                                              const DropdownMenuEntry(value: "Neverland", label: "Neverland")
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Card(
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
                                                "Agent in",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Container(
                                                  width: scaffoldWidth - 62,
                                                  child: Wrap(
                                                    direction: Axis.horizontal,
                                                    spacing: -5,
                                                    runSpacing: 5,
                                                    children: engine.voisoUser["agent_in_teams"]
                                                        .split(", ")
                                                        .map((teamid) {
                                                          if (teamid == "") {
                                                            return Container();
                                                          }
                                                          return Padding(
                                                            padding: const EdgeInsets.only(right: 10),
                                                            child: Chip(
                                                              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                              padding: const EdgeInsets.all(6),
                                                              backgroundColor: Colors.transparent,
                                                              side: const BorderSide(color: Colors.transparent),
                                                              elevation: 5,
                                                              label: Text(engine.getTeamName(teamid)),
                                                            ),
                                                          );
                                                        })
                                                        .toList()
                                                        .cast<Widget>(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Icon(Icons.arrow_forward_ios_rounded)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
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
                                                "Supervisor in",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Container(
                                                  width: scaffoldWidth - 62,
                                                  child: Wrap(
                                                    direction: Axis.horizontal,
                                                    spacing: -5,
                                                    runSpacing: 5,
                                                    children: engine.voisoUser["supervisor_in_teams"]
                                                        .split(", ")
                                                        .map((teamid) {
                                                          if (teamid == "") {
                                                            return Container();
                                                          }
                                                          return Padding(
                                                            padding: const EdgeInsets.only(right: 10),
                                                            child: Chip(
                                                              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                              padding: const EdgeInsets.all(6),
                                                              backgroundColor: Colors.transparent,
                                                              side: const BorderSide(color: Colors.transparent),
                                                              elevation: 5,
                                                              label: Text(engine.getTeamName(teamid)),
                                                            ),
                                                          );
                                                        })
                                                        .toList()
                                                        .cast<Widget>(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Icon(Icons.arrow_forward_ios_rounded)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
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
                                                "Skills",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              Text("${engine.voisoUser["assigned_skills"].length} asigned"),
                                            ],
                                          ),
                                          const Icon(Icons.arrow_forward_ios_rounded)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
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
                                                "Queues",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              Text(engine.voisoUser["assigned_queues"]),
                                            ],
                                          ),
                                          const Icon(Icons.arrow_forward_ios_rounded)
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilledButton(
                              onPressed: () {
                                Navigator.pop(topContext);
                              },
                              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Theme.of(context).colorScheme.background),
                              )),
                          Text(
                            "Editing agents is not available yet",
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                          const FilledButton(onPressed: null, child: Text("Save")),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
      }),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

class CDRPage extends StatefulWidget {
  const CDRPage({super.key});
  @override
  CDRPageState createState() => CDRPageState();
}

class HoverBuilder extends StatefulWidget {
  const HoverBuilder({
    required this.builder,
    Key? key,
  }) : super(key: key);

  final Widget Function(bool isHovered) builder;

  @override
  _HoverBuilderState createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) => _onHoverChanged(enabled: true),
      onExit: (PointerExitEvent event) => _onHoverChanged(enabled: false),
      child: widget.builder(_isHovered),
    );
  }

  void _onHoverChanged({required bool enabled}) {
    setState(() {
      _isHovered = enabled;
    });
  }
}

class CDRPageState extends State<CDRPage> {
  @override
  void initState() {
    super.initState();
  }

  bool isShift = false;
  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext topContext) {
    final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        double scaffoldHeight = constraints.maxHeight;
        double scaffoldWidth = constraints.maxWidth;
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
            return KeyboardListener(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: (event) {
                if (event is KeyUpEvent && event.logicalKey.keyLabel == "Shift Left") {
                  isShift = false;
                }
                if (event is KeyDownEvent && event.logicalKey.keyLabel == "Shift Left") {
                  isShift = true;
                }
                if (event is KeyUpEvent && event.logicalKey.keyLabel == "Enter"&& !isShift) {
                  if(engine.cdrSearch.text.isNotEmpty){engine.getStupidCDR();}
                }
              },
              child: Scaffold(
                floatingActionButton: (!(engine.dropController.text.contains("CP: ") || engine.dropController.text.contains("Voiso: ")) && engine.allClusters.containsKey(engine.dropController.text.split(": ")[1])&&(engine.cpCDR[engine.dropController.text.split(": ")[1]].isEmpty || engine.voisoCDR[engine.dropController.text.split(": ")[1]]))
                    ? null
                    : FloatingActionButton(

                  onPressed: engine.dropController.text.split(": ")[0] == "CP"
                      ? !engine.cpCDR.containsKey(engine.dropController.text.split(": ")[1])?null: () async {
                    String formatCopy = "Number	First call / Date	Sum calls / Agent	Office / Team	Call duration	Answered?\n";
                    for (int n = 0; n < engine.cpCDR[engine.dropController.text.split(": ")[1]].length; n++) {
                      String number = engine.cpCDR[engine.dropController.text.split(": ")[1]].keys.toList()[n];
                      if (engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length == 0) {
                        formatCopy = "$formatCopy$number";
                        formatCopy = "$formatCopy		0	\n";
                      } else {
                        formatCopy = "$formatCopy$number";
                        formatCopy =
                        "$formatCopy	${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["call_start"]).toIso8601String().split("T")[0].split("-")[2]}.${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["call_start"]).toIso8601String().split("T")[0].split("-")[1]}.${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["call_start"]).toIso8601String().split("T")[0].split("-")[0]}";
                        formatCopy = "$formatCopy	${engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length}";
                        formatCopy = "$formatCopy	${engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["desks"]}";
                        formatCopy = "$formatCopy\n";
                        for (int e = 0; e < engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length; e++) {
                          formatCopy =
                          "$formatCopy	${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][e]["call_start"]).toIso8601String().split("T")[0].split("-")[2]}.${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][e]["call_start"]).toIso8601String().split("T")[0].split("-")[1]}.${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][e]["call_start"]).toIso8601String().split("T")[0].split("-")[0]}";
                          formatCopy = "$formatCopy	${engine.cpCDR[engine.dropController.text.split(": ")[1]][number][e]["agent_name"]}";
                          formatCopy = "$formatCopy	${engine.cpCDR[engine.dropController.text.split(": ")[1]][number][e]["desks"]}";
                          formatCopy = "$formatCopy	${engine.cpCDR[engine.dropController.text.split(": ")[1]][number][e]["duration"]}";
                          formatCopy =
                          "$formatCopy	${engine.cpCDR[engine.dropController.text.split(": ")[1]][number][e]["hangup_cause"][0].toUpperCase()}${engine.cpCDR[engine.dropController.text.split(": ")[1]][number][e]["hangup_cause"].substring(1).toLowerCase()}";
                          formatCopy = "$formatCopy\n";
                        }
                      }
                    }
                    await Clipboard.setData(ClipboardData(text: formatCopy));
                  }
                      : !engine.voisoCDR.containsKey(engine.dropController.text.split(": ")[1])?null:() async {
                    String formatCopy = "Number	First call / Date	Sum calls / Agent	Office / Team	Call duration	Status\n";
                    for (int n = 0; n < engine.voisoCDR[engine.dropController.text.split(": ")[1]].length; n++) {
                      String number = engine.voisoCDR[engine.dropController.text.split(": ")[1]].keys.toList()[n];
                      if (engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].isEmpty) {
                        formatCopy = "$formatCopy$number";
                        formatCopy = "$formatCopy		0	\n";
                      } else {
                        formatCopy = "$formatCopy$number";
                        formatCopy =
                        "$formatCopy	${DateTime.parse(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["timestamp"]).toIso8601String().split("T")[0].split("-")[2]}.${DateTime.parse(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["timestamp"]).toIso8601String().split("T")[0].split("-")[1]}.${DateTime.parse(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["timestamp"]).toIso8601String().split("T")[0].split("-")[0]}";
                        formatCopy = "$formatCopy	${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length}";
                        formatCopy =
                        "$formatCopy	${engine.getTeamName(engine.getTeamByUserId(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["agent_id"]))}";
                        formatCopy = "$formatCopy\n";
                        for (int e = 0; e < engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length; e++) {
                          if (!(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["type"] == "outbound_sms")) {
                            formatCopy =
                            "$formatCopy	${DateTime.parse(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["timestamp"]).toIso8601String().split("T")[0].split("-")[2]}.${DateTime.parse(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["timestamp"]).toIso8601String().split("T")[0].split("-")[1]}.${DateTime.parse(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["timestamp"]).toIso8601String().split("T")[0].split("-")[0]}";
                            formatCopy = "$formatCopy	${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["agent"]}";
                            formatCopy =
                            "$formatCopy	${engine.getTeamName(engine.getTeamByUserId(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["agent_id"]))}";
                            formatCopy = "$formatCopy	${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["duration"]}";
                            formatCopy =
                            "$formatCopy	${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["disposition"][0].toUpperCase()}${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["disposition"].substring(1).toLowerCase().split("_")[0]}${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["disposition"].split("_").length > 1 ? " ${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["disposition"].split("_")[1][0].toUpperCase()}${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][e]["disposition"].split("_")[1].substring(1).toLowerCase().split("_")[0]}" : ""}";
                            formatCopy = "$formatCopy\n";
                          }
                        }
                      }
                    }
                    await Clipboard.setData(ClipboardData(text: formatCopy));
                  },
                  child: engine.voisoCDR.containsKey(engine.dropController.text.split(": ")[1]) || engine.cpCDR.containsKey(engine.dropController.text.split(": ")[1])? const Icon(Icons.copy_rounded):const Icon(Icons.error_outline_rounded),
                ),
                body: Column(
                  children: [
                    scaffoldWidth > 800?Container():Row(
                      children: [
                        Container(
                          width: (scaffoldWidth/2),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextField(
                              controller: engine.cdrFromSearch,
                              keyboardType: TextInputType.multiline,
                              expands: false,
                              minLines: null,
                              maxLines: null,
                              decoration: const InputDecoration(
                                constraints: BoxConstraints(maxHeight: 55),
                                labelText: 'Numbers From',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: (scaffoldWidth/2),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextField(
                              controller: engine.cdrSearch,
                              keyboardType: TextInputType.multiline,
                              expands: false,
                              minLines: null,
                              maxLines: null,
                              decoration: const InputDecoration(
                                constraints: BoxConstraints(maxHeight: 55),
                                labelText: 'Numbers To',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: DropdownMenu(
                            controller: engine.dropController,
                            initialSelection: "${engine.allClusters[engine.allClusters.keys.toList()[0]]}: ${engine.allClusters.keys.toList()[0]}",
                            onSelected: (cluster) {
                              print(engine.dropController.text.split(": ")[1]);
                            },
                            enableSearch: true,
                            label: const Text("Cluster"),
                            width: 180,
                            dropdownMenuEntries: engine.allClusters.keys.toList().map((cluster) {
                              return DropdownMenuEntry(value: cluster, label: "${engine.allClusters[cluster]}: $cluster");
                            }).toList(),
                          ),
                        ),
                        Container(
                          width: 125,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextField(
                              controller: TextEditingController(text: engine.dateCDR.toIso8601String().split("T")[0]),
                              onTap: () {
                                showDatePicker(
                                    context: context,
                                    initialDate: engine.dateCDR,
                                    firstDate: DateTime(2021, 9, 11),
                                    lastDate: DateTime.now())
                                    .then((value) {
                                  if (!(value == null)) {
                                    setState(() {
                                      engine.dateCDR = value;
                                    });
                                  }
                                });
                              },
                              readOnly: true,
                              onChanged: null,
                              showCursor: false,
                              decoration: const InputDecoration(
                                labelText: 'Period',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                              ),
                            ),
                          ),
                        ),
                        scaffoldWidth < 800?Container():Container(
                          width: (scaffoldWidth - 625),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextField(
                              controller: engine.cdrSearch,
                              keyboardType: TextInputType.multiline,
                              expands: false,
                              minLines: null,
                              maxLines: null,
                              onChanged: (v){
                                setState(() {

                                });
                              },
                              decoration: const InputDecoration(
                                constraints: BoxConstraints(maxHeight: 55),
                                labelText: 'Numbers',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 180,
                          child: CheckboxListTile(
                            title: const Text('Only answered'),
                            contentPadding: const EdgeInsets.all(10),
                            value: engine.answCDR,
                            onChanged: (value) {
                              engine.answCDR = value!;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            width: 100,
                            child: FilledButton(
                                onPressed: (engine.cdrSearch.text.isEmpty && engine.cdrFromSearch.text.isEmpty)?null:() {
                                  engine.getStupidCDR();
                                },
                                child: const Text("Send")),
                          ),
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: engine.progressCDR,
                      backgroundColor: Colors.transparent,
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(2), topRight: Radius.circular(2)),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Container(
                      height: scaffoldWidth > 800?scaffoldHeight - 72:scaffoldHeight - 144,
                      child: SingleChildScrollView(
                        child: ((engine.dropController.text.contains("CP: ") || engine.dropController.text.contains("Voiso: ")) && engine.allClusters.containsKey(engine.dropController.text.split(": ")[1]))
                            ?engine.dropController.text.split(": ")[0] == "CP"
                            ? engine.cpCDR[engine.dropController.text.split(": ")[1]].isEmpty
                            ? Container()
                            : Column(
                          children: engine.cpCDR[engine.dropController.text.split(": ")[1]].keys
                              .toList()
                              .map((number) {
                            if (engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length == 0) {
                              return Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${number.toString()} • No calls",
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ExpansionTileTheme(
                                data: const ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15)),
                                child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${number.toString()} • ${engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length} call${engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length == 11 ? "s" : engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length % 10 == 1 ? "" : "s"}",
                                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                          ),
                                          Text(
                                              "First call: ${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["call_start"]).toIso8601String().split("T")[0].split("-")[2]}.${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["call_start"]).toIso8601String().split("T")[0].split("-")[1]}.${DateTime.parse(engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["call_start"]).toIso8601String().split("T")[0].split("-")[0]} by ${engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["agent_name"]} (${engine.cpCDR[engine.dropController.text.split(": ")[1]][number][engine.cpCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["desks"]})")
                                        ],
                                      ),
                                      children: engine.cpCDR[engine.dropController.text.split(": ")[1]][number]
                                          .map((entry) {
                                        DateTime time = DateTime.parse(entry["call_start"]);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${entry["agent_name"]} (${entry["desks"]})",
                                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          "${time.toIso8601String().split("T")[0].split("-")[2]}.${time.toIso8601String().split("T")[0].split("-")[1]}.${time.toIso8601String().split("T")[0].split("-")[0]}"),
                                                      Text(" ${time.toIso8601String().split("T")[1].split(".000")[0]}"),
                                                      Text(" (${time.timeAgo(numericDates: false)})"),
                                                      const Text(" • "),
                                                      Text("${entry["duration"]}"),
                                                      const Text(" • "),
                                                      Text(
                                                          "${entry["hangup_cause"][0].toUpperCase()}${entry["hangup_cause"].substring(1).toLowerCase()}"),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        launchUrlString(entry["recordingUrl"]);
                                                      },
                                                      icon: const Icon(Icons.download_rounded))
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      })
                                          .toList()
                                          .cast<Widget>(),
                                    )));
                          })
                              .toList()
                              .cast<Widget>(),
                        )
                            : engine.voisoCDR[engine.dropController.text.split(": ")[1]].isEmpty
                            ? Container()
                            : Column(
                          children: engine.voisoCDR[engine.dropController.text.split(": ")[1]].keys
                              .toList()
                              .map((number) {
                            if (engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length == 0) {
                              return Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${number.toString()} • No calls",
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            }
                            DateTime firstCallDate = DateTime.parse(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["timestamp"]);
                            return ExpansionTileTheme(
                                data: const ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15)),
                                child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${number.toString()=="0"?"Calls from ${engine.getVoisoNumberInfo(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][0]["from"])["cid_groups"][0]["name"]}":number.toString()} • ${number.toString()=="0"?"${engine.numbersFromAmountCalls[engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][0]["from"]]} call${engine.numbersFromAmountCalls[engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][0]["from"]] == 11 ? "s" : engine.numbersFromAmountCalls[engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][0]["from"]] % 10 == 1 ? "" : "s"}":"${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length} call${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length == 11 ? "s" : engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length % 10 == 1 ? "" : "s"}"}",
                                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                          ),
                                          Text(
                                              "First call: ${firstCallDate.toIso8601String().split("T")[0].split("-")[2]}.${firstCallDate.toIso8601String().split("T")[0].split("-")[1]}.${firstCallDate.toIso8601String().split("T")[0].split("-")[0]} by ${engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["agent"] == null?"[No agent lol]":engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["agent"]} (${engine.getTeamName(engine.getTeamByUserId(engine.voisoCDR[engine.dropController.text.split(": ")[1]][number][engine.voisoCDR[engine.dropController.text.split(": ")[1]][number].length - 1]["agent_id"]))})")
                                        ],
                                      ),
                                      children: engine.voisoCDR[engine.dropController.text.split(": ")[1]][number]
                                          .map((entry) {
                                        if (entry["type"] == "outbound_sms") {
                                          return Container();
                                        } else {
                                          DateTime time = DateTime.parse(entry["timestamp"]).toLocal();
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "${entry["agent"] == null?"[No agent lol]":entry["agent"]} (${engine.getTeamName(engine.getTeamByUserId(entry["agent_id"]))}) • ${entry["disposition"][0].toUpperCase()}${entry["disposition"].substring(1).toLowerCase().split("_")[0]}${entry["disposition"].split("_").length > 1 ? " ${entry["disposition"].split("_")[1][0].toUpperCase()}${entry["disposition"].split("_")[1].substring(1).toLowerCase().split("_")[0]}" : ""} • ${entry["duration"]}",
                                                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                            "${time.toIso8601String().split("T")[0].split("-")[2]}.${time.toIso8601String().split("T")[0].split("-")[1]}.${time.toIso8601String().split("T")[0].split("-")[0]}"),
                                                        Text(" ${time.toIso8601String().split("T")[1].split(".000")[0]}"),
                                                        Text(" (${time.timeAgo(numericDates: false)})"),
                                                        const Text(" • "),
                                                        HoverBuilder(
                                                          builder: (isHovered) {
                                                            if(isHovered){
                                                              if(engine.getVoisoNumberInfo(entry["from"]).isEmpty){
                                                                return Text(
                                                                  "[Removed number]",
                                                                  style: TextStyle(
                                                                      color: Theme.of(context).colorScheme.error,
                                                                      fontWeight: FontWeight.bold
                                                                  ),
                                                                );
                                                              }
                                                              return GestureDetector(
                                                                onTap: (){launchUrlString("https://${engine.activeVoisoClusters.toList()[0]}.voiso.com/cid_groups/${engine.getVoisoNumberInfo(entry["from"])["cid_groups"][0]["id"]}/edit");},
                                                                child: Container(
                                                                  constraints: BoxConstraints(
                                                                    maxWidth: scaffoldWidth-450
                                                                  ),
                                                                  child: Text(
                                                                    engine.getVoisoNumberInfo(entry["from"])["cid_groups"][0]["name"],
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context).colorScheme.primary,
                                                                        fontWeight: FontWeight.bold
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }else{
                                                              return Text("${entry["from"]} > ${entry["to"]}");
                                                            }
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () async {
                                                          await Clipboard.setData(ClipboardData(
                                                              text:
                                                              "https://${engine.activeVoisoClusters.toList()[0]}.voiso.com/cdr/${entry["uuid"]}"));
                                                        },
                                                        icon: const Icon(Icons.copy_rounded)),
                                                    IconButton(
                                                        onPressed: () {
                                                          launchUrlString("https://${engine.activeVoisoClusters.toList()[0]}.voiso.com/cdr/${entry["uuid"]}");
                                                        },
                                                        icon: const Icon(Icons.open_in_new_rounded)),
                                                    IconButton(
                                                        onPressed: () {
                                                          launchUrlString(
                                                              "https://${engine.activeVoisoClusters.toList()[0]}.voiso.com/recordings/${entry["uuid"]}.mp3?mode=download");
                                                        },
                                                        icon: const Icon(Icons.download_rounded))
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                      })
                                          .toList()
                                          .cast<Widget>(),
                                    )));
                          })
                              .toList()
                              .cast<Widget>(),
                        )
                            : Container(),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        );
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
