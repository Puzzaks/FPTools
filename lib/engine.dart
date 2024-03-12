import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';
import 'network.dart';

class fastEngine with ChangeNotifier{
  TextEditingController userSearch = TextEditingController(
      text: ""
  );
  Map known = {};
  List allUsers = [];
  Map logins = {};
  Map logs = {};
  Map availables = {};
  List users = [];
  Map filtered = {};
  Map domains = {};
  List userDomains = [];
  List creationDomains = [];
  String action = "Loading...";
  bool loading = false;
  bool loadOnLaunch = false;
  bool displayUsers = true;

  TextEditingController tempL = TextEditingController();
  TextEditingController tempA = TextEditingController();
  TextEditingController tempU = TextEditingController();
  TextEditingController tempP = TextEditingController();

  TextEditingController userL = TextEditingController();
  TextEditingController userP = TextEditingController();
  List userErrors = [];

  bool tempPanelAddReady = false;
  bool tempPanelAddloading = false;

  Future <void> launch() async {
    loading = true; action = "Loading saved data...";
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("displayUsers")){
      displayUsers = prefs.getBool("displayUsers")??true;
    }
    if(prefs.containsKey("known")){
      String memKnown = "";
      memKnown = await prefs.getString("known")??"";
      known = jsonDecode(memKnown);
      if(prefs.containsKey("logins")){
        String memLogs = "";
        memLogs = await prefs.getString("logins")??"";
        logins = jsonDecode(memLogs);
      }
      if(prefs.containsKey("domains")){
        String memDomains = "";
        memDomains = prefs.getString("domains")??"";
        domains = jsonDecode(memDomains);
      }
      for(int i=0; i<known.length;i++){
        var keyVar = known[known.keys.toList()[i]]["addr"];
        action = "Checking connection to $keyVar...";
        notifyListeners();
        await checkConnect(keyVar).then((value) async {
          availables[keyVar] = value;
          if(value){
            if(logins.containsKey(keyVar)){
              checkLogin(keyVar);
            }
          }
        });
      }
      for(int i=0; i<known.length;i++){
        var keyVar = known[known.keys.toList()[i]]["addr"];
        if(logins.containsKey(keyVar)){
          action = "Checking login with $keyVar...";
          notifyListeners();
          if(availables[keyVar]){
            checkLogin(keyVar);
          }
        }
      }
      action = "Loading users...";
      notifyListeners();
      await getAllUsers().then((value){
        filterUsers();
      });
      loading = false;
      notifyListeners();
    }
    loading = false;
    notifyListeners();
  }

  Future deleteUser(user) async {
    loading = true;
    action = "Deleting ${user["address"]}...";
    notifyListeners();
    var userDomain = user["address"].replaceAll("${user["login"]}@", "");
    var domainIP = "";
    for(int a=0; a < known.length;a++){
      for(int i=0; i < domains[known.keys.toList()[a]].length;i++){
        if(domains[known.keys.toList()[a]][i]["domain"] == userDomain){
          domainIP = known.keys.toList()[a];
        }
      }
    }
    await checkLogin(domainIP).then((value) async {
      await fastpanelDeleteUser(user["id"], domainIP, logins[domainIP]["token"]).then((value){
        loading = false;
        action = "User ${user["address"]} deleted.";
        notifyListeners();
      });
    });
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }

  Future createUser() async {
    loading = true;
    action = "Creating ${userL.text}...";
    notifyListeners();
    var pass = userP.text == ""?generateRandomString(12):userP.text;
    for(int a=0; a < userDomains.length;a++){
      action = "Creating ${userL.text} on ${userDomains[a]["domain"]}...";
      notifyListeners();
      await fastpanelCreateUser(
          userDomains[a]["id"],
          userDomains[a]["server"],
          userL.text,
          pass,
          logins[userDomains[a]["server"]]["token"]
      ).then((value) async {
        action = "Created ${userL.text} on ${userDomains[a]["domain"]}.";
        notifyListeners();
      });
    }
    await getAllUsers().then((value) async {
      await filterUsers().then((value) async {
        action = "Created ${userL.text}.";
        loading = false;
        notifyListeners();
        await Clipboard.setData(ClipboardData(text: "${userL.text}	$pass"));
        return pass;
      });
    });
  }

  Future saveToggle(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
  Future getDomains(ip) async{
    await checkLogin(ip);
    var out = {};
    await fastpanelDomains(ip, logins[ip]["token"]).then((value) {
      out = value;
    });
    return out;
  }

  Future <String?> checkLogin(ip) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(DateTime.parse(logins[ip]["data"]["expire"]).difference(DateTime.now()).inMinutes < 1){
      await fastpanelLogin(ip, known[ip]["user"], known[ip]["pass"]).then((value) async {
        availables[ip] = true;
        if(value.containsKey("token")){
          logins[ip] = value;
          await prefs.setString("logins", jsonEncode(logins));
          notifyListeners();
        }
      });
    }
  }
  Future <void> checkAndCacheBrand() async{
    tempPanelAddloading = true;
    tempPanelAddReady = false;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await fastpanelLogin(tempA.text, tempU.text, tempP.text).then((value) async {
      if(value.containsKey("token")){
        logins[tempA.text] = value;
        tempPanelAddReady = true;
        tempPanelAddloading = false;
        availables[tempA.text] = true;
        await prefs.setString("logins", jsonEncode(logins));
        notifyListeners();
      }else{
        tempPanelAddloading = false;
        tempPanelAddReady = false;
        notifyListeners();
      }
    });
  }
  Future<bool> saveBrand() async{
    known[tempA.text] = {
      "name": tempL.text,
      "addr": tempA.text,
      "user": tempU.text,
      "pass": tempP.text,
    };
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("known", jsonEncode(known));
    notifyListeners();
    return true;
  }
  Future<bool> saveBrandList() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("known", jsonEncode(known));
    notifyListeners();
    return true;
  }
  Future <Map> filterUsers() async {
    loading = true;
    notifyListeners();
    filtered.clear();
    for(int i=0; i < users.length; i++){
      if(!allUsers.contains(users[i]["login"])){
        allUsers.add(users[i]["login"]);
      }
      if(users[i]["login"].contains(userSearch.text)){
        if(displayUsers){
          if(filtered.length < 100){
            if(!filtered.containsKey(users[i]["login"])){
              filtered[users[i]["login"]] = [];
            }
            filtered[users[i]["login"]].add(users[i]);
          }else{
            if(filtered.containsKey(users[i]["login"])){
              filtered[users[i]["login"]].add(users[i]);
            }
          }
        }else {
          if (!filtered.containsKey(users[i]["login"])) {
            filtered[users[i]["login"]] = [];
          }
          filtered[users[i]["login"]].add(users[i]);
        }
      }
    }
    loading = false;
    notifyListeners();
    return filtered;
  }
  Future<List> getAllUsers() async {
    users.clear();
    for(int i=0; i<known.length;i++){
      var keyVar = known[known.keys.toList()[i]]["addr"];
      if(!domains.containsKey(keyVar)){
        domains[keyVar] = [];
      }
      for(int a=0; a<domains[keyVar].length;a++){
        if(logins.containsKey(keyVar)){
          await checkLogin(keyVar).then((huh) async {
            await fastpanelMailboxes(keyVar, domains[keyVar][a], logins[keyVar]["token"]).then((value){
              users.addAll(value["data"]);
            });
          });
        }
      }
    }
    return users;
  }
  Future<bool> saveDomains() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("domains", jsonEncode(domains));
    return true;
  }
}