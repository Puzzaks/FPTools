import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:latinize/latinize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'network.dart';

class Translit {
  final _transliteratedSymbol = <String, String>{
    'А': 'A',
    'Б': 'B',
    'В': 'V',
    'Г': 'G',
    'Д': 'D',
    'Е': 'E',
    'З': 'Z',
    'И': 'I',
    'Й': 'J',
    'К': 'K',
    'Л': 'L',
    'М': 'M',
    'Н': 'N',
    'О': 'O',
    'П': 'P',
    'Р': 'R',
    'С': 'S',
    'Т': 'T',
    'У': 'U',
    'Ф': 'F',
    'Х': 'H',
    'Ц': 'C',
    'Ы': 'Y',
    'а': 'a',
    'б': 'b',
    'в': 'v',
    'г': 'g',
    'д': 'd',
    'е': 'e',
    'з': 'z',
    'и': 'i',
    'й': 'j',
    'к': 'k',
    'л': 'l',
    'м': 'm',
    'н': 'n',
    'о': 'o',
    'п': 'p',
    'р': 'r',
    'с': 's',
    'т': 't',
    'у': 'u',
    'ф': 'f',
    'х': 'h',
    'ц': 'c',
    'ы': 'y',
    "'": '',
    '"': '',
  };

  final _complicatedSymbols = <String, String>{
    'Є': 'Ye',
    'є': 'ye',
    'Ґ': 'G',
    'ґ': 'g',
    'ё': 'yo',
    'Ё': 'Yo',
    'І': 'I',
    'і': 'i',
    'Ї': 'Yi',
    'ї': 'yi',
    'Ж': 'Zh',
    'Щ': 'Shhch',
    'Ш': 'Shh',
    'Ч': 'Ch',
    'Э': "Eh'",
    'Ю': 'Yu',
    'Я': 'Ya',
    'ё': 'yo',
    'ж': 'zh',
    'щ': 'shhch',
    'ш': 'shh',
    'ч': 'ch',
    'э': "eh'",
    'ъ': '"',
    'ь': "'",
    'ю': 'yu',
    'я': 'ya',
  };


  /// Method for converting to translit for the [source] value
  String toTranslit({required String source}) {
    if (source.isEmpty) return source;

    final regExp = RegExp(
      '([А-Яа-яёЁЇїІіЄєҐґ]+)',
      caseSensitive: false,
      multiLine: true,
    );

    if (!regExp.hasMatch(source)) return source;

    final translit = <String>[];
    final sourceSymbols = <String>[...source.split('')];

    _transliteratedSymbol.addAll(_complicatedSymbols);

    for (final element in sourceSymbols) {
      final transElement = _transliteratedSymbol.containsKey(element)
          ? _transliteratedSymbol[element] ?? ''
          : element;
      translit.add(transElement);
    }

    return translit.join();
  }
}

class fastEngine with material.ChangeNotifier{
  material.TextEditingController userSearch = material.TextEditingController(
      text: ""
  );
  material.TextEditingController updatePassword = material.TextEditingController();
  Map known = {};
  List allUsers = [];
  Map logins = {};
  Map logs = {};
  Map availables = {};
  List users = [];
  Map filtered = {};
  Map domains = {};
  Map availdomains = {};
  List toUpdate = [];
  Map domainUsers = {};
  List domainNames = [];
  List userDomains = [];
  List creationDomains = [];
  String action = "Loading...";
  bool loading = false;
  bool loadOnLaunch = false;
  bool displayUsers = true;
  bool allowDuplicates = true;

  List newbieDomains = [];

  material.TextEditingController tempL = material.TextEditingController();
  material.TextEditingController tempA = material.TextEditingController();
  material.TextEditingController tempU = material.TextEditingController();
  material.TextEditingController tempP = material.TextEditingController();

  material.TextEditingController userL = material.TextEditingController(text: "");
  material.TextEditingController userP = material.TextEditingController();

  material.TextEditingController proxyUser = material.TextEditingController();
  material.TextEditingController proxyPassword = material.TextEditingController();
  material.TextEditingController proxyAddr = material.TextEditingController();
  material.TextEditingController proxyPort = material.TextEditingController();


  List userErrors = [];
  String userMessage = "Leave password field empty for random password";

  bool tempPanelAddReady = false;
  bool tempPanelAddloading = false;

  bool loggedIn = false;
  String globalPassword = "";

  bool isProxyUsed = true;

  material.TextEditingController globeP = material.TextEditingController();


  material.TextEditingController voisoKey = material.TextEditingController();

  Future<bool> checkPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("globalPassword")){
      var refPWD = prefs.getString("globalPassword");
      var checkPWD = md5.convert(utf8.encode(md5.convert(utf8.encode("$password-FPT")).toString())).toString();
      if(checkPWD == refPWD){
        globalPassword = checkPWD;
        loggedIn = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> setPassword (String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    globalPassword = md5.convert(utf8.encode(md5.convert(utf8.encode("$password-FPT")).toString())).toString();
    prefs.setString("globalPassword", globalPassword);
  }

  clearDB() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  String normUsername(username){
    return Translit().toTranslit(source: latinize(username.trim())).replaceAll(" ", ".").toLowerCase();
  }

  String decrypt(Encrypted encryptedData) {
    final key = Key.fromUtf8(globalPassword);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(globalPassword.substring(0, 16));
    return encrypter.decrypt(encryptedData, iv: initVector);
  }

  Encrypted encrypt(String plainText) {
    final key = Key.fromUtf8(globalPassword);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(globalPassword.substring(0, 16));
    Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
    return encryptedData;
  }

  Future <void> launch() async {
    loading = true; action = "Loading saved data...";
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("displayUsers")){
      displayUsers = prefs.getBool("displayUsers")??true;
    }
    if(prefs.containsKey("allowDuplicates")){
      allowDuplicates = prefs.getBool("allowDuplicates")??true;
    }
    if(prefs.containsKey("known")){
      String memKnown = "";
      memKnown = await prefs.getString("known")??"";
      try {
        known = jsonDecode(memKnown);
      } on FormatException catch (e) {
        known = jsonDecode(decrypt(Encrypted.fromBase64(memKnown)));
      }
      if(prefs.containsKey("logins")){
        String memLogs = "";
        memLogs = await prefs.getString("logins")??"";
        try {
          logins = jsonDecode(memLogs);
        } on FormatException catch (e) {
          logins = jsonDecode(decrypt(Encrypted.fromBase64(memLogs)));
        }
      }
      if(prefs.containsKey("domains")){
        String memDomains = "";
        memDomains = prefs.getString("domains")??"";
        try {
          domains = jsonDecode(memDomains);
        } on FormatException catch (e) {
          domains = jsonDecode(decrypt(Encrypted.fromBase64(memDomains)));
        }
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
    var userDomain = user["address"].replaceAll("${user["login"]}@", "");
    toUpdate.add(userDomain);
    notifyListeners();
    var domainIP = "";
    for(int a=0; a < known.length;a++){
      for(int i=0; i < domains[known.keys.toList()[a]].length;i++){
        if(domains[known.keys.toList()[a]][i]["name"] == userDomain){
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

  Future updateUser(user) async {
    loading = true;
    var pass = updatePassword.text == ""?generateRandomString(12):updatePassword.text;
    action = "Updating ${user["address"]}...";
    notifyListeners();
    var userDomain = user["address"].replaceAll("${user["login"]}@", "");
    var domainIP = "";
    for(int a=0; a < known.length;a++){
      for(int i=0; i < domains[known.keys.toList()[a]].length;i++){
        if(domains[known.keys.toList()[a]][i]["name"] == userDomain){
          domainIP = known.keys.toList()[a];
        }
      }
    }
    await checkLogin(domainIP).then((value) async {
      await fastpanelUpdateUser(user["id"], pass, domainIP, logins[domainIP]["token"]).then((value){
        loading = false;
        action = "User ${user["address"]} updated.";
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
    action = "Creating ${normUsername(userL.text)}...";
    notifyListeners();
    var pass = userP.text == ""?generateRandomString(12):userP.text;
    for(int a=0; a < userDomains.length;a++){
      toUpdate.add(userDomains[a]["name"]);
      action = "Creating ${normUsername(userL.text)} on ${userDomains[a]["name"]}...";
      notifyListeners();
      await fastpanelCreateUser(
          userDomains[a]["id"],
          userDomains[a]["server"],
          normUsername(userL.text),
          pass,
          logins[userDomains[a]["server"]]["token"]
      ).then((value) async {
        action = "Created ${normUsername(userL.text)} on ${userDomains[a]["name"]}.";
        notifyListeners();
      });
    }
    await getAllUsers().then((value) async {
      await filterUsers().then((value) async {
        action = "Created ${userL.text}.";
        loading = false;
        notifyListeners();
        await Clipboard.setData(ClipboardData(text: "${userDomains.length == 1 ? "${normUsername(userL.text)}@${userDomains[0]["name"]}" : normUsername(userL.text)}	$pass"));
        userSearch.text = userL.text;
        userL.text = "";
        userP.text = "";
        filterUsers();
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
    var out = [];
    await fastpanelSites(ip, logins[ip]["token"]).then((site) async {
      for(int i=0;i < site["data"].length;i++){
        await fastpanelDomains(ip,site["data"][i]["id"], logins[ip]["token"]).then((domain) async {
          if(!domain["data"][0]["name"].contains("smtp.")){
            if(!availdomains.containsKey(ip)){
              availdomains[ip] = [];
            }
            if(!domainNames.contains(domain["data"][0]["name"])){
              availdomains[ip].add(domain);
              domainNames.add(domain["data"][0]["name"]);
            }
            out.add(domain);
          }
        });
      }
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
          await prefs.setString("logins", encrypt(jsonEncode(logins)).base64);
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
        await prefs.setString("logins", encrypt(jsonEncode(logins)).base64);
        notifyListeners();
      }else{
        tempPanelAddloading = false;
        tempPanelAddReady = false;
        notifyListeners();
      }
    });
  }
  Future<bool> saveBrand() async{
    Map tempKnown = {};
    tempKnown[tempA.text] = {
      "name": tempL.text,
      "addr": tempA.text,
      "user": tempU.text,
      "pass": tempP.text,
    };
    tempKnown.addAll(known);
    known = tempKnown;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("known", encrypt(jsonEncode(known)).base64);
    notifyListeners();
    return true;
  }
  Future<bool> saveBrandList() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("known", encrypt(jsonEncode(known)).base64);
    notifyListeners();
    return true;
  }
  Future <Map> filterUsers() async {
    loading = true;
    action = "Validating...";
    notifyListeners();
    loading = true;
    notifyListeners();
    filtered.clear();
    users.clear();
    for(int i = 0; i < domainUsers.length;i++){
      for(int b = 0; b < domainUsers[domainUsers.keys.toList()[i]].length;b++){
        users.add(domainUsers[domainUsers.keys.toList()[i]][b]);
      }
    }
    for(int i=0; i < users.length; i++){
      if(!allUsers.contains(users[i]["login"])){
        allUsers.add(users[i]["login"]);
      }
      if(users[i]["login"].contains(normUsername(userSearch.text))){
        if(displayUsers){
          if(filtered.length < 100){
            if(!filtered.containsKey(users[i]["login"])){
              filtered[users[i]["login"]] = [];
            }
            filtered[users[i]["login"]].add(users[i]);
            for(int h = 0 ; h < filtered[users[i]["login"]].length ; h++){
              if(newbieDomains.isNotEmpty){
                if(newbieDomains.contains(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""))){
                  newbieDomains.remove(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""));
                }
              }
            }
          }else{
            if(filtered.containsKey(users[i]["login"])){
              filtered[users[i]["login"]].add(users[i]);
              for(int h = 0 ; h < filtered[users[i]["login"]].length ; h++){
                if(newbieDomains.isNotEmpty){
                  if(newbieDomains.contains(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""))){
                    newbieDomains.remove(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""));
                  }
                }
              }
            }
          }
        }else {
          if (!filtered.containsKey(users[i]["login"])) {
            filtered[users[i]["login"]] = [];
          }
          filtered[users[i]["login"]].add(users[i]);
          for(int h = 0 ; h < filtered[users[i]["login"]].length ; h++){
            if(newbieDomains.isNotEmpty){
              if(newbieDomains.contains(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""))){
                newbieDomains.remove(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""));
              }
            }
          }
        }
      }
    }
    loading = false;
    notifyListeners();
    return filtered;
  }

  Future updateCachedUsers() async{
    loading = true;
    action = "Updating users...";
    notifyListeners();
    users.clear();
    for(int i = 0; i < domainUsers.length;i++){
      for(int b = 0; b < domainUsers[domainUsers.keys.toList()[i]].length;b++){
        users.add(domainUsers[domainUsers.keys.toList()[i]][b]);
      }
    }
    loading = false;
    action = "Updated users!";
    notifyListeners();
  }

  Future<List> getAllUsers() async {
    users.clear();
    loading = true;
    action = "Loading users...";
    notifyListeners();
    for(int i=0; i<known.length;i++){
      var keyVar = known[known.keys.toList()[i]]["addr"];
      if(!domains.containsKey(keyVar)){
        domains[keyVar] = [];
      }
      for(int a=0; a<domains[keyVar].length;a++){
        if(toUpdate.isEmpty){
          if(logins.containsKey(keyVar)){
            action = "Getting users from ${domains[keyVar][a]["name"]}...";
            notifyListeners();
            await checkLogin(keyVar).then((huh) async {
              await fastpanelMailboxes(keyVar, domains[keyVar][a], logins[keyVar]["token"]).then((value){
                domainUsers[domains[keyVar][a]["name"]] = value["data"];
              });
            });
          }
        }else{
          if(toUpdate.contains(domains[keyVar][a]["name"])){
            if(logins.containsKey(keyVar)){
              action = "Getting users from ${domains[keyVar][a]["name"]}...";
              toUpdate.remove(domains[keyVar][a]["name"]);
              notifyListeners();
              await checkLogin(keyVar).then((huh) async {
                await fastpanelMailboxes(keyVar, domains[keyVar][a], logins[keyVar]["token"]).then((value){
                  domainUsers[domains[keyVar][a]["name"]] = value["data"];
                });
              });
            }
          }
        }
      }
    }
    toUpdate.clear();
    action = "Got users.";
    loading = false;
    notifyListeners();
    return users;
  }
  Future<bool> saveDomains() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("domains", encrypt(jsonEncode(domains)).base64);
    return true;
  }
}