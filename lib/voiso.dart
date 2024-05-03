import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
                     height: engine.voisoClusters.isEmpty?null:scaffoldHeight,
                     child: SingleChildScrollView(
                       scrollDirection: Axis.vertical,
                       child: Column(
                           children: engine.voisoClusters.keys.map((clustername) {
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
                                                   clustername,
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
                                                   engine.voisoCluster.text = clustername;
                                                   engine.voisoKeyCenter.text = engine.voisoClusters[clustername]["center"];
                                                   engine.voisoKeyUser.text = engine.voisoClusters[clustername]["user"];
                                                   Navigator.push(
                                                     context,
                                                     MaterialPageRoute(builder: (context) => const EditVoisoCluster()),
                                                   );
                                                 },
                                                 icon: const Icon(Icons.edit_rounded)
                                             ),
                                             IconButton(
                                                 onPressed: () {
                                                   engine.voisoClusters.remove(clustername);
                                                   setState(() {

                                                   });
                                                 },
                                                 icon: const Icon(Icons.delete_rounded)
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                               ),
                             );
                           }).toList()
                       ),
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

  bool voisoChecked = false;
  @override
  Widget build(BuildContext topContext) {
    ServicesBinding.instance.keyboard.addHandler((KeyEvent event){
      if (event is KeyUpEvent && event.logicalKey.keyLabel == "Escape") {
        Navigator.pop(this.context);
        return true;
      }
      return false;
    });
    final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
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
                if(
                  !voisoChecked
                  && engine.voisoCluster.text.isNotEmpty
                  && engine.voisoKeyUser.text.isNotEmpty
                  && engine.voisoKeyCenter.text.isNotEmpty
                ){
                  Future.delayed(Duration.zero, () {
                    clusterLoading = true;
                    engine.checkVoisoCluster(engine.voisoCluster.text).then((value){
                      setState(() {
                        clusterLoading = false;
                        clusterCorrect = value;
                      });
                    });
                    uKeyLoading = true;
                    engine.checkVoisoUKey(engine.voisoCluster.text, engine.voisoKeyUser.text).then((value){
                      setState(() {
                        uKeyLoading = false;
                        uKeyCorrect = value;
                      });
                    });
                    ccKeyLoading = true;
                    engine.checkVoisoCCKey(engine.voisoCluster.text, engine.voisoKeyCenter.text).then((value){
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
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
                                          "${engine.voisoClusters.containsKey(engine.voisoCluster.text)?"Edit":"Add"} Voiso Cluster",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        Text(
                                          "${engine.voisoClusters.containsKey(engine.voisoCluster.text)?"Edit":"Enter"} credentials for Voiso cluster",
                                        )
                                      ],
                                    ),
                                    Container(
                                      width: 200,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left:5,bottom: 5),
                                        child: TextField(
                                          controller: engine.voisoCluster,
                                          onChanged: (value) {
                                            engine.checkVoisoCluster(engine.voisoCluster.text).then((value){
                                              setState(() {
                                                clusterCorrect = value;
                                              });
                                            });
                                          },
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.dashboard),
                                            suffixIcon: clusterLoading?
                                            Icon(Icons.cloud_sync_outlined):clusterCorrect?
                                            Icon(Icons.done_rounded):
                                            Icon(Icons.error_outline_rounded),
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
                                      padding: const EdgeInsets.only(top: 5,bottom: 5,),
                                      child: TextField(
                                        controller: engine.voisoKeyUser,
                                        onChanged: (value) {
                                          engine.checkVoisoUKey(engine.voisoCluster.text, engine.voisoKeyUser.text).then((value){
                                            setState(() {
                                              uKeyCorrect = value;
                                            });
                                          });
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.person_rounded),
                                          suffixIcon: uKeyLoading?
                                          Icon(Icons.cloud_sync_outlined):uKeyCorrect?
                                          const Icon(Icons.done_rounded):
                                          const Icon(Icons.error_outline_rounded),
                                          labelText: 'User Key',
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5,bottom: 5, ),
                                      child: TextField(
                                        controller: engine.voisoKeyCenter,
                                        onChanged: (value) {
                                          engine.checkVoisoCCKey(engine.voisoCluster.text, engine.voisoKeyCenter.text).then((value){
                                            setState(() {
                                              ccKeyCorrect = value;
                                            });
                                          });
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.corporate_fare_rounded),
                                          suffixIcon: ccKeyLoading?
                                          Icon(Icons.cloud_sync_outlined):ccKeyCorrect?
                                          const Icon(Icons.done_rounded):
                                          const Icon(Icons.error_outline_rounded),
                                          labelText: 'Center Key',
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                        ),
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
                                            Navigator.pop(this.context);
                                          },
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)
                                          ),
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
                                    )
                                ),
                                FilledButton(
                                    onPressed: (ccKeyCorrect && uKeyCorrect && clusterCorrect)
                                        ? (){
                                      engine.saveVoisoKeys(engine.voisoCluster.text, engine.voisoKeyUser.text, engine.voisoKeyCenter.text);
                                      Navigator.pop(topContext);
                                    } : null,
                                    child: const Text(
                                        "Save cluster"
                                    )
                                ),
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
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: SegmentedButton(
                                  segments: engine.voisoClusters.keys.toList().map((cluster) {
                                    return ButtonSegment(
                                        value: cluster,
                                        enabled: true,
                                        label: Text(cluster)
                                    );
                                  }).toList(),
                                  selected: engine.activeVoisoClusters,
                                  multiSelectionEnabled: true,
                                  emptySelectionAllowed: true,
                                  style: SegmentedButton.styleFrom(
                                    padding: EdgeInsets.all(20)
                                  ),
                                  onSelectionChanged: (selector) {
                                    engine.activeVoisoClusters = selector;
                                    engine.filterVoisoUsers();
                                  },
                              ),
                            ),
                          )
                      ),
                      Expanded(
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
                          )
                        )
                    ],
                  ),
                  Container(
                    height: engine.filteredVoisoAgents.isEmpty?null:scaffoldHeight - 66,
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
                                          Text(
                                            agent["name"],
                                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                          ),
                                          Text(
                                            "${agent["extension"]==null?"":"${agent["extension"]} • "}${agent["sag"]=="Supervisor"?"Supervisor in ${agent["supervisor_in_teams"].split(", ").length} team${agent["supervisor_in_teams"].split(", ").length%10==1?"":"s"}":agent["sag"]} • ${agent["email"]} • ${agent["timezone"]}"
                                          )
                                        ],
                                      ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(vertical: 3),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  engine.voisoUserEmail.text = agent["email"];
                                                  engine.voisoUserName.text = agent["name"];
                                                  engine.voisoUserExtension.text = agent["extension"]==null?"":agent["extension"];
                                                  engine.voisoUserPassword.text = "example password";
                                                  engine.voisoUser = agent;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const NewAgentPage()),
                                                  );
                                                },
                                                icon: const Icon(Icons.edit_rounded)
                                            ),
                                            IconButton(
                                                onPressed: null,
                                                icon: const Icon(Icons.delete_rounded)
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                              ),
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
                        :Column(
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
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double scaffoldHeight = constraints.maxHeight;
            double scaffoldWidth = constraints.maxWidth;
            bool album = false;
            print(scaffoldWidth);
            if(scaffoldWidth > 1250){
              album = true;
            }else{
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
                        height: scaffoldHeight-62,
                        child: SingleChildScrollView(
                          child: album
                              ?Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            "Edit agent ${engine.voisoUser["id"]}",
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
                                        Container(
                                          width: album?scaffoldWidth/2-10:scaffoldWidth,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: SegmentedButton(
                                                  segments: [
                                                    ButtonSegment(
                                                        value: "Admin",
                                                        enabled: true,
                                                        label: Text("Admin")
                                                    ),
                                                    ButtonSegment(
                                                        value: "Agent",
                                                        enabled: true,
                                                        label: Text("Agent")
                                                    ),
                                                    ButtonSegment(
                                                        value: "Analyst",
                                                        enabled: true,
                                                        label: Text("Analyst")
                                                    ),
                                                    ButtonSegment(
                                                        value: "Hardware phone",
                                                        enabled: true,
                                                        label: Text("Hardware phone")
                                                    ),
                                                    ButtonSegment(
                                                        value: "Supervisor",
                                                        enabled: true,
                                                        label: Text("Supervisor")
                                                    ),
                                                  ],
                                                  selected: {engine.voisoUser["sag"]},
                                                  multiSelectionEnabled: false,
                                                  emptySelectionAllowed: false,
                                                  showSelectedIcon: false,
                                                  style: SegmentedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7.6),
                                                  ),
                                                  onSelectionChanged: (va){},
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: album?scaffoldWidth/2-62:scaffoldWidth,
                                          child: Row(
                                            children: [
                                              Container(
                                                  width: album?scaffoldWidth/4-10:scaffoldWidth,
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
                                                  )
                                              ),
                                              Container(
                                                width: album?scaffoldWidth/4-62:scaffoldWidth,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5),
                                                  child: DropdownMenu(
                                                    controller: TextEditingController(
                                                        text: engine.voisoUser["timezone"]
                                                    ),
                                                    width: scaffoldWidth/(album?4:2),
                                                    initialSelection: engine.voisoUser["timezone"],
                                                    onSelected: null,
                                                    enableSearch: true,
                                                    label: Text("Timezone"),
                                                    leadingIcon: Icon(Icons.travel_explore_rounded),
                                                    dropdownMenuEntries: [
                                                      DropdownMenuEntry(
                                                          value: engine.voisoUser["timezone"],
                                                          label: engine.voisoUser["timezone"]
                                                      ),
                                                      DropdownMenuEntry(
                                                          value: "Neverland",
                                                          label: "Neverland"
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                ),
                                VerticalDivider(thickness: 1, width: 1),
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
                                                    Text(
                                                      "Agent in",
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top:10),
                                                      child: Container(
                                                        width: scaffoldWidth/2-63,
                                                        child: Wrap(
                                                          direction: Axis.horizontal,
                                                          spacing: -5,
                                                          runSpacing: 5,
                                                          children: engine.voisoUser["agent_in_teams"].split(", ").map((teamid){
                                                            if(teamid==""){
                                                              return Container();
                                                            }
                                                            return Padding(
                                                              padding: const EdgeInsets.only(right: 10),
                                                              child: Chip(
                                                                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                                padding: const EdgeInsets.all(6),
                                                                backgroundColor: Colors.transparent,
                                                                side: const BorderSide(
                                                                    color: Colors.transparent
                                                                ),
                                                                elevation: 5,
                                                                label: Text(engine.getTeamName(teamid)),
                                                              ),
                                                            );
                                                          }).toList().cast<Widget>(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Icon(Icons.arrow_forward_ios_rounded)
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
                                                    Text(
                                                      "Supervisor in",
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top:10),
                                                      child: Container(
                                                        width: scaffoldWidth/2-63,
                                                        child: Wrap(
                                                          direction: Axis.horizontal,
                                                          spacing: -5,
                                                          runSpacing: 5,
                                                          children: engine.voisoUser["supervisor_in_teams"].split(", ").map((teamid){
                                                            if(teamid==""){
                                                              return Container();
                                                            }
                                                            return Padding(
                                                              padding: const EdgeInsets.only(right: 10),
                                                              child: Chip(
                                                                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                                padding: const EdgeInsets.all(6),
                                                                backgroundColor: Colors.transparent,
                                                                side: const BorderSide(
                                                                    color: Colors.transparent
                                                                ),
                                                                elevation: 5,
                                                                label: Text(engine.getTeamName(teamid)),
                                                              ),
                                                            );
                                                          }).toList().cast<Widget>(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Icon(Icons.arrow_forward_ios_rounded)
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
                                                    Text(
                                                      "Skills",
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                    ),
                                                    Text(
                                                        "${engine.voisoUser["assigned_skills"].length} asigned"
                                                    ),
                                                  ],
                                                ),
                                                Icon(Icons.arrow_forward_ios_rounded)
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
                                                    Text(
                                                      "Queues",
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                    ),
                                                    Text(
                                                        engine.voisoUser["assigned_queues"]
                                                    ),
                                                  ],
                                                ),
                                                Icon(Icons.arrow_forward_ios_rounded)
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ]
                          )
                              :Column(
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
                                        ButtonSegment(
                                            value: "Admin",
                                            enabled: true,
                                            label: Text("Admin")
                                        ),
                                        ButtonSegment(
                                            value: "Agent",
                                            enabled: true,
                                            label: Text("Agent")
                                        ),
                                        ButtonSegment(
                                            value: "Analyst",
                                            enabled: true,
                                            label: Text("Analyst")
                                        ),
                                        ButtonSegment(
                                            value: "Hardware phone",
                                            enabled: true,
                                            label: Text("Hardware phone")
                                        ),
                                        ButtonSegment(
                                            value: "Supervisor",
                                            enabled: true,
                                            label: Text("Supervisor")
                                        ),
                                      ],
                                      selected: {engine.voisoUser["sag"]},
                                      multiSelectionEnabled: false,
                                      emptySelectionAllowed: false,
                                      showSelectedIcon: false,
                                      style: SegmentedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7.6),
                                      ),
                                      onSelectionChanged: (va){},
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
                                      )
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: DropdownMenu(
                                        controller: TextEditingController(
                                            text: engine.voisoUser["timezone"]
                                        ),
                                        width: scaffoldWidth/2 - 10,
                                        initialSelection: engine.voisoUser["timezone"],
                                        onSelected: null,
                                        enableSearch: true,
                                        label: Text("Timezone"),
                                        leadingIcon: Icon(Icons.travel_explore_rounded),
                                        dropdownMenuEntries: [
                                          DropdownMenuEntry(
                                              value: engine.voisoUser["timezone"],
                                              label: engine.voisoUser["timezone"]
                                          ),
                                          DropdownMenuEntry(
                                              value: "Neverland",
                                              label: "Neverland"
                                          )
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
                                          Text(
                                            "Agent in",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top:10),
                                            child: Container(
                                              width: scaffoldWidth-62,
                                              child: Wrap(
                                                direction: Axis.horizontal,
                                                spacing: -5,
                                                runSpacing: 5,
                                                children: engine.voisoUser["agent_in_teams"].split(", ").map((teamid){
                                                  if(teamid==""){
                                                    return Container();
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Chip(
                                                      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                      padding: const EdgeInsets.all(6),
                                                      backgroundColor: Colors.transparent,
                                                      side: const BorderSide(
                                                          color: Colors.transparent
                                                      ),
                                                      elevation: 5,
                                                      label: Text(engine.getTeamName(teamid)),
                                                    ),
                                                  );
                                                }).toList().cast<Widget>(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded)
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
                                          Text(
                                            "Supervisor in",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top:10),
                                            child: Container(
                                              width: scaffoldWidth-62,
                                              child: Wrap(
                                                direction: Axis.horizontal,
                                                spacing: -5,
                                                runSpacing: 5,
                                                children: engine.voisoUser["supervisor_in_teams"].split(", ").map((teamid){
                                                  if(teamid==""){
                                                    return Container();
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Chip(
                                                      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                      padding: const EdgeInsets.all(6),
                                                      backgroundColor: Colors.transparent,
                                                      side: const BorderSide(
                                                          color: Colors.transparent
                                                      ),
                                                      elevation: 5,
                                                      label: Text(engine.getTeamName(teamid)),
                                                    ),
                                                  );
                                                }).toList().cast<Widget>(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded)
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
                                          Text(
                                            "Skills",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                              "${engine.voisoUser["assigned_skills"].length} asigned"
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded)
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
                                          Text(
                                            "Queues",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                              engine.voisoUser["assigned_queues"]
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded)
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
                                )
                            ),
                            Text(
                              "Editing agents is not available yet",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error
                              ),
                            ),
                            FilledButton(
                                onPressed: null,
                                child: Text(
                                    "Save"
                                )
                            ),
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