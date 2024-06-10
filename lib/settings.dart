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
                                      "Demo mode",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text(
                                      "Hide sensitive data in UI",
                                    )
                                  ],
                                ),
                                Switch(
                                  thumbIcon: thumbIcon,
                                  value: engine.demoMode,
                                  onChanged: (bool value) {
                                    setState(() {
                                      engine.demoMode = value;
                                      engine.saveToggle("demoMode", value);
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ), // Demo mode
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
                                      "Allow clipboard reading",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text(
                                      "Copy text from clipboard when creating user",
                                    )
                                  ],
                                ),
                                Switch(
                                  thumbIcon: thumbIcon,
                                  value: engine.allowClipboard,
                                  onChanged: (bool value) {
                                    setState(() {
                                      engine.allowClipboard = value;
                                      engine.saveToggle("allowClipboard", value);
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
                                            "Proxy all app traffic through SOCKS",
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
                                              padding: const EdgeInsets.only(left:5, top: 10,bottom: 5, right: 5),
                                              child: TextField(
                                                controller: engine.proxyAddr,
                                                onChanged: (value) {
                                                  engine.saveProxy();
                                                },
                                                decoration: const InputDecoration(
                                                  prefixIcon: Icon(Icons.link_rounded),
                                                  labelText: 'IP',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left:5, top: 10,bottom: 5, right: 5),
                                              child: TextField(
                                                controller: engine.proxyPort,
                                                onChanged: (value) {
                                                  engine.saveProxy();
                                                },
                                                decoration: const InputDecoration(
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
                                              padding: const EdgeInsets.only(left:5, top: 5,bottom: 5,right: 5),
                                              child: TextField(
                                                controller: engine.proxyUser,
                                                onChanged: (value) {
                                                  engine.saveProxy();
                                                },
                                                decoration: const InputDecoration(
                                                  prefixIcon: Icon(Icons.person_rounded),
                                                  labelText: 'Login',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(left:5, right:5, top: 5,bottom: 5),
                                                child: TextField(
                                                  controller: engine.proxyPassword,
                                                  onChanged: (value) {
                                                    engine.saveProxy();
                                                  },
                                                  decoration: const InputDecoration(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Icon(Icons.restart_alt_rounded),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Restart the app",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                            Text(
                                              "If you have issues loading anything",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    FilledButton(
                                        onPressed: engine.loading? null: () {
                                          engine.loadOnLaunch = false;
                                          engine.fetchTimer.reset();
                                          engine.fetchTimer.cancel();
                                          engine.launch();
                                        },
                                        child: Text(
                                          engine.loading?"Loading...":'Restart',
                                          style: TextStyle(color: Theme.of(context).colorScheme.background),
                                        )),
                                  ],
                                ),
                              ],
                            ),
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