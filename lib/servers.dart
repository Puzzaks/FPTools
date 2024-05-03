import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'engine.dart';
import 'package:flutter/services.dart';


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
    ServicesBinding.instance.keyboard.addHandler((KeyEvent event){
      if (event is KeyUpEvent && event.logicalKey.keyLabel == "F5") {
        setState(() {});
        return true;
      }
      return false;
    });
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
          if(engine.toOpenDCM){
            engine.toOpenDCM = false;
            engine.fetchTimer.cancel();
            engine.tempL.text = "";
            engine.tempA.text = "";
            engine.tempU.text = "";
            engine.tempP.text = "";
            engine.tempPanelAddReady = false;
            Future.delayed(Duration.zero, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewServerPage()),
              );
            });
          }
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
                      MaterialPageRoute(builder: (context) => const NewServerPage()),
                    );
                  },
                  tooltip: "Add server",
                  child: const Icon(Icons.add_rounded),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        controller: engine.serverSearch,
                        onChanged: (value) {
                          if(value.contains("	")){
                            if(value.split("	")[0].length > 2 && value.split("	")[1].length > 2 && value.split("	")[2].length > 2 && value.split("	")[3].length > 2){
                              engine.tempP.text = value.split("	")[3].replaceAll("	", "");
                              engine.tempU.text = value.split("	")[2].replaceAll("	", "");
                              engine.tempA.text = value.split("	")[1].replaceAll("	", "").split("://")[1].split(":")[0];
                              engine.tempL.text = value.split("	")[0].replaceAll("	", "");
                              engine.serverSearch.text = value.split("	")[0].replaceAll("	", "");
                              engine.checkAndCacheBrand();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NewServerPage()),
                              );
                            }
                          }else{
                            engine.filterServers();
                          }
                        },
                        decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: engine.serverSearch.text.isNotEmpty
                                ? IconButton(
                                onPressed: () {
                                  engine.serverSearch.clear();
                                  engine.filterServers();
                                },
                                icon: const Icon(Icons.clear_rounded)
                            ) : null,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded),
                          labelText: 'Search servers',
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                        ),
                      ),
                    ),
                    Container(
                        height: scaffoldHeight - 66,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                              children: engine.displayKnown.keys.map((server) {
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
                                                  padding: const EdgeInsets.only(right: 10),
                                                  child: engine.availables[server]?const Icon(Icons.done_rounded):const Icon(Icons.error_outline_rounded),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      engine.known[server]["name"],
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                    ),
                                                    Text(
                                                      "${engine.known[server]["user"]}@${server} • ${engine.availables[server]?DateTime.parse(engine.logins[server]["data"]["expire"]).difference(DateTime.now()).inMinutes > 0 ? "Logged in (${DateTime.parse(engine.logins[server]["data"]["expire"]).difference(DateTime.now()).inMinutes} min left)" : "Logging back in...":"Server unavailable"}",
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      engine.tempL.text = engine.known[server]["name"];
                                                      engine.tempA.text = engine.known[server]["addr"];
                                                      engine.tempU.text = engine.known[server]["user"];
                                                      engine.tempP.text = engine.known[server]["pass"];
                                                      engine.checkAndCacheBrand();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => const NewServerPage()),
                                                      );
                                                    },
                                                    icon: const Icon(Icons.edit)
                                                ),
                                                IconButton(
                                                    onPressed: (){
                                                      showDialog<String>(
                                                        context: context,
                                                        builder: (BuildContext context) => AlertDialog(
                                                          icon: const Icon(Icons.delete_rounded),
                                                          title: const Text('Forget this panel?'),
                                                          content: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text('You are about to remove ${engine.known[server]["name"]} (${server}) from known servers.\nConfirm deletion?'),
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
                                                                      engine.known.remove(server);
                                                                      engine.domains.remove(server);
                                                                      engine.saveBrandList().then((value){
                                                                        engine.saveDomains().then((value){
                                                                          Navigator.pop(context);
                                                                          setState(() {
                                                                          });
                                                                        });
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
                                                    icon: const Icon(Icons.delete)
                                                )
                                              ],
                                            ),
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
  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext topContext) {
    final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
    bool isCtrl = false;
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
            ServicesBinding.instance.keyboard.addHandler((KeyEvent event){
              if (event is KeyUpEvent && event.logicalKey.keyLabel == "Enter") {
                if(engine.tempA.text.isNotEmpty && engine.tempPanelAddReady && !engine.tempPanelAddloading){
                  engine.saveBrand().then((value) {
                    engine.filterServers().then((e){
                      Navigator.pop(this.context);
                    });
                  });
                }
                return true;
              }
              if (isCtrl && event.logicalKey.keyLabel == "S") {
                if(engine.tempA.text.isNotEmpty && engine.tempPanelAddReady && !engine.tempPanelAddloading){
                  engine.saveBrand().then((value) {
                    engine.filterServers().then((e){
                      Navigator.pop(this.context);
                    });
                  });
                }
                return true;
              }
              if (event is KeyDownEvent && event.logicalKey.keyLabel == "Control Left") {
                isCtrl = true;
                return true;
              }
              if (event is KeyUpEvent && event.logicalKey.keyLabel == "Control Left") {
                isCtrl = false;
                return true;
              }
              return false;
            });
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Fastpanel instance",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: TextField(
                          controller: engine.tempL,
                          onChanged: (value){
                            if(value.contains("	")){
                              if(value.split("	")[0].length > 2 && value.split("	")[1].length > 2 && value.split("	")[2].length > 2 && value.split("	")[3].length > 2){
                                engine.tempP.text = value.split("	")[3].replaceAll("	", "");
                                engine.tempU.text = value.split("	")[2].replaceAll("	", "");
                                engine.tempA.text = value.split("	")[1].replaceAll("	", "").split("://")[1].split(":")[0];
                                engine.tempL.text = value.split("	")[0].replaceAll("	", "");
                                engine.checkAndCacheBrand();
                              }
                            }
                            setState(() {

                            });
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.new_label_rounded),
                            labelText: 'Label',
                            helperText: engine.tempL.text.isEmpty?"Paste whole line from the spreadsheet here for autofill":null,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: TextField(
                          controller: engine.tempA,
                          onChanged: (value) {
                            if(value.isNotEmpty){
                              engine.checkAndCacheBrand();
                            }
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.dns_rounded),
                            labelText: 'Server IP',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: TextField(
                          controller: engine.tempU,
                          onChanged: (value) {
                            if(value.isNotEmpty){
                              engine.checkAndCacheBrand();
                            }
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_rounded),
                            labelText: 'Login',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: TextField(
                          controller: engine.tempP,
                          onChanged: (value) {
                            if(value.isNotEmpty){
                              engine.checkAndCacheBrand();
                            }
                          },
                          decoration: const InputDecoration(
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
                                            icon: const Icon(Icons.delete_rounded),
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
                                                        engine.domains.remove(engine.tempA.text);
                                                        engine.saveBrandList().then((value){
                                                          engine.saveDomains().then((value){
                                                            Navigator.pop(topContext);
                                                            Navigator.pop(context);
                                                            setState(() {
                                                            });
                                                          });
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
                        padding: const EdgeInsets.only(
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
                                  await engine.saveBrand().then((value) async {

                                    await engine.filterServers().then((e){
                                      Navigator.pop(topContext);
                                    });
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
      }),
    );
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}