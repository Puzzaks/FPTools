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
  Future<String?> getClipboardData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
  String formatSize(int speed) {
    if (speed < 1024) {
      return '${speed}B';
    } else if (speed < 10240) {
      double speedKb = speed / 1024;
      return '${speedKb.toStringAsFixed(2)}KB';
    } else if (speed < 1048576) {
      double speedKb = speed / 1024;
      return '${speedKb.toStringAsFixed(1)}KB';
    } else if (speed < 10485760) {
      double speedMb = speed / 1048576;
      return '${speedMb.toStringAsFixed(2)}MB';
    } else if (speed < 104857600) {
      double speedMb = speed / 1048576;
      return '${speedMb.toStringAsFixed(1)}MB';
    } else {
      double speedMb = speed / 1048576;
      return '${speedMb.toInt()}MB';
    }
  }

  String timePassed(time, {bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(DateTime.parse(time));
    if (((difference.inDays / 7) / 4).floor() > 1) {
      return '${((difference.inDays / 7) / 4).floor()} month ago';
    } else if (((difference.inDays / 7) / 4).floor() >= 1) {
      return (numericDates) ? '1 month ago' : 'Last month';
    } else if ((difference.inDays / 7).floor() > 1) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 2) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
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
          if(engine.toOpenUCM){
            engine.toOpenUCM = false;
            engine.userErrors.clear();
            if(engine.allowClipboard){
              getClipboardData().then((value){
                if(value!.contains("\n")){
                  engine.multiUserCreate = true;
                  engine.userMessage = "${value.split('\n').length} users pasted";
                  engine.userL.text = value;
                }else{
                  if(value.contains("	")){
                    if(engine.userL.text.split("	")[0].contains("@")){
                      engine.userP.text = value.split("@")[1].split("	")[1];
                      engine.userL.text = value.split("@")[0];
                    }else{
                      engine.userP.text = value.split("	")[1];
                      engine.userL.text = value.split("	")[0];
                    }
                    engine.userMessage = "User will be created as ${engine.normUsername(value.split("	")[0])}";
                  }else{
                    engine.userL.text = value;
                  }
                  engine.multiUserCreate = false;
                }
              });
            }else{
              engine.userL.text = "";
              engine.userErrors.add("Enter valid username");
              engine.userP.text = "";
              engine.multiUserCreate = false;
              engine.userErrors = [];
            }
            engine.userErrors.add("No domains selected");
            engine.userCreateMode = true;
            engine.glowDomains = {};
            engine.selectedLabels.clear();
            engine.userDomains.clear();
            engine.creationDomains = [];
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
                MaterialPageRoute(builder: (context) => const NewUserPage()),
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
              floatingActionButton: !engine.domainsLoading
                ? FloatingActionButton(
                onPressed: () async {
                  engine.userErrors.clear();
                  if(engine.allowClipboard){
                    await getClipboardData().then((value){
                      if(value!.contains("\n")){
                        engine.multiUserCreate = true;
                        engine.userMessage = "${value.split('\n').length} users pasted";
                        engine.userL.text = value;
                      }else{
                        if(value.contains("	")){
                          if(engine.userL.text.split("	")[0].contains("@")){
                            engine.userP.text = value.split("@")[1].split("	")[1];
                            engine.userL.text = value.split("@")[0];
                          }else{
                            engine.userL.text = value.split("	")[0];
                            engine.userP.text = value.split("	")[1];
                          }
                          engine.userMessage = "User will be created as ${engine.normUsername(value.split("	")[0])}";
                        }else{
                          engine.userL.text = value;
                        }
                        engine.multiUserCreate = false;
                      }
                    });
                  }else{
                    engine.userL.text = "";
                    engine.userErrors.add("Enter valid username");
                    engine.userP.text = "";
                    engine.multiUserCreate = false;
                  }
                  engine.userErrors.add("No domains selected");
                  engine.userCreateMode = true;
                  engine.glowDomains = {};
                  engine.selectedLabels.clear();
                  engine.userDomains.clear();
                  engine.creationDomains = [];
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
                    MaterialPageRoute(builder: (context) => const NewUserPage()),
                  );
                },
                tooltip: "Add user",
                child: const Icon(Icons.add_rounded),
              ):null,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextField(
                      controller: engine.userSearch,
                      onChanged: (value) {
                        engine.filterUsers();
                      },
                      autofocus: true,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 5),
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
                              icon: const Icon(Icons.clear_rounded)
                          ) : null,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded),
                        labelText: 'Search users',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
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
                          const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.warning_rounded)),
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
                              const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.warning_rounded)),
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
                                  padding: engine.filtered[login].length > 1 ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  child: engine.filtered[login].length > 1
                                        ? ExpansionTileTheme(
                                        data: const ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15)),
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
                                                            ? const Icon(Icons.remove_done_rounded)
                                                            : const Icon(Icons.done_all_rounded)
                                                      ),
                                                      Text(
                                                        "${(engine.selectedUsers.isNotEmpty&&engine.userSearch.text.isEmpty)? "Selected":engine.filtered[login][0]["login"]}${(engine.selectedUsers.isNotEmpty&&engine.userSearch.text.isEmpty)?"":" • ${engine.filtered[login].length} domains"}${engine.selectedUsers.isNotEmpty?" • ${engine.selectedUsers.length} ${(engine.selectedUsers.isNotEmpty&&engine.userSearch.text.isEmpty)?"total":"selected"}":""}${engine.hasVoiso(engine.filtered[login][0]["login"])?" • Has Voiso":""}",
                                                        style:  TextStyle(fontSize: 16,
                                                            fontFamily: engine.demoMode?"Flow":null),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      engine.hasVoiso(engine.filtered[login][0]["login"])?IconButton(
                                                          onPressed: () async {
                                                            engine.voisoSearch.text = engine.filtered[login][0]["login"];
                                                            engine.filterVoisoUsers();
                                                            setState(() {
                                                              engine.screenIndex = 4;
                                                            });
                                                          },
                                                          icon: const Icon(Icons.dialer_sip_rounded)
                                                      ):Container(),
                                                      IconButton(
                                                          onPressed: () async {
                                                            await Clipboard.setData(ClipboardData(text: engine.filtered[login][0]["login"]));
                                                          },
                                                          icon: const Icon(Icons.copy_rounded)
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
                                                                      padding: const EdgeInsets.only(top: 10),
                                                                      child: TextField(
                                                                        controller: engine.updatePassword,
                                                                        onChanged: (value) {
                                                                        },
                                                                        decoration: const InputDecoration(
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
                                                          icon: const Icon(Icons.edit_rounded)
                                                      ),
                                                      IconButton(
                                                          onPressed: () {
                                                        showDialog<String>(
                                                          context: context,
                                                          builder: (BuildContext context) => AlertDialog(
                                                            icon: const Icon(Icons.delete_rounded),
                                                            title: const Text('Confirm deletion'),
                                                            content: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text('You are about to delete ${accounts.length} accounts:'),
                                                                Container(
                                                                  constraints: const BoxConstraints(maxHeight: 120),
                                                                  child: SingleChildScrollView(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: accounts.map((account) {
                                                                        return Text(" • ${account["address"]}");
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Text('Confirm deletion please.'),
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
                                                      }, icon: const Icon(Icons.delete_rounded))
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
                                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                    child: Stack(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(right: 5,top:4,bottom:4),
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
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "${account["address"]}",
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                      fontFamily: engine.demoMode?"Flow":null
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${account["size"]==0?"Empty":formatSize(account["size"])} • Created ${timePassed(account["created_at"])}",
                                                                  style: const TextStyle(fontSize: 14,color: Colors.grey),
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: SingleChildScrollView(
                                                                scrollDirection: Axis.horizontal,
                                                                child: Row(
                                                                  children: engine.getUserLabels(account["address"].split("@")[1]).map((label){
                                                                    return Padding(
                                                                      padding: const EdgeInsets.only(left: 10),
                                                                      child: Chip(
                                                                        labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                                        padding: const EdgeInsets.all(6),
                                                                        backgroundColor: Colors.transparent,
                                                                        side: const BorderSide(
                                                                            color: Colors.transparent
                                                                        ),
                                                                        elevation: 5,
                                                                        label: Text(label),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            engine.selectedUsers.isEmpty
                                                                ? Row(
                                                              children: [
                                                                IconButton(
                                                                    onPressed: () async {
                                                                      await Clipboard.setData(ClipboardData(text: account["address"]));
                                                                    },
                                                                    icon: const Icon(Icons.copy_rounded)
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
                                                                                padding: const EdgeInsets.only(top: 10),
                                                                                child: TextField(
                                                                                  controller: engine.updatePassword,
                                                                                  onChanged: (value) {
                                                                                  },
                                                                                  decoration: const InputDecoration(
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
                                                                    },
                                                                    icon: const Icon(Icons.edit_rounded)
                                                                ),
                                                                IconButton(
                                                                    onPressed: () {
                                                                  showDialog<String>(
                                                                    context: context,
                                                                    builder: (BuildContext context) => AlertDialog(
                                                                      icon: const Icon(Icons.delete_rounded),
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
                                                                },
                                                                    icon: const Icon(Icons.delete_rounded)
                                                                )
                                                              ],
                                                            ) : Container()
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            )))
                                      : Stack(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 5,top:4,bottom:4),
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
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${engine.filtered[login][0]["address"]}",
                                                style: TextStyle(fontSize: 16,
                                                    fontFamily: engine.demoMode?"Flow":null),
                                              ),
                                              Text(
                                                "${engine.filtered[login][0]["size"]==0?"Empty":formatSize(engine.filtered[login][0]["size"])} • Created ${timePassed(engine.filtered[login][0]["created_at"])}${engine.hasVoiso(engine.filtered[login][0]["login"])?" • Has Voiso":""}",
                                                style: const TextStyle(fontSize: 14,color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: engine.getUserLabels(engine.filtered[login][0]["address"].replaceAll("${engine.filtered[login][0]["login"]}@", "")).map((label){
                                                    return Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: Chip(
                                                        labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                        padding: const EdgeInsets.all(6),
                                                        backgroundColor: Colors.transparent,
                                                        side: const BorderSide(
                                                            color: Colors.transparent
                                                        ),
                                                        elevation: 5,
                                                        label: Text(label),
                                                      ),
                                                    );
                                                  }).toList(),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                      engine.selectedUsers.length < 2
                                          ? Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          engine.hasVoiso(engine.filtered[login][0]["login"])?IconButton(
                                              onPressed: () async {
                                                engine.voisoSearch.text = engine.filtered[login][0]["login"];
                                                engine.filterVoisoUsers();
                                                setState(() {
                                                  engine.screenIndex = 4;
                                                });
                                              },
                                              icon: const Icon(Icons.dialer_sip_rounded)
                                          ):Container(),
                                          IconButton(
                                              onPressed: () async {
                                                await Clipboard.setData(ClipboardData(text: engine.filtered[login][0]["address"]));
                                              },
                                              icon: const Icon(Icons.copy_rounded)
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
                                                      padding: const EdgeInsets.only(top: 10),
                                                      child: TextField(
                                                        controller: engine.updatePassword,
                                                        onChanged: (value) {
                                                        },
                                                        decoration: const InputDecoration(
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
                                          }, icon: const Icon(Icons.edit_rounded)),
                                          IconButton(onPressed: () {
                                            showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) => AlertDialog(
                                                icon: const Icon(Icons.delete_rounded),
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
                                          }, icon: const Icon(Icons.delete_rounded))
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
                        ? const Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(15),
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
  final FocusNode _focusNode = FocusNode();
  bool ctrlPress = false;
  bool toEscape = false;
  @override
  Widget build(BuildContext topContext) {
    final defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
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
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double scaffoldHeight = constraints.maxHeight;
            double scaffoldWidth = constraints.maxWidth;
            return MaterialApp(
              theme: ThemeData(
                colorScheme: lightColorScheme ?? defaultLightColorScheme,
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme ?? defaultDarkColorScheme,
                useMaterial3: true,
              ),
              themeMode: ThemeMode.system,
              debugShowCheckedModeBanner: false,
              home: Consumer<fastEngine>(builder: (context, engine, child) {
                engine.userCreateMode = true;
                engine.fetchTimer.reset();
                final List chips = engine.creationDomains..sort((a, b) => a["name"].compareTo(b["name"]));
                ServicesBinding.instance.keyboard.addHandler((KeyEvent event){
                  if(event is KeyUpEvent && event.logicalKey.keyLabel == "S" && ctrlPress && engine.userErrors.isEmpty){
                    engine.newbieDomains = engine.userDomains.map((domain){return domain["name"];}).toList();
                    engine.createUser().then((value){toEscape = true;});
                  }
                  if(event.logicalKey.keyLabel == "Control Left"){
                    if (event is KeyUpEvent) {
                      ctrlPress = false;
                      return true;
                    }else if(event is KeyDownEvent) {
                      ctrlPress = true;
                      return true;
                    }
                  }
                  return false;
                });
                return Scaffold(
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
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
                                    padding: const EdgeInsets.only(left:5, right: 5,bottom: 5),
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
                                        if(engine.userExists(value)){
                                          engine.userErrors.add("Existing user found");
                                        }else{
                                          engine.userErrors.remove("Existing user found");
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
                                              engine.userP.text = value.split("	")[1];
                                              engine.userL.text = value.split("	")[0];
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
                                      decoration: const InputDecoration(
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
                                    padding: const EdgeInsets.only(right: 5, left: 5,bottom: 5,),
                                    child: TextField(
                                      controller: engine.userP,
                                      onChanged: (value) {

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
                            elevation: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(padding: const EdgeInsets.all(15), child: engine.userErrors.isEmpty ? const Icon(Icons.info_outline_rounded) : const Icon(Icons.error_rounded)),
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
                                      Row(
                                        children: [
                                          engine.userDomains.isEmpty
                                              ? Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: FilledButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      engine.userDomains.addAll(engine.creationDomains);
                                                    });
                                                  },
                                                  child: Text(
                                                    'Select all domains',
                                                    style: TextStyle(color: Theme.of(context).colorScheme.background),
                                                  )
                                              )
                                          )
                                              :Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: FilledButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      engine.userDomains.clear();
                                                    });
                                                  },
                                                  child: Text(
                                                    'Clear selection',
                                                    style: TextStyle(color: Theme.of(context).colorScheme.background),
                                                  )
                                              )
                                          ),
                                          engine.multiUserCreate
                                              ? Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: FilledButton(
                                                  onPressed: () {
                                                    showDialog<String>(
                                                      context: context,
                                                      builder: (BuildContext context) => AlertDialog(
                                                        content: Container(
                                                          constraints: const BoxConstraints(
                                                              maxHeight: 300
                                                          ),
                                                          child: SingleChildScrollView(
                                                            child: Column(
                                                                children: engine.userL.text.split('\n').map((userline){
                                                                  if(userline.split("	")[0].length < 4 && userline.split("	").length == 1){
                                                                    return Padding(
                                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            "Empty line",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Theme.of(context).colorScheme.error
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }else{
                                                                    if(userline.split("	")[0].length > 4 && !userline.contains("	")){
                                                                      String uline = "";
                                                                      if(userline.split("	")[0].contains("@")){
                                                                        uline = userline.split("	")[0].split("@")[0];
                                                                      }else if(userline.contains("	")){
                                                                        uline = userline.split("	")[0];
                                                                      }else{
                                                                        uline = engine.normUsername(userline);
                                                                      }
                                                                      if(engine.userExists(uline)){
                                                                        return Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                "User exists on ${engine.existDomains[0]}",
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Theme.of(context).colorScheme.error
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }else{
                                                                        return Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                  engine.userExists(uline)?"[User exists]":uline
                                                                              ),
                                                                              const SizedBox(width: 25,),
                                                                              const Text(
                                                                                  "[Random password]"
                                                                              )
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }
                                                                    }else {
                                                                      String uline = "";
                                                                      if(userline.split("	")[0].contains("@")){
                                                                        uline = userline.split("	")[0].split("@")[0];
                                                                      }else{
                                                                        uline = userline.split("	")[0];
                                                                      }
                                                                      if(engine.userExists(uline)){
                                                                        return Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                "User exists on ${engine.existDomains[0]}",
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Theme.of(context).colorScheme.error
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }else{
                                                                        return Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                  engine.userExists(uline)?"[User exists]":uline
                                                                              ),
                                                                              const SizedBox(width: 25,),
                                                                              Text(
                                                                                  userline.split("	")[1]
                                                                              )
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }
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
                                                                  child: const Text(
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
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                                            onDoubleTap: (){
                                              for(int i=0; i < label["domains"].length; i++){
                                                if(engine.glowDomains.containsKey(label["domains"][i])){
                                                  if(engine.glowDomains[label["domains"][i]].contains(label["name"])){
                                                    engine.glowDomains[label["domains"][i]].remove(label["name"]);
                                                    for(int s = 0; s < engine.creationDomains.length; s++){
                                                      if(label["domains"][i] == engine.creationDomains[s]["name"]){
                                                        engine.userDomains.remove(engine.creationDomains[s]);
                                                      }
                                                    }
                                                    if(engine.glowDomains[label["domains"][i]].length == 0){
                                                      engine.glowDomains.remove(label["domains"][i]);
                                                      for(int s = 0; s < engine.creationDomains.length; s++){
                                                        if(label["domains"][i] == engine.creationDomains[s]["name"]){
                                                          engine.userDomains.remove(engine.creationDomains[s]);
                                                        }
                                                      }
                                                    }
                                                  }else{
                                                    engine.glowDomains[label["domains"][i]].add(label["name"]);
                                                    for(int s = 0; s < engine.creationDomains.length; s++){
                                                      if(label["domains"][i] == engine.creationDomains[s]["name"]){
                                                        engine.userDomains.add(engine.creationDomains[s]);
                                                      }
                                                    }
                                                  }
                                                }else{
                                                  engine.glowDomains[label["domains"][i]] = [];
                                                  engine.glowDomains[label["domains"][i]].add(label["name"]);
                                                  for(int s = 0; s < engine.creationDomains.length; s++){
                                                    if(label["domains"][i] == engine.creationDomains[s]["name"]){
                                                      engine.userDomains.add(engine.creationDomains[s]);
                                                    }
                                                  }
                                                }
                                              }
                                              if(engine.userDomains.isEmpty){
                                                engine.userErrors.add("No domains selected");
                                              }else{
                                                engine.userErrors.remove("No domains selected");
                                              }
                                            },
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
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            child: Container(
                              height: scaffoldHeight - 290,
                              child: SingleChildScrollView(
                                child: Builder(
                                    builder: (context) {
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
                                                if(engine.userExists(engine.userL.text)){
                                                  if(!engine.multiUserCreate && !engine.userErrors.contains("Existing user found")){engine.userErrors.add("Existing user found");}
                                                }else{
                                                  engine.userErrors.remove("Existing user found");
                                                }

                                                if(engine.userDomains.isEmpty){
                                                  setState(() {
                                                    engine.userErrors.add("No domains selected");
                                                  });
                                                }else{
                                                  setState(() {
                                                    engine.userErrors.remove("No domains selected");
                                                  });
                                                }
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
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilledButton(
                                onPressed: () {
                                  Navigator.pop(this.context);
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
                                  Navigator.pop(this.context);
                                }
                                    : null,
                                child: Text(
                                    (engine.multiUserCreate)? "Create users" : "Create user"
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
    }),
    );
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}