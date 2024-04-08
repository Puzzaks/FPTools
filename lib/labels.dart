import 'package:collection/collection.dart';
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
                  engine.tempLabel.clear();
                  engine.labelName.text = "";
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          children: engine.labels.map((label) {
                            int thisIndex = 0;
                            for(int i=0;i<engine.labels.length;i++){
                              if(engine.labels[i]["name"]==label["name"]){
                                thisIndex = i;
                              }
                            }
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
                                                  label["name"]??"Error loading name",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                                Text(
                                                  "${label["domains"].length} domains",
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: thisIndex > 0 ?() {
                                                  setState(() {
                                                    engine.labels.swap(thisIndex, thisIndex - 1);
                                                  });
                                                }:null,
                                                icon: Icon(Icons.arrow_upward_rounded)
                                            ),
                                            IconButton(
                                                onPressed: thisIndex < (engine.labels.length - 1)?() {
                                                  setState(() {
                                                    engine.labels.swap(thisIndex, thisIndex + 1);
                                                  });
                                                }:null,
                                                icon: Icon(Icons.arrow_downward_rounded)
                                            ),
                                            FilledButton(
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
                                                  engine.labelName.text = label["name"]??"";
                                                  engine.tempLabel = label;
                                                  for(int i = 0; i < label["domains"].length; i++){
                                                    if(!engine.tempLabel["domains"].contains(label["domains"][i])){
                                                      engine.tempLabel["domains"].add(label["domains"][i]);
                                                    }
                                                  }
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => EditLabelPage()),
                                                  );
                                                },
                                                child: Text(
                                                  'Edit',
                                                  style: TextStyle(color: Theme.of(context).colorScheme.background),
                                                ))
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

class EditLabelPage extends StatefulWidget {
  const EditLabelPage({super.key});
  @override
  EditLabelPageState createState() => EditLabelPageState();
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
                bool isLabelN = false;
                bool isLabel(name){
                  for(int i=0;i<engine.labels.length;i++){
                    if(engine.labels[i]["name"]==name){
                      isLabelN = true;
                      return true;
                    }
                  }
                  isLabelN = false;
                  return false;
                }
                isLabelN = isLabel(engine.labelName.text);
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
                              isLabelN?"Edit label":"Add new label",
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
                                      setState(() {
                                        isLabelN = isLabel(value);
                                        engine.tempLabel["name"] = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: engine.labelName.text.isNotEmpty
                                            ? IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isLabelN = false;
                                                engine.labelName.clear();
                                                engine.tempLabel["name"] = "";
                                              });
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
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            child: Container(
                              height: scaffoldHeight - (isLabelN?259:189),
                              child: SingleChildScrollView(
                                child: Builder(
                                    builder: (context) {
                                      List chips = engine.creationDomains..sort((a, b) => a["name"].compareTo(b["name"]));
                                      if(!engine.tempLabel.containsKey("domains")){
                                        engine.tempLabel["domains"] = [];
                                      }
                                      return Wrap(
                                        spacing: 5,
                                        runSpacing: 5,
                                        children: chips.map((crD) {
                                          if(engine.availables[crD["server"]]){
                                            return GestureDetector(
                                              onTap: () {
                                                if(engine.tempLabel["domains"].contains(crD["name"])){
                                                  engine.tempLabel["domains"].remove(crD["name"]);
                                                }else{
                                                  engine.tempLabel["domains"].add(crD["name"]);
                                                }
                                                setState(() {});
                                              },
                                              child: Chip(
                                                backgroundColor: engine.tempLabel["domains"].contains(crD["name"])
                                                    ? Theme.of(context).colorScheme.primary
                                                    : null,
                                                label: Text(
                                                  "${crD["name"]}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: engine.tempLabel["domains"].contains(crD["name"])
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
                      isLabelN
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
                                            "Delete this label",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  FilledButton(
                                      onPressed: () {
                                        for(int i=0;i<engine.labels.length;i++){
                                          if(engine.labels[i]["name"]==engine.labelName.text){
                                            engine.labels.removeAt(i);
                                          }
                                        }
                                        engine.saveLabels().then((value){
                                          Navigator.pop(topContext);
                                        });
                                      },
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)
                                      ),
                                      child: Text(
                                        'Delete',
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
                                onPressed: (engine.labelName.text.isNotEmpty)
                                  ? (){
                                  engine.labels.add({
                                    "name": engine.labelName.text,
                                    "domains": engine.tempLabel["domains"]
                                  });
                                  engine.saveLabels().then((value){
                                    Navigator.pop(topContext);
                                  });
                                } : null,
                                child: Text(
                                    "Save label"
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