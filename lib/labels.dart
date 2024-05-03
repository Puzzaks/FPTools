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
          if(engine.toOpenLCM){
            engine.toOpenLCM = false;
            engine.fetchTimer.reset();
            engine.creationDomains.clear();
            engine.userCreateMode = true;
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
            Future.delayed(Duration.zero, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditLabelPage()),
              );
            });
          }
          engine.userCreateMode = false;
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
              floatingActionButton: engine.domainsLoading?null:FloatingActionButton(
                onPressed: () {
                  engine.creationDomains.clear();
                  engine.userCreateMode = true;
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
                    MaterialPageRoute(builder: (context) => const EditLabelPage()),
                  );
                },
                tooltip: "Add label",
                child: const Icon(Icons.add_rounded),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(5),
                  //   child: TextField(
                  //     controller: engine.labelSearch,
                  //     onChanged: (value) {
                  //       // engine.filterUsers();
                  //     },
                  //     decoration: InputDecoration(
                  //       suffixIcon: Padding(
                  //         padding: const EdgeInsets.only(right: 5),
                  //         child: engine.labelSearch.text.isNotEmpty
                  //             ? IconButton(
                  //             onPressed: () {
                  //               engine.labelSearch.clear();
                  //             },
                  //             icon: const Icon(Icons.clear_rounded)
                  //         ) : null,
                  //       ),
                  //       prefixIcon: const Icon(Icons.search_rounded),
                  //       labelText: 'Search labels',
                  //       border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    height: engine.labels.isEmpty?null:scaffoldHeight,
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
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                                                  engine.saveLabels();
                                                }:null,
                                                icon: const Icon(Icons.arrow_upward_rounded)
                                            ),
                                            IconButton(
                                                onPressed: thisIndex < (engine.labels.length - 1)?() {
                                                  setState(() {
                                                    engine.labels.swap(thisIndex, thisIndex + 1);
                                                  });
                                                  engine.saveLabels();
                                                }:null,
                                                icon: const Icon(Icons.arrow_downward_rounded)
                                            ),
                                            IconButton(
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
                                                  engine.userCreateMode = true;
                                                  engine.tempLabel = label;
                                                  for(int i = 0; i < label["domains"].length; i++){
                                                    if(!engine.tempLabel["domains"].contains(label["domains"][i])){
                                                      engine.tempLabel["domains"].add(label["domains"][i]);
                                                    }
                                                  }
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const EditLabelPage()),
                                                  );
                                                },
                                                icon: const Icon(Icons.edit_rounded)
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  int thisIndex = 0;
                                                  for(int i=0;i<engine.labels.length;i++){
                                                    if(engine.labels[i]["name"]==label["name"]){
                                                      thisIndex = i;
                                                    }
                                                  }
                                                  engine.labels.removeAt(thisIndex);
                                                  engine.saveLabels().then((value){
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
    if (hex.hasMatch(color)) {
      return true;
    } else {
      return false;
    }
  }

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
                engine.userCreateMode = true;
                engine.fetchTimer.cancel();
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
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              isLabelN?"Edit label":"Add new label",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
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
                                        padding: const EdgeInsets.only(right: 5),
                                        child: engine.labelName.text.isNotEmpty
                                            ? IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isLabelN = false;
                                                engine.labelName.clear();
                                                engine.tempLabel["name"] = "";
                                              });
                                            },
                                            icon: const Icon(Icons.clear_rounded)
                                        ) : null,
                                      ),
                                      prefixIcon: const Icon(Icons.label_rounded),
                                      labelText: 'Label name',
                                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                                                style: const TextStyle(
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
                                            "Delete this label",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  FilledButton(
                                      onPressed: () {
                                        int thisIndex = 0;
                                        for(int i=0;i<engine.labels.length;i++){
                                          if(engine.labels[i]["name"]==engine.labelName.text){
                                            thisIndex = i;
                                          }
                                        }
                                      engine.labels.removeAt(thisIndex);
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
                                onPressed: (engine.labelName.text.isNotEmpty)
                                  ? (){
                                  int thisIndex = 0;
                                  bool isNew = true;
                                  for(int i=0;i<engine.labels.length;i++){
                                    if(engine.labels[i]["name"]==engine.labelName.text){
                                      thisIndex = i;
                                      isNew = false;
                                    }
                                  }
                                  if(isNew){
                                    engine.labels.add({
                                      "name": engine.labelName.text,
                                      "domains": engine.tempLabel["domains"]
                                    });
                                  }else{
                                    engine.labels[thisIndex] = {
                                      "name": engine.labelName.text,
                                      "domains": engine.tempLabel["domains"]
                                    };
                                  }

                                  engine.saveLabels().then((value){
                                    Navigator.pop(topContext);
                                  });
                                } : null,
                                child: const Text(
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
  @override
  void dispose() {
    super.dispose();
  }
}