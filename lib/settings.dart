import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'engine.dart';
import 'network.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  @override
  void initState() {
    super.initState();
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
        home: Consumer<fastEngine>(builder: (context, engine, child) {
          return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double scaffoldHeight = constraints.maxHeight;
                double scaffoldWidth = constraints.maxWidth;
                return Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                        ):Container(), // Loading
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
                        ), // Less Users
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
                                      "Check for duplicates",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text(
                                      "Disallow creation of existing users",
                                    )
                                  ],
                                ),
                                Switch(
                                  thumbIcon: thumbIcon,
                                  value: engine.allowDuplicates,
                                  onChanged: (bool value) {
                                    setState(() {
                                      engine.allowDuplicates = value;
                                      engine.saveToggle("allowDuplicates", value);
                                      engine.filterUsers();
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ), // Duplicates
                        // Card(
                        //   elevation: 2,
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(15),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         const Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text(
                        //               "Read-write mode",
                        //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        //             ),
                        //             Text(
                        //               "Allow writing to the remote DB",
                        //             )
                        //           ],
                        //         ),
                        //         Switch(
                        //           thumbIcon: thumbIcon,
                        //           value: engine.remoteRWMode,
                        //           onChanged: (bool value) {
                        //             setState(() {
                        //               engine.remoteRWMode = value;
                        //               engine.saveToggle("remoteRWMode", value);
                        //             });
                        //           },
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ), // Admin
                        Card(
                          elevation: 2,
                          child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Use proxy",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          Text(
                                            "Proxy all apps traffic through SOCKS",
                                          )
                                        ],
                                      ),
                                      Switch(
                                        thumbIcon: thumbIcon,
                                        value: engine.isProxyUsed,
                                        onChanged: (bool value) {
                                          if(value){
                                            engine.saveProxy();
                                          }else{
                                            setState(() {
                                              engine.proxyStatus = "Disabled!";
                                            });
                                            HttpOverrides.global = CertificateOverride();
                                          }
                                          engine.isProxyUsed = value;
                                          engine.saveToggle("isProxyUsed", value);
                                        },
                                      )
                                    ],
                                  ),
                                  engine.isProxyUsed
                                      ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(left:5, top: 10,bottom: 5, right: 5),
                                              child: TextField(
                                                controller: engine.proxyAddr,
                                                onChanged: (value) {
                                                  engine.saveProxy();
                                                },
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(Icons.link_rounded),
                                                  labelText: 'IP',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(left:5, top: 10,bottom: 5, right: 5),
                                              child: TextField(
                                                controller: engine.proxyPort,
                                                onChanged: (value) {
                                                  engine.saveProxy();
                                                },
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(Icons.link_rounded),
                                                  labelText: 'Port',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(left:5, top: 5,bottom: 5,right: 5),
                                              child: TextField(
                                                controller: engine.proxyUser,
                                                onChanged: (value) {
                                                  engine.saveProxy();
                                                },
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(Icons.person_rounded),
                                                  labelText: 'Login',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(left:5, right:5, top: 5,bottom: 5),
                                                child: TextField(
                                                  controller: engine.proxyPassword,
                                                  onChanged: (value) {
                                                    engine.saveProxy();
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
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    engine.proxyStatus,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                      : Container()
                                ],
                              )
                          ),
                        ), // Proxy
                        Card(
                          elevation: 2,
                          child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Voiso Settings",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          Text(
                                            "Enter credentials for Voiso",
                                          )
                                        ],
                                      ),
                                      Container(
                                        width: 200,
                                        child: Padding(
                                          padding: EdgeInsets.only(left:5,bottom: 5),
                                          child: TextField(
                                            controller: engine.voisoCluster,
                                            onChanged: (value) {
                                              engine.saveVoisoKeys();
                                            },
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.dashboard),
                                              labelText: 'Cluster ID',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 5,bottom: 5,),
                                        child: TextField(
                                          controller: engine.voisoKeyUser,
                                          onChanged: (value) {
                                            engine.saveVoisoKeys();
                                          },
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.person_rounded),
                                            labelText: 'User Key',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5,bottom: 5, ),
                                        child: TextField(
                                          controller: engine.voisoKeyCenter,
                                          onChanged: (value) {
                                            engine.saveVoisoKeys();
                                          },
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.corporate_fare_rounded),
                                            labelText: 'Center Key',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                          ),
                        ), // Voiso
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