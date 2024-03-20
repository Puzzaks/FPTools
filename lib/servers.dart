import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'engine.dart';

class ServersPage extends StatefulWidget {
  const ServersPage({super.key});
  @override
  ServersPageState createState() => ServersPageState();
}

class ServersPageState extends State<ServersPage> {
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
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double scaffoldHeight = constraints.maxHeight;
              double scaffoldWidth = constraints.maxWidth;
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
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
                  tooltip: "Add server",
                  child: Icon(Icons.add_rounded),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        height: scaffoldHeight,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                              children: engine.known.keys.map((server) {
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
                                                Padding(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: engine.availables[server]?Icon(Icons.done_rounded):Icon(Icons.error_outline_rounded),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      engine.known[server]["name"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                    ),
                                                    Text(
                                                      "${engine.known[server]["user"]}@${server} • ${engine.availables[server]?DateTime.parse(engine.logins[server]["data"]["expire"]).difference(DateTime.now()).inMinutes > 0 ? "Logged in (${DateTime.parse(engine.logins[server]["data"]["expire"]).difference(DateTime.now()).inMinutes} min left)" : "Logging back in...":"Server unavailable"}",
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            FilledButton(
                                                onPressed: () {
                                                  engine.tempL.text = engine.known[server]["name"];
                                                  engine.tempA.text = engine.known[server]["addr"];
                                                  engine.tempU.text = engine.known[server]["user"];
                                                  engine.tempP.text = engine.known[server]["pass"];
                                                  engine.checkAndCacheBrand();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => NewServerPage()),
                                                  );
                                                },
                                                child: Text(
                                                  'Edit',
                                                  style: TextStyle(color: Theme.of(context).colorScheme.background),
                                                )),
                                          ],
                                        ),
                                        engine.availables[server] ? FutureBuilder(
                                            future: engine.getDomains(server),
                                            builder: (BuildContext context, AsyncSnapshot domains) {
                                              if (engine.availdomains.containsKey(server)) {
                                                if (!engine.domains.containsKey(server)) {
                                                  engine.domains[server] = [];
                                                }

                                                return SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: Wrap(
                                                      spacing: 5,
                                                      // Adjust the spacing between chips as needed
                                                      runSpacing: 5,
                                                      // Adjust the run spacing as needed
                                                      children: engine.availdomains[server].map((domain) {
                                                        var enabled = false;
                                                        for(int i=0; i<engine.domains[server].length;i++){
                                                          if(engine.domains[server][i]["id"] == domain["data"][0]["id"]){
                                                            enabled = true;
                                                          }
                                                        }
                                                        return GestureDetector(
                                                          onTap: () async {
                                                            bool found = false;
                                                            for(int i=0; i<engine.domains[server].length;i++){
                                                              if(engine.domains[server][i]["id"] == domain["data"][0]["id"]){
                                                                found = true;
                                                                engine.domains[server].removeAt(i);
                                                                engine.domainUsers.remove(domain["data"][0]["name"]);
                                                                engine.toUpdate.remove(domain["data"][0]["name"]);
                                                              }
                                                            }
                                                            if(!found){
                                                              engine.toUpdate.add(domain["data"][0]["name"]);
                                                              engine.domains[server].add(domain["data"][0]);
                                                            }
                                                            engine.saveDomains().then((value) async {
                                                              engine.toUpdate.add(domain["data"][0]["name"]);
                                                              await engine.getAllUsers().then((value){
                                                                engine.filterUsers();
                                                              });
                                                            });
                                                          },
                                                          child: Chip(
                                                            backgroundColor: enabled
                                                                ? Theme.of(context).colorScheme.primary
                                                                : null,
                                                            label: Text(
                                                              "${domain["data"][0]["name"]}",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                enabled ? FontWeight.w600 : FontWeight.w400,
                                                                color: enabled
                                                                    ? Theme.of(context).colorScheme.background
                                                                    : Colors.grey,
                                                              ),
                                                            ),
                                                            elevation: 5.0,
                                                          ),
                                                        );
                                                      })
                                                          .toList()
                                                          .cast<Widget>(),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Center(
                                                  child: LinearProgressIndicator(
                                                    backgroundColor: Colors.transparent,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                );
                                              }
                                            })
                                            : Container()
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()
                          ),
                        )),
                  ],
                ),
              );
            }
          );
        }),
      );
    });
  }
}

class NewServerPage extends StatefulWidget {
  const NewServerPage({super.key});
  @override
  NewServerPageState createState() => NewServerPageState();
}

class NewServerPageState extends State<NewServerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext topContext) {
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
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Fastpanel instance",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextField(
                        controller: engine.tempL,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.new_label_rounded),
                          labelText: 'Label',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextField(
                        controller: engine.tempA,
                        onChanged: (value) {
                          engine.checkAndCacheBrand();
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.dns_rounded),
                          labelText: 'Server IP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextField(
                        controller: engine.tempU,
                        onChanged: (value) {
                          engine.checkAndCacheBrand();
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_rounded),
                          labelText: 'Login',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextField(
                        controller: engine.tempP,
                        onChanged: (value) {
                          engine.checkAndCacheBrand();
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password_rounded),
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    engine.known.containsKey(engine.tempA.text)
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
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Icon(Icons.dangerous_rounded),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Forget this FastPanel",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                FilledButton(
                                    onPressed: () {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          icon: Icon(Icons.delete_rounded),
                                          title: const Text('Forget this panel?'),
                                          content: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('You are about to remove ${engine.tempA.text} from known servers.\nConfirm deletion?'),
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
                                                      engine.known.remove(engine.tempA.text);
                                                      engine.saveBrandList().then((value){
                                                        Navigator.pop(topContext);
                                                        Navigator.pop(context);
                                                      });
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
                      padding: EdgeInsets.only(
                          top: 5,
                          bottom: 10,
                          left: 10,
                          right: 10
                      ),
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
                              onPressed: (engine.tempA.text.isNotEmpty && engine.tempPanelAddReady && !engine.tempPanelAddloading)
                                  ? () async {
                                await engine.saveBrand().then((value) {
                                  Navigator.pop(topContext);
                                });
                              }
                                  : null,
                              child: const Text('Save')
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        }),
      );
    });
  }
}