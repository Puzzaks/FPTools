import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:latinize/latinize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
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

class fastEngine extends HttpOverrides with material.ChangeNotifier{
  material.TextEditingController userSearch = material.TextEditingController(text: "");
  material.TextEditingController serverSearch = material.TextEditingController(text: "");
  material.TextEditingController labelSearch = material.TextEditingController(text: "");
  material.TextEditingController updatePassword = material.TextEditingController();
  material.TextEditingController labelName = material.TextEditingController();
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
  material.TextEditingController globeP = material.TextEditingController();
  material.TextEditingController voisoKeyUser = material.TextEditingController();
  material.TextEditingController voisoKeyCenter = material.TextEditingController();
  material.TextEditingController voisoCluster = material.TextEditingController();
  Map known = {};
  Map displayKnown = {};
  List allUsers = [];
  Map logins = {};
  List logs = [];
  Map availables = {};
  List users = [];
  Map filtered = {};
  Map domains = {};
  Map availdomains = {};
  List toUpdate = [];
  Map domainUsers = {};
  List domainNames = [];
  List doubleDomains = [];
  List userDomains = [];
  List creationDomains = [];
  String action = "Loading...";
  bool loading = false;
  bool loadOnLaunch = false;
  bool displayUsers = true;
  bool allowDuplicates = true;
  List selectedUsers = [];
  List selectedGroups = [];
  List newbieDomains = [];
  List userErrors = [];
  String userMessage = "Leave password field empty for random password";
  bool tempPanelAddReady = false;
  bool tempPanelAddloading = false;
  bool loggedIn = false;
  String globalPassword = "";
  bool isProxyUsed = false;
  Map proxy = {};
  String proxyStatus = "Loading...";
  String voisoStatus = "";
  bool voisoLoading = true;
  bool emaisLoading = true;
  bool domainsLoading = true;
  List labels = [];
  List labelDomains = [];
  Map tempLabel = {};
  Map glowDomains = {};
  List selectedLabels = [];
  bool multiUserCreate = false;
  late material.BuildContext defaultContext;

  clearDB() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
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
    String pwd = globalPassword.substring(0, 16);
    final initVector = IV.fromUtf8(pwd);
    Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
    return encryptedData;
  }
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
  Future <void> logAdd (log, type, thread, bool isArray) async{
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    logs.add({
      "time": DateTime.now().millisecondsSinceEpoch,
      "log": log,
      "array": isArray,
      "thread": thread,
      "type": type
    });
    notifyListeners();
    // await prefs.setString("logs", encrypt(jsonEncode(logs)).base64);
  }
  String normUsername(username){
    return Translit().toTranslit(source: latinize(username.replaceAll("\r", "").replaceAll("\n", "").replaceAll("	", "").trim())).replaceAll(" ", ".").toLowerCase();
  }
  launch() async {
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle("OneTool: $action");
    });
    loading = true; action = "Checking proxy...";
    await windowManager.setTitle("OneTool: $action");
    ignite();
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // if(prefs.containsKey("logs")){
    //   String memLogs = "";
    //   memLogs = await prefs.getString("logs")??"";
    //   logs = jsonDecode(decrypt(Encrypted.fromBase64(memLogs)));
    // }
    logAdd(action, "info", "startup", false);
    if(prefs.containsKey("isProxyUsed")){
      isProxyUsed = prefs.getBool("isProxyUsed")??false;
    }
    if(isProxyUsed){
      proxyStatus = "Checking proxy...";
      notifyListeners();
      if(prefs.containsKey("proxy")){
        String memProxy = "";
        memProxy = await prefs.getString("proxy")??"";
        proxy = jsonDecode(decrypt(Encrypted.fromBase64(memProxy)));
        proxyStatus = "Pinging proxy...";
        notifyListeners();
        await pingProxy("${proxy["address"]}:${proxy["port"]}", "${proxy["username"]}:${proxy["password"]}").then((value) async {
          proxyStatus = "Setting up proxy...";
          notifyListeners();
          if(value){
            HttpOverrides.global = ProxyOverride(proxy: proxy);
            proxyAddr.text = proxy["address"];
            proxyPort.text = proxy["port"];
            proxyUser.text = proxy["username"];
            proxyPassword.text = proxy["password"];
            proxyStatus = "Proxy connection established!";
            notifyListeners();
          }else{
            proxyStatus = "Credentials incorrect";
            notifyListeners();
          }
        });
      }
    }else {
      proxyStatus = "Proxy is disabled.";
      notifyListeners();
      HttpOverrides.global = CertificateOverride();
    }
    action = "Loading saved data...";
    logAdd(action, "info", "startup", false);
    await windowManager.setTitle("OneTool: $action");
    notifyListeners();
    if(prefs.containsKey("displayUsers")){
      displayUsers = prefs.getBool("displayUsers")??true;
    }
    if(prefs.containsKey("allowDuplicates")){
      allowDuplicates = prefs.getBool("allowDuplicates")??false;
    }
    if(prefs.containsKey("known")){
      String memKnown = "";
      memKnown = await prefs.getString("known")??"";
      known = jsonDecode(decrypt(Encrypted.fromBase64(memKnown)));
      if(prefs.containsKey("logins")){
        String memLogs = "";
        memLogs = await prefs.getString("logins")??"";
        logins = jsonDecode(decrypt(Encrypted.fromBase64(memLogs)));
      }
      if(prefs.containsKey("domains")){
        String memDomains = "";
        memDomains = prefs.getString("domains")??"";
        domains = jsonDecode(decrypt(Encrypted.fromBase64(memDomains)));
      }
      if(prefs.containsKey("labels")){
        String memLabels = "";
        memLabels = prefs.getString("labels")??"";
        labels = jsonDecode(decrypt(Encrypted.fromBase64(memLabels)));
      }
      for(int i=0; i<known.length;i++){
        var keyVar = known[known.keys.toList()[i]]["addr"];
        action = "Checking connection to $keyVar...";
        logAdd(action, "info", "startup", false);
        await windowManager.setTitle("OneTool: $action");
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
          logAdd(action, "info", "startup", false);
          await windowManager.setTitle("OneTool: $action");
          notifyListeners();
          if(availables[keyVar]){
            checkLogin(keyVar);
          }
        }
      }
      filterServers();
      domainsLoading = false;
      action = "Loading users...";
      logAdd(action, "info", "startup", false);
      await windowManager.setTitle("OneTool: $action");
      notifyListeners();
      await getAllUsers().then((value){
        filterUsers();
      });
      notifyListeners();
    }
    emaisLoading = false;
    loading = false;
    notifyListeners();
  }
  Future deleteUser(user) async {
    newbieDomains.clear();
    loading = true;
    action = "Deleting ${user["address"]}...";
    logAdd(action, "info", "deletion", false);
    await windowManager.setTitle("OneTool: $action");
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
      await fastpanelDeleteUser(user["id"], domainIP, logins[domainIP]["token"]).then((value) async {
        loading = false;
        action = "User ${user["address"]} deleted.";
        logAdd(action, "info", "deletion", false);
        await windowManager.setTitle("OneTool: $action");
        notifyListeners();
        filterUsers();
      });
    });
  }
  Future updateUser(user) async {
    loading = true;
    var pass = updatePassword.text == ""?generateRandomString(12):updatePassword.text;
    action = "Updating ${user["address"]}...";
    logAdd(action, "info", "updating", false);
    await windowManager.setTitle("OneTool: $action");
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
      await fastpanelUpdateUser(user["id"], pass, domainIP, logins[domainIP]["token"]).then((value) async {
        loading = false;
        action = "User ${user["address"]} updated.";
        logAdd(action, "info", "updating", false);
        await windowManager.setTitle("OneTool: $action");
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
    logAdd(action, "info", "creation", false);
    await windowManager.setTitle("OneTool: $action");
    notifyListeners();
      String pass = userP.text == ""?generateRandomString(12):userP.text;
      String uname = normUsername(userL.text);
      String multiUserCopy = "";
      List multiUsers = [];
      if(multiUserCreate){
        for(int h=0; h<userL.text.split('\n').length;h++) {
          pass = userL.text.contains("	")
              ? userL.text.split('\n')[h].split("	")[1] == "" ? generateRandomString(12) : userL.text.split('\n')[h].split("	")[1]
              : generateRandomString(12);
          uname = userL.text.split('\n')[h].split("	")[0].replaceAll("\r", "");
          multiUserCopy = "$multiUserCopy$uname	$pass\r";
          multiUsers.add({"l":uname,"p":pass});
        }
      }
      for(int a=0; a < userDomains.length;a++) {
        action = "Validating login on ${userDomains[a]["name"]}...";
        logAdd(action, "info", "login", false);
        await windowManager.setTitle("OneTool: $action");
        notifyListeners();
        if (userDomains[a].containsKey("data")) {
          await checkLogin(userDomains[a]["data"]["server"]).then((value) async {
            action = "Renewed login on ${userDomains[a]["name"]}";
            logAdd(action, "info", "creation", false);
            await windowManager.setTitle("OneTool: $action");
            notifyListeners();
          });
        } else {
          await checkLogin(userDomains[a]["server"]).then((value) async {
            action = "Renewed login on ${userDomains[a]["name"]}";
            logAdd(action, "info", "login", false);
            await windowManager.setTitle("OneTool: $action");
            notifyListeners();
          });
        }
        toUpdate.add(userDomains[a]["name"]);
        if(multiUserCreate){
          for(int h=0; h<multiUsers.length;h++) {
            pass = multiUsers[h]["p"];
            uname = multiUsers[h]["l"];
            if (pass.length < 4) {
              logAdd("User not created as login data is empty", "warn", "creation", false);
              print("Empty line, ignored");
            }else{
              action = "Creating ${multiUserCreate?uname:normUsername(userL.text)} on ${userDomains[a]["name"]}...";
              logAdd(action, "info", "creation", false);
              await windowManager.setTitle("OneTool: $action");
              notifyListeners();
              await fastpanelCreateUser(
                  userDomains[a]["id"],
                  userDomains[a]["server"],
                  uname,
                  pass.replaceAll("\r", ""),
                  logins[userDomains[a]["server"]]["token"]
              ).then((value) async {
                action = "Created ${multiUserCreate?uname:normUsername(userL.text)} on ${userDomains[a]["name"]}.";
                logAdd(action, "info", "creation", false);
                await windowManager.setTitle("OneTool: $action");
                notifyListeners();
              });
            }
          }
        }else{
          action = "Creating ${normUsername(userL.text)} on ${userDomains[a]["name"]}...";
          logAdd(action, "info", "creation", false);
          await windowManager.setTitle("OneTool: $action");
          notifyListeners();
          await fastpanelCreateUser(
              userDomains[a]["id"],
              userDomains[a]["server"],
              uname,
              pass,
              logins[userDomains[a]["server"]]["token"]
          ).then((value) async {
            action = "Created ${normUsername(userL.text)} on ${userDomains[a]["name"]}.";
            logAdd(action, "info", "creation", false);
            await windowManager.setTitle("OneTool: $action");
            notifyListeners();
          });
        }
      }
      await getAllUsers().then((value) async {
        await filterUsers().then((value) async {
          action = "Created ${userL.text}.";
          logAdd(action, "info", "creation", false);
          await windowManager.setTitle("OneTool: $action");
          loading = false;
          notifyListeners();
          if(!multiUserCreate){
            await Clipboard.setData(ClipboardData(text: "${userDomains.length == 1 ? "${normUsername(userL.text)}@${userDomains[0]["name"]}" : normUsername(userL.text)}	$pass"));
            userSearch.text = uname;
          }else{
            await Clipboard.setData(ClipboardData(text: multiUserCopy));
          }
          userL.text = "";
          userP.text = "";
          filterUsers();
          return pass;
        });
      });
    return "WTF";
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
    if(logins.containsKey(ip)) {
      if(DateTime.parse(logins[ip]["data"]["expire"]).difference(DateTime.now()).inMinutes < 1){
        await fastpanelLogin(ip, known[ip]["user"], known[ip]["pass"]).then((value) async {
          if(value.containsKey("token")){
            availables[ip] = true;
            logins[ip] = value;
            await prefs.setString("logins", encrypt(jsonEncode(logins)).base64);
            notifyListeners();
          }else{
            availables[ip] = false;
          }
        });
      }
    }else{
      await fastpanelLogin(ip, known[ip]["user"], known[ip]["pass"]).then((value) async {
        if(value.containsKey("token")){
          availables[ip] = true;
          logins[ip] = value;
          await prefs.setString("logins", encrypt(jsonEncode(logins)).base64);
          notifyListeners();
        }else{
          availables[ip] = false;
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
        availables[tempA.text] = true;
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
    known.remove(tempA.text);
    tempKnown.addAll(known);
    known = tempKnown;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("known", encrypt(jsonEncode(known)).base64);
    filterServers();
    return true;
  }
  Future<bool> saveLabels() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("labels", encrypt(jsonEncode(labels)).base64);
    notifyListeners();
    return true;
  }
  Future<bool> saveBrandList() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("known", encrypt(jsonEncode(known)).base64);
    filterServers();
    return true;
  }
  Future<bool> saveProxy() async{
    proxyStatus = "Checking proxy...";
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await pingProxy("${proxyAddr.text}:${proxyPort.text}", "${proxyUser.text}:${proxyPassword.text}").then((value){
      if(value){
        proxyStatus = "Proxy updated!";
        notifyListeners();
        proxy["address"] = proxyAddr.text;
        proxy["port"] = proxyPort.text;
        proxy["username"] = proxyUser.text;
        proxy["password"] = proxyPassword.text;
        prefs.setString("proxy", encrypt(jsonEncode(proxy)).base64);
        HttpOverrides.global = ProxyOverride(proxy: proxy);
        notifyListeners();
      }else{
        proxyStatus = "Wrong proxy settings!";
        notifyListeners();
        HttpOverrides.global = CertificateOverride();
      }
    });
    return true;
  }
  Future <Map> filterUsers() async {
    loading = true;
    action = "Validating...";
    logAdd(action, "info", "filtering", false);
    await windowManager.setTitle("OneTool: $action");
    notifyListeners();
    loading = true;
    notifyListeners();
    filtered.clear();
    users.clear();
    for (int i = 0; i < domainUsers.length; i++) {
      if (domainUsers[domainUsers.keys.toList()[i]].isEmpty) {

      }else{
        for (int b = 0; b < domainUsers[domainUsers.keys.toList()[i]].length; b++) {
          users.add(domainUsers[domainUsers.keys.toList()[i]][b]);
        }
      }
    }
    if (selectedUsers.isNotEmpty && userSearch.text.isEmpty) {
      filtered["Selected"] = selectedUsers;
    }else{
      for (int i = 0; i < users.length; i++) {
        if (!allUsers.contains(users[i]["login"])) {
          allUsers.add(users[i]["login"]);
        }
        if (users[i]["login"].contains(normUsername(userSearch.text))) {
          if (displayUsers) {
            if (filtered.length < 100) {
              if (!filtered.containsKey(users[i]["login"])) {
                filtered[users[i]["login"]] = [];
              }
              filtered[users[i]["login"]].add(users[i]);
              for (int h = 0; h < filtered[users[i]["login"]].length; h++) {
                if (newbieDomains.isNotEmpty) {
                  if (newbieDomains.contains(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""))) {
                    newbieDomains.remove(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""));
                  }
                }
              }
            } else {
              if (filtered.containsKey(users[i]["login"])) {
                filtered[users[i]["login"]].add(users[i]);
                for (int h = 0; h < filtered[users[i]["login"]].length; h++) {
                  if (newbieDomains.isNotEmpty) {
                    if (newbieDomains.contains(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""))) {
                      newbieDomains.remove(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""));
                    }
                  }
                }
              }
            }
          } else {
            if (!filtered.containsKey(users[i]["login"])) {
              filtered[users[i]["login"]] = [];
            }
            filtered[users[i]["login"]].add(users[i]);
            for (int h = 0; h < filtered[users[i]["login"]].length; h++) {
              if (newbieDomains.isNotEmpty) {
                if (newbieDomains.contains(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""))) {
                  newbieDomains.remove(filtered[users[i]["login"]][h]["address"].replaceAll("${filtered[users[i]["login"]][h]["login"]}@", ""));
                }
              }
            }
          }
        }
      }
    }
    loading = false;
    action = "Ready";
    await windowManager.setTitle("OneTool: $action");
    notifyListeners();
    return filtered;
  }
  Future <Map> filterServers() async {
    displayKnown.clear();
    for (int i = 0; i < known.length; i++) {
      if(known[known.keys.toList()[i]]["name"].toString().toLowerCase().contains(serverSearch.text.toLowerCase())){
        displayKnown[known.keys.toList()[i]] = known[known.keys.toList()[i]];
      }
    }
    notifyListeners();
    return displayKnown;
  }
  Future updateCachedUsers() async{
    loading = true;
    action = "Updating users...";
    logAdd(action, "info", "filtering", false);
    await windowManager.setTitle("OneTool: $action");
    notifyListeners();
    users.clear();
    for(int i = 0; i < domainUsers.length;i++){
      for(int b = 0; b < domainUsers[domainUsers.keys.toList()[i]].length;b++){
        users.add(domainUsers[domainUsers.keys.toList()[i]][b]);
      }
    }
    loading = false;
    action = "Updated users!";
    logAdd(action, "info", "filtering", false);
    await windowManager.setTitle("OneTool: $action");
    notifyListeners();
  }
  Future<List> getAllUsers() async {
    users.clear();
    loading = true;
    action = "Loading users...";
    await windowManager.setTitle("OneTool: $action");
    logAdd(action, "info", "users", false);
    notifyListeners();
    for(int i=0; i<known.length;i++){
      var keyVar = known[known.keys.toList()[i]]["addr"];
      if(!domains.containsKey(keyVar)){
        domains[keyVar] = [];
      }
      for(int a=0; a<domains[keyVar].length;a++){
        if(availables[keyVar]){
          if(toUpdate.isEmpty){
            if(logins.containsKey(keyVar)){
              await checkLogin(keyVar).then((huh) async {
                loading = true;
                notifyListeners();
                action = "Getting users from ${domains[keyVar][a]["name"]}...";
                logAdd(action, "info", "getting", false);
                await windowManager.setTitle("OneTool: $action");
                notifyListeners();
                await fastpanelMailboxes(keyVar, domains[keyVar][a], logins[keyVar]["token"]).then((value) async {
                  domainUsers[domains[keyVar][a]["name"]] = value["data"];
                  await filterUsers();
                });
              });
            }
          }else{
            if(toUpdate.contains(domains[keyVar][a]["name"])){
              if(logins.containsKey(keyVar)){
                toUpdate.remove(domains[keyVar][a]["name"]);
                await checkLogin(keyVar).then((huh) async {
                  action = "Getting users from ${domains[keyVar][a]["name"]}...";
                  logAdd(action, "info", "getting", false);
                  await windowManager.setTitle("OneTool: $action");
                  notifyListeners();
                  await fastpanelMailboxes(keyVar, domains[keyVar][a], logins[keyVar]["token"]).then((value){
                    domainUsers[domains[keyVar][a]["name"]] = value["data"];
                    filterUsers();
                  });
                });
              }
            }
          }
        }
      }
    }
    toUpdate.clear();
    action = "Ready";
    await windowManager.setTitle("OneTool: $action");
    loading = false;
    notifyListeners();
    return users;
  }
  Future<bool> saveDomains() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("domains", encrypt(jsonEncode(domains)).base64);
    return true;
  }

  ignite() async {
    voisoLoading = true;
    voisoStatus = "Loading settings...";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("voiso")) {
      String voisoString = "";
      voisoString = await prefs.getString("voiso") ?? "";
      Map voisoKeys = jsonDecode(decrypt(Encrypted.fromBase64(voisoString)));
      voisoCluster.text = voisoKeys["cluster"];
      voisoKeyUser.text = voisoKeys["user"];
      voisoKeyCenter.text = voisoKeys["center"];
    }
    // voisoLoading = false;
    voisoStatus = "Loaded";
  }
  Future<bool> saveVoisoKeys() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("voiso", encrypt(
        jsonEncode(
            {
              "cluster":voisoCluster.text,
              "user":voisoKeyUser.text,
              "center":voisoKeyCenter.text
            }
        )
    ).base64);
    return true;
  }
}