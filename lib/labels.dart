import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'engine.dart';

class LabelsPage extends StatefulWidget {
  const LabelsPage({super.key});
  @override
  LabelsPageState createState() => LabelsPageState();
}

class LabelsPageState extends State<LabelsPage> {
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
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  engine.creationDomains.clear();
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
                    MaterialPageRoute(builder: (context) => EditLabelPage()),
                  );
                },
                tooltip: "Add label",
                child: Icon(Icons.add_rounded),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: TextField(
                      controller: engine.labelSearch,
                      onChanged: (value) {
                        // engine.filterUsers();
                      },
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: engine.labelSearch.text.isNotEmpty
                              ? IconButton(
                              onPressed: () {
                                engine.labelSearch.clear();
                              },
                              icon: Icon(Icons.clear_rounded)
                          ) : null,
                        ),
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search labels',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ),
                  Container(
                    height: engine.labels.isEmpty?null:scaffoldHeight - 66,
                    child: Column(
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

class EditLabelPage extends StatefulWidget {
  const EditLabelPage({super.key});
  @override
  EditLabelPageState createState() => EditLabelPageState();
}
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
class EditLabelPageState extends State<EditLabelPage> {
  @override
  void initState() {
    super.initState();
  }
  bool isColor(String color) {
    RegExp hex = RegExp(
        r'^#([\da-f]{3}){1,2}$|^#([\da-f]{4}){1,2}$|(rgb|hsl)a?\((\s*-?\d+%?\s*,){2}(\s*-?\d+%?\s*,?\s*\)?)(,\s*(0?\.\d+)?|1)?\)');
    if (hex.hasMatch(color))
      return true;
    else
      return false;
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
                              "Add new label",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: TextField(
                                    controller: engine.labelName,
                                    onChanged: (value) {
                                      // engine.filterUsers();
                                    },
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: engine.labelName.text.isNotEmpty
                                            ? IconButton(
                                            onPressed: () {
                                              engine.labelName.clear();
                                            },
                                            icon: Icon(Icons.clear_rounded)
                                        ) : null,
                                      ),
                                      prefixIcon: Icon(Icons.label_rounded),
                                      labelText: 'Label name',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: TextField(
                                    controller: engine.labelColor,
                                    onChanged: (value) {
                                      setState(() {

                                      });
                                    },
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: engine.labelColor.text.isNotEmpty
                                            ? IconButton(
                                            onPressed: () {
                                              engine.labelColor.clear();
                                            },
                                            icon: Icon(Icons.clear_rounded)
                                        ) : null,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.palette_rounded,
                                        color: isColor(engine.labelColor.text)?HexColor(engine.labelColor.text):null,
                                      ),
                                      labelText: 'Label color',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: isColor(engine.labelColor.text)?HexColor(engine.labelColor.text):Colors.grey)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            child: Container(
                              height: scaffoldHeight - 189,
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
                                                backgroundColor: engine.userDomains.contains(crD)
                                                    ? Theme.of(context).colorScheme.primary
                                                    : null,
                                                label: Text(
                                                  "${crD["name"]}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: engine.userDomains.contains(crD)
                                                        ? Theme.of(context).colorScheme.background
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                elevation: 5.0,
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
                                onPressed: null,
                                child: Text(
                                    "Create label"
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