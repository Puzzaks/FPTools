import 'dart:io';
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
    WindowManager.instance.setMaximumSize(const Size(775, 525));
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
        title: 'FastPanel Toolkit',
        home: Consumer<fastEngine>(builder: (context, engine, child) {
          return Scaffold(
            body: Container(
              width: View.of(context).physicalSize.width,
              height: View.of(context).physicalSize.height,
              child: engine.loading ?
              Center(
                child: Container(
                  height: 85,
                  width: 400,
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
                                "Starting FPTools...",
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
                    extended: true,
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
                    width: 500,
                    height: View.of(context).physicalSize.height,
                    child: Builder(
                      builder: (context) {
                        switch (screenIndex) {
                          case 0:
                            return UsersPage(); //users
                          case 1:
                            return ServersPage(); //brands
                          case 2:
                            return Container(
                              width: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Card(
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Display less users",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                              ),
                                              Text(
                                                "Limit amount of users in the list",
                                              )
                                            ],
                                          ),
                                          Switch(
                                            thumbIcon: thumbIcon,
                                            value: engine.displayUsers,
                                            onChanged: (bool value) {
                                              setState(() {
                                                engine.displayUsers = value;
                                                engine.saveToggle("displayUsers", value);
                                                engine.filterUsers();
                                              });
                                            },
                                          )
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
                                          const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Spreadsheet-ready copying",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                              ),
                                              Text(
                                                "Copy new users as username-password pair",
                                              )
                                            ],
                                          ),
                                          Switch(
                                            thumbIcon: thumbIcon,
                                            value: engine.loadOnLaunch,
                                            onChanged: (bool value) {
                                              setState(() {
                                                engine.loadOnLaunch = value;
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ); //settings
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
        }),
      );
    });
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {
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
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                engine.userDomains = [];
                engine.userErrors = [];
                engine.creationDomains = [];
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
              tooltip: "Add user",
              child: Icon(Icons.add_rounded),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    controller: engine.userSearch,
                    onChanged: (value) {
                      engine.filterUsers();
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      labelText: 'Search users',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                ),
                Container(
                  height: engine.filtered.length == 0?null:421,
                  child: engine.filtered.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Builder(builder: (context) {
                            List logins = [];
                            for (int i = 0; i < engine.filtered.length; i++) {
                              logins.add(engine.filtered.keys.toList()[i]);
                            }
                            return Column(
                                children: logins.map((login) {
                              List accounts = engine.filtered[login];
                              return Card(
                                elevation: 2,
                                clipBehavior: Clip.hardEdge,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: engine.filtered[login].length > 1 ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  child: engine.filtered[login].length > 1
                                      ? ExpansionTileTheme(
                                          data: ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15)),
                                          child: Theme(
                                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                              child: ExpansionTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${engine.filtered[login][0]["login"]} • ${engine.filtered[login].length} domains",
                                                      style: TextStyle(fontSize: 16),
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(onPressed: () {}, icon: Icon(Icons.edit_rounded)),
                                                        IconButton(onPressed: () {
                                                          showDialog<String>(
                                                            context: context,
                                                            builder: (BuildContext context) => AlertDialog(
                                                              icon: Icon(Icons.delete_rounded),
                                                              title: const Text('Confirm deletion'),
                                                              content: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text('You are about to delete following accounts:'),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: accounts.map((account) {
                                                                      return Text(" • ${account["address"]}");
                                                                    }).toList(),
                                                                  ),
                                                                  Text('Confirm deletion please.'),
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
                                                                          Navigator.pop(context);
                                                                          for(int i = 0; i<accounts.length;i++){
                                                                            await engine.deleteUser(accounts[i]).then((value) async {

                                                                            });
                                                                          }
                                                                          await engine.getAllUsers().then((value) async {

                                                                          });
                                                                          await engine.filterUsers().then((value) async {
                                                                          });
                                                                        },
                                                                        child: const Text('Confirm')
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        }, icon: Icon(Icons.delete_rounded))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                children: accounts.map((account) {
                                                  return Card(
                                                    elevation: 10,
                                                    clipBehavior: Clip.hardEdge,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            account["address"],
                                                            style: TextStyle(fontSize: 16),
                                                          ),
                                                          Row(
                                                            children: [
                                                              IconButton(onPressed: () {}, icon: Icon(Icons.edit_rounded)),
                                                              IconButton(onPressed: () {
                                                                showDialog<String>(
                                                                  context: context,
                                                                  builder: (BuildContext context) => AlertDialog(
                                                                    icon: Icon(Icons.delete_rounded),
                                                                    title: const Text('Confirm deletion'),
                                                                    content: Text('You are about to delete ${account["address"]}.\nConfirm deletion please.'),
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
                                                                              await engine.deleteUser(account).then((value) async {
                                                                                await engine.getAllUsers().then((value) async {
                                                                                  await engine.filterUsers().then((value) async {
                                                                                    Navigator.pop(context);
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
                                                              }, icon: Icon(Icons.delete_rounded))
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              )))
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${engine.filtered[login][0]["login"]} • ${engine.filtered[login][0]["address"].replaceAll("${engine.filtered[login][0]["login"]}@", "")}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(onPressed: () {}, icon: Icon(Icons.edit_rounded)),
                                                IconButton(onPressed: () {
                                                  showDialog<String>(
                                                    context: context,
                                                    builder: (BuildContext context) => AlertDialog(
                                                      icon: Icon(Icons.delete_rounded),
                                                      title: const Text('Confirm deletion'),
                                                      content: Text('You are about to delete ${engine.filtered[login][0]["address"]}.\nConfirm deletion please.'),
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
                                                                  await engine.deleteUser(engine.filtered[login][0]).then((value) async {
                                                                    await engine.getAllUsers().then((value) async {
                                                                      await engine.filterUsers().then((value){
                                                                        Navigator.pop(context);
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
                                                }, icon: Icon(Icons.delete_rounded))
                                              ],
                                            )
                                          ],
                                        ),
                                ),
                              );
                            }).toList());
                          }),
                        )
                      : !engine.loading
                  ? Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.warning_rounded)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "No users to display.",
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
        }),
      );
    });
  }
}

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});
  @override
  NewUserPageState createState() => NewUserPageState();
}

class NewUserPageState extends State<NewUserPage> {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Add new user",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left:5, right: 5,bottom: 5),
                            child: TextField(
                              controller: engine.userL,
                              onChanged: (value) {
                                if(engine.allUsers.contains(value)){
                                  engine.userErrors.add("This user already exists");
                                }else{
                                  engine.userErrors.remove("This user already exists");
                                }
                                if(value == ""){
                                  engine.userErrors.add("Enter valid username");
                                }else{
                                  engine.userErrors.remove("Enter valid username");
                                }
                                setState(() {

                                });
                              },
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person_rounded),
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 5, left: 5,bottom: 5,),
                              child: TextField(
                                controller: engine.userP,
                                onChanged: (value) {

                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.password_rounded),
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.only(right: 10), child: engine.userErrors.isEmpty ? Icon(Icons.info_outline_rounded) : Icon(Icons.error_rounded)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  engine.userErrors.isEmpty
                                      ? "Leave password field empty for random password"
                                  : engine.userErrors[0],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Builder(
                            builder: (context) {
                              return Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: engine.creationDomains.map((crD) {
                                  return GestureDetector(
                                    onTap: () {
                                        if(engine.userDomains.contains(crD)){
                                          engine.userDomains.remove(crD);
                                        }else{
                                          engine.userDomains.add(crD);
                                        }
                                        if(engine.userDomains.isEmpty){
                                          engine.userErrors.add("No domains selected");
                                        }else{
                                          engine.userErrors.remove("No domains selected");
                                        }
                                      setState(() {});
                                    },
                                    child: Chip(
                                      backgroundColor: engine.userDomains.contains(crD)
                                          ? Theme.of(context).colorScheme.primary
                                          : null,
                                      label: Text(
                                        "${crD["domain"]}",
                                        style: TextStyle(
                                          fontWeight:
                                          engine.userDomains.contains(crD) ? FontWeight.w600 : FontWeight.w400,
                                          color: engine.userDomains.contains(crD)
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
                              );
                            }
                        ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(15),
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
                          onPressed: engine.userErrors.isEmpty ? () async {
                            await engine.createUser().then((value){
                              Navigator.pop(topContext);
                            });
                          }
                              : null,
                          child: Text(
                            engine.userDomains.length > 1 ? "Create users" : "Create user"
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
  }
}

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
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      labelText: 'Search servers and domains',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                ),
                Container(
                    height: 421,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          children: engine.known.keys.map((server) {
                            print(engine.availables[server]);
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
                                              if (domains.hasData) {
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
                                                      children: domains.data["data"]
                                                          .map((domain) {
                                                        var enabled = false;
                                                        for(int i=0; i<engine.domains[server].length;i++){
                                                          if(engine.domains[server][i]["id"] == domain["id"]){
                                                            enabled = true;
                                                          }
                                                        }
                                                        if(domain["status_code"] == 200){
                                                          return GestureDetector(
                                                            onTap: () async {
                                                              bool found = false;
                                                              for(int i=0; i<engine.domains[server].length;i++){
                                                                if(engine.domains[server][i]["id"] == domain["id"]){
                                                                  found = true;
                                                                  engine.domains[server].removeAt(i);
                                                                }
                                                              }
                                                              if(!found){
                                                                engine.domains[server].add(domain);
                                                              }
                                                              engine.saveDomains().then((value) async {
                                                                await engine.getAllUsers().then((value){
                                                                  engine.filterUsers();
                                                                });
                                                                setState(() {});
                                                              });
                                                            },
                                                            child: Chip(
                                                              backgroundColor: enabled
                                                                  ? Theme.of(context).colorScheme.primary
                                                                  : null,
                                                              label: Text(
                                                                "${domain["domain"]}",
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
                                                        }
                                                        return Container();
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
                                  if (value) {
                                    Navigator.pop(topContext);
                                  } else {
                                    print("HOW???");
                                  }
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
