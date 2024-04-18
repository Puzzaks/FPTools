import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'engine.dart';

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
                  engine.userDomains = [];
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
                    MaterialPageRoute(builder: (context) => NewAgentPage()),
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
                    height: engine.filtered.length == 0?null:scaffoldHeight - 66,
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
                                                    IconButton(onPressed: () {
                                                      showDialog<String>(
                                                        context: context,
                                                        builder: (BuildContext context) => AlertDialog(
                                                          content: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text('Updating password for ${engine.filtered[login][0]["login"]}'),
                                                              Padding(
                                                                padding: EdgeInsets.only(top: 10),
                                                                child: TextField(
                                                                  controller: engine.updatePassword,
                                                                  onChanged: (value) {
                                                                  },
                                                                  decoration: InputDecoration(
                                                                    prefixIcon: Icon(Icons.password_rounded),
                                                                    labelText: 'New password',
                                                                    helperText: 'Leave empty for random password',
                                                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                                                                  ),
                                                                ),
                                                              ),
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
                                                                        await engine.updateUser(accounts[i]).then((value) async {

                                                                        });
                                                                      }
                                                                    },
                                                                    child: const Text('Confirm')
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }, icon: Icon(Icons.edit_rounded)),
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
                                                                        engine.toUpdate.add(accounts[i]["address"].replaceAll("${accounts[i]["login"]}@", ""));
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
                                                          IconButton(onPressed: () {
                                                            showDialog<String>(
                                                              context: context,
                                                              builder: (BuildContext context) => AlertDialog(
                                                                content: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Text('Updating password for ${engine.filtered[login][0]["login"]}'),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(top: 10),
                                                                      child: TextField(
                                                                        controller: engine.updatePassword,
                                                                        onChanged: (value) {
                                                                        },
                                                                        decoration: InputDecoration(
                                                                          prefixIcon: Icon(Icons.password_rounded),
                                                                          labelText: 'New password',
                                                                          helperText: 'Leave empty for random password',
                                                                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                                                                        ),
                                                                      ),
                                                                    ),
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
                                                                            await engine.updateUser(account).then((value) async {

                                                                            });
                                                                          },
                                                                          child: const Text('Confirm')
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          }, icon: Icon(Icons.edit_rounded)),
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
                                                                            Navigator.pop(context);
                                                                            await engine.deleteUser(account).then((value) async {
                                                                              engine.toUpdate.add(account["address"].replaceAll("${account["login"]}@", ""));
                                                                              await engine.getAllUsers().then((value) async {
                                                                                await engine.filterUsers().then((value) async {

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
                                          IconButton(onPressed: () {
                                            showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) => AlertDialog(
                                                content: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('Updating password for ${engine.filtered[login][0]["login"]}'),
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 10),
                                                      child: TextField(
                                                        controller: engine.updatePassword,
                                                        onChanged: (value) {
                                                        },
                                                        decoration: InputDecoration(
                                                          prefixIcon: Icon(Icons.password_rounded),
                                                          labelText: 'New password',
                                                          helperText: 'Leave empty for random password',
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                                                        ),
                                                      ),
                                                    ),
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
                                                            await engine.updateUser(engine.filtered[login][0]).then((value) async {

                                                            });
                                                          },
                                                          child: const Text('Confirm')
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          }, icon: Icon(Icons.edit_rounded)),
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
                                                            Navigator.pop(context);
                                                            await engine.deleteUser(engine.filtered[login][0]).then((value) async {
                                                              engine.toUpdate.add(engine.filtered[login][0]["address"].replaceAll("${engine.filtered[login][0]["login"]}@", ""));
                                                              await engine.getAllUsers().then((value) async {
                                                                await engine.filterUsers().then((value){
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

  @override
  Widget build(BuildContext topContext) {
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
                                      if(value == engine.normUsername(value)){
                                        engine.userMessage = "Leave password field empty for random password";
                                      }else{
                                        engine.userMessage = "User will be created as ${engine.normUsername(value)}";
                                      }
                                      if(engine.allUsers.contains(value) && engine.allowDuplicates){
                                        engine.userErrors.add("This user already exists");
                                      }else{
                                        engine.userErrors.remove("This user already exists");
                                      }
                                      if(value == "" && engine.userL.text.isEmpty){
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
                                            ? engine.userMessage
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
                            child: Container(
                              height: scaffoldHeight - 246,
                              child: SingleChildScrollView(
                                child: Builder(
                                    builder: (context) {
                                      return Wrap(
                                        spacing: 5,
                                        runSpacing: 5,
                                        children: engine.creationDomains.map((crD) {
                                          return GestureDetector(
                                            onTap: () {
                                              if(engine.userDomains.contains(crD)){
                                                engine.toUpdate.remove(crD["name"]);
                                                engine.userDomains.remove(crD);
                                              }else{
                                                engine.toUpdate.add(crD["name"]);
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
                                                "${crD["name"]}",
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
                                onPressed: engine.userErrors.isEmpty ? () {
                                  engine.createUser();
                                  Navigator.pop(topContext);
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
    });
  }
}