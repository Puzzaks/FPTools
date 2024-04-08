import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'engine.dart';

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
          List unavailables = [];
          for(int i=0;i<engine.availables.length;i++){
            if(!engine.availables[engine.availables.keys.toList()[i]]){
              unavailables.add(engine.availables.keys.toList()[i]);
            }
          }
          return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            double scaffoldHeight = constraints.maxHeight;
            double scaffoldWidth = constraints.maxWidth;
            return Scaffold(
              floatingActionButton: !engine.domainsLoading
                ? FloatingActionButton(
                onPressed: () {
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
                tooltip: "Add user",
                child: Icon(Icons.add_rounded),
              ):null,
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
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: engine.selectedUsers.isNotEmpty
                              ? FilledButton(
                                onPressed: (){
                                  engine.userSearch.clear();
                                  engine.filterUsers();
                                },
                                child: Text("Show ${engine.selectedUsers.length} selected"),
                              )
                              : engine.userSearch.text.isNotEmpty
                              ? IconButton(
                              onPressed: () {
                                engine.userSearch.clear();
                                engine.filterUsers();
                              },
                              icon: Icon(Icons.clear_rounded)
                          ) : null,
                        ),
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search users',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ),
                  (engine.newbieDomains.isNotEmpty) ? Card(
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
                              Container(
                                width: scaffoldWidth - 80,
                                child: Text(
                                  "User not found on ${engine.newbieDomains.map((e){return "$e";})}.${engine.action=="Ready"?"":" Updating now..."}",
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ) : Container(),
                  unavailables.isNotEmpty ? Card(
                        color: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.errorContainer),
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
                                  Container(
                                    width: scaffoldWidth - 80,
                                    child: Text(
                                      "${unavailables.length==1?"Domain is unavailable: ${engine.known[unavailables[0]]["name"]}":"Some domains are not available: ${unavailables.map((e){return "$e";})}"}.",
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ) : Container(),
                  engine.loading?Card(
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
                  Container(
                    height: engine.filtered.isEmpty?null:scaffoldHeight - (engine.newbieDomains.isEmpty?unavailables.isNotEmpty?128:66:unavailables.isNotEmpty?206:144) - (engine.loading?84:0),
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
                                                Row(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          if(engine.selectedUsers.isNotEmpty&&engine.userSearch.text.isEmpty){
                                                            engine.selectedUsers.clear();
                                                            engine.filterUsers();
                                                          }else{
                                                            for(int i=0;i < accounts.length; i++){
                                                              if(!engine.selectedUsers.contains(accounts[i])){
                                                                engine.selectedUsers.add(accounts[i]);
                                                              }
                                                            }
                                                            engine.filterUsers();
                                                          }
                                                        },
                                                        icon: (engine.selectedUsers.isNotEmpty&&engine.userSearch.text.isEmpty)
                                                          ? Icon(Icons.remove_done_rounded)
                                                          : Icon(Icons.done_all_rounded)
                                                    ),
                                                    Text(
                                                      "${(engine.selectedUsers.isNotEmpty&&engine.userSearch.text.isEmpty)? "Selected":engine.filtered[login][0]["login"]}${(engine.selectedUsers.isNotEmpty&&engine.userSearch.text.isEmpty)?"":" • ${engine.filtered[login].length} domains"}${engine.selectedUsers.isNotEmpty?" • ${engine.selectedUsers.length} ${(engine.selectedUsers.isNotEmpty&&engine.userSearch.text.isEmpty)?"total":"selected"}":""}",
                                                      style: TextStyle(fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () async {
                                                        await Clipboard.setData(ClipboardData(text: engine.filtered[login][0]["login"]));
                                                      },
                                                      icon: Icon(Icons.copy_rounded)
                                                  ),
                                                    IconButton(
                                                        onPressed: () {
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
                                                        },
                                                        icon: Icon(Icons.edit_rounded)
                                                    ),
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
                                                              Text('You are about to delete ${accounts.length} accounts:'),
                                                              Container(
                                                                constraints: BoxConstraints(maxHeight: 120),
                                                                child: SingleChildScrollView(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: accounts.map((account) {
                                                                      return Text(" • ${account["address"]}");
                                                                    }).toList(),
                                                                  ),
                                                                ),
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
                                                                        await engine.filterUsers().then((value) async {

                                                                        });
                                                                      });
                                                                      engine.selectedUsers.clear();
                                                                      engine.filterUsers();
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
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(right: 5,top:4,bottom:4),
                                                            child: Checkbox(
                                                              value: engine.selectedUsers.contains(account),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  if(engine.selectedUsers.contains(account)){
                                                                    engine.selectedUsers.remove(account);
                                                                  }else{
                                                                    engine.selectedUsers.add(account);
                                                                  }
                                                                });
                                                                if(engine.selectedUsers.isEmpty){engine.filterUsers();}
                                                              },
                                                            ),
                                                          ),
                                                          Text(
                                                            account["address"],
                                                            style: TextStyle(fontSize: 16),
                                                          ),
                                                        ],
                                                      ),
                                                      engine.selectedUsers.isEmpty
                                                          ? Row(
                                                        children: [
                                                          IconButton(
                                                              onPressed: () async {
                                                                await Clipboard.setData(ClipboardData(text: account["address"]));
                                                              },
                                                              icon: Icon(Icons.copy_rounded)
                                                          ),
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
                                                      ) : Container()
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          )))
                                      : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 5,top:4,bottom:4),
                                            child: Checkbox(
                                              value: engine.selectedUsers.contains(engine.filtered[login][0]),
                                              onChanged: (value) {
                                                setState(() {
                                                  if(engine.selectedUsers.contains(engine.filtered[login][0])){
                                                    engine.selectedUsers.remove(engine.filtered[login][0]);
                                                  }else{
                                                    engine.selectedUsers.add(engine.filtered[login][0]);
                                                  }
                                                });
                                                if(engine.selectedUsers.isEmpty){engine.filterUsers();}
                                              },
                                            ),
                                          ),
                                          Text(
                                            "${engine.filtered[login][0]["login"]} • ${engine.filtered[login][0]["address"].replaceAll("${engine.filtered[login][0]["login"]}@", "")}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      engine.selectedUsers.length < 2
                                      ? Row(
                                        children: [
                                          IconButton(
                                              onPressed: () async {
                                                await Clipboard.setData(ClipboardData(text: engine.filtered[login][0]["address"]));
                                              },
                                              icon: Icon(Icons.copy_rounded)
                                          ),
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
                                      ) : Container()
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
                            child: Container(
                              height: 61,
                              child: Padding(
                                padding: EdgeInsets.only(left:5, right: 5,bottom: 5),
                                child: TextField(
                                  controller: engine.userL,
                                  maxLines:null,
                                  expands: false,
                                  minLines: 1,
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
                                    if(value.contains("\n")){
                                      setState(() {
                                        engine.multiUserCreate = true;
                                        engine.userMessage = "${value.split('\n').length} users pasted";
                                      });
                                    }else{
                                      if(value.contains("	")){
                                      if(engine.userL.text.split("	")[0].contains("@")){
                                        engine.userP.text = value.split("@")[1].split("	")[1];
                                        engine.userL.text = value.split("@")[0];

                                      }else{
                                        engine.userL.text = value.split("	")[0];
                                        engine.userP.text = value.split("	")[1];
                                      }
                                        setState(() {
                                          engine.userMessage = "User will be created as ${engine.normUsername(value.split("	")[0])}";
                                        });
                                      }
                                      setState(() {
                                        engine.multiUserCreate = false;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person_rounded),
                                    labelText: 'Username',
                                    border: OutlineInputBorder(),
                                  ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(padding: EdgeInsets.all(15), child: engine.userErrors.isEmpty ? Icon(Icons.info_outline_rounded) : Icon(Icons.error_rounded)),
                            Container(
                              height: 54,
                              width: scaffoldWidth - 62,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      child: Text(
                                        engine.userErrors.isEmpty
                                            ? engine.userMessage
                                            : engine.userErrors[0],
                                      )
                                  ),

                                  engine.multiUserCreate
                                      ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: FilledButton(
                                          onPressed: () {
                                            showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) => AlertDialog(
                                                content: Container(
                                                  constraints: BoxConstraints(
                                                    maxHeight: 300
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                        children: engine.userL.text.split('\n').map((userline){
                                                          if(userline.split("	")[0].length < 4 && userline.split("	")[1].length < 4){
                                                            return Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 2),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      "Empty line (ignored)",
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Theme.of(context).colorScheme.error
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }else {
                                                            if(userline.split("	")[0].length > 4 && !userline.contains("	")){
                                                              return Padding(
                                                                padding: EdgeInsets.symmetric(vertical: 2),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        userline.split("	")[0]
                                                                    ),
                                                                    SizedBox(width: 25,),
                                                                    Text(
                                                                        "[Random password]"
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            }else {
                                                              return Padding(
                                                                padding: EdgeInsets.symmetric(vertical: 2),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        userline.split("	")[0]
                                                                    ),
                                                                    SizedBox(width: 25,),
                                                                    Text(
                                                                        userline.split("	")[1]
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        ).toList()
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      FilledButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text(
                                                            'Done',
                                                          )
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'List users',
                                            style: TextStyle(color: Theme.of(context).colorScheme.background),
                                          )
                                      )
                                  ):Container(),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Builder(
                                builder: (context) {
                                  return Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: engine.labels.map((label) {
                                        return GestureDetector(
                                          onTap: () {
                                            for(int i=0; i < label["domains"].length; i++){
                                              if(engine.glowDomains.containsKey(label["domains"][i])){
                                                if(engine.glowDomains[label["domains"][i]].contains(label["name"])){
                                                  engine.glowDomains[label["domains"][i]].remove(label["name"]);
                                                  if(engine.glowDomains[label["domains"][i]].length == 0){
                                                    engine.glowDomains.remove(label["domains"][i]);
                                                  }
                                                }else{
                                                  engine.glowDomains[label["domains"][i]].add(label["name"]);
                                                }
                                              }else{
                                                engine.glowDomains[label["domains"][i]] = [];
                                                engine.glowDomains[label["domains"][i]].add(label["name"]);
                                              }
                                            }
                                            if(engine.selectedLabels.contains(label["name"])){
                                              engine.selectedLabels.remove(label["name"]);
                                            }else{
                                              engine.selectedLabels.add(label["name"]);
                                            }
                                            setState(() {});
                                          },
                                          child: Chip(
                                            backgroundColor: engine.selectedLabels.contains(label["name"])
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                            label: Text(
                                              "${label["name"]}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: engine.selectedLabels.contains(label["name"])
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Container(
                          height: scaffoldHeight - 290,
                          child: SingleChildScrollView(
                            child: Builder(
                                builder: (context) {
                                  List chips = engine.creationDomains..sort((a, b) => a["name"].compareTo(b["name"]));
                                  return Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: chips.map((crD) {
                                      if(engine.availables[crD["server"]]){
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
                                            side: BorderSide(
                                              width: engine.glowDomains.containsKey(crD["name"])?2:1,
                                              strokeAlign: engine.glowDomains.containsKey(crD["name"])?0:-1,
                                              color: MaterialStateColor.resolveWith((states) => engine.glowDomains.containsKey(crD["name"])?Theme.of(context).colorScheme.primary:Colors.grey),
                                            ),
                                            backgroundColor: engine.userDomains.contains(crD)
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                            label: Text(
                                              "${crD["name"]}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: engine.userDomains.contains(crD)
                                                    ? Theme.of(context).colorScheme.background
                                                    : MaterialStateColor.resolveWith((states) => engine.glowDomains.containsKey(crD["name"])?Theme.of(context).colorScheme.primary:Colors.grey),
                                              ),
                                            ),
                                            elevation: engine.glowDomains.containsKey(crD["name"])?55:5.0,
                                          ),
                                        );
                                      }else{
                                        return Chip(
                                          backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                          label: Text(
                                            "${crD["name"]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey
                                            ),
                                          ),
                                          elevation: 5.0,
                                        );
                                      }
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
                              engine.newbieDomains = engine.userDomains.map((domain){return domain["name"];}).toList();
                              engine.createUser();
                              Navigator.pop(topContext);
                            }
                                : null,
                            child: Text(
                                (engine.userDomains.length > 1 ||engine.multiUserCreate)? "Create users" : "Create user"
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