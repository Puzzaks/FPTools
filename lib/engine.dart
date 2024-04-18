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
import 'package:flutter/foundation.dart' show kIsWeb;

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
  bool remoteRWMode = false;
  List selectedUsers = [];
  List selectedGroups = [];
  List newbieDomains = [];
  List userErrors = [];
  String userMessage = "Leave password field empty for random password";
  bool tempPanelAddReady = false;
  bool tempPanelAddloading = false;
  bool loggedIn = false;
  String globalPassword = md5.convert(utf8.encode(md5.convert(utf8.encode("113245-FPT")).toString())).toString();
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
      var checkPWD = md5.convert(utf8.encode(md5.convert(utf8.encode("113245-FPT")).toString())).toString();
      if(checkPWD == refPWD){
        globalPassword = checkPWD;
        loggedIn = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> logAdd (log, type, thread, bool isArray) async {
    logs.add({
      "time": DateTime.now().millisecondsSinceEpoch,
      "log": log,
      "array": isArray,
      "thread": thread,
      "type": type
    });
    if(!isArray){
      await windowManager.setTitle(log);
      action = log;
    }
    notifyListeners();
  }
  String normUsername(username){
    return Translit().toTranslit(source: latinize(username.replaceAll("\r", "").replaceAll("\n", "").replaceAll("	", "").trim())).replaceAll(" ", ".").replaceAll("..", ".").toLowerCase();
  }
  launch() async {
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle("OneTool: $action");
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    loading = true;
    ignite();
    pingServer().then((value) async {
      if(value){ //if online
        await logAdd("Checking proxy...", "info", "startup", false);
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
        } else {
          proxyStatus = "Proxy is disabled.";
          notifyListeners();
          HttpOverrides.global = CertificateOverride();
        }

        await logAdd("Downloading data...", "info", "startup", false);
        await getData("known").then((value) async {
          known = jsonDecode(decrypt(Encrypted.fromBase64(value)));
        });
        await getData("domains").then((value) async {
          domains = jsonDecode(decrypt(Encrypted.fromBase64(value)));
          for(int n=0; n<domains.keys.toList().length;n++){
            if(!known.containsKey(domains.keys.toList()[n])){
              print("Not found: ${domains.keys.toList()[n]} - ${domains[domains.keys.toList()[n]]}");
              domains.remove(domains.keys.toList()[n]);
            }
          }
        });

        await logAdd("Loading settings...", "info", "startup", false);
        if(prefs.containsKey("displayUsers")){
          displayUsers = prefs.getBool("displayUsers")??true;
        }
        if(prefs.containsKey("allowDuplicates")){
          allowDuplicates = prefs.getBool("allowDuplicates")??false;
        }
        if(prefs.containsKey("remoteRWMode")){
          remoteRWMode = prefs.getBool("remoteRWMode")??false;
        }


        if(prefs.containsKey("logins")){
          String memLogs = "";
          memLogs = await prefs.getString("logins")??"";
          logins = jsonDecode(decrypt(Encrypted.fromBase64(memLogs)));
        }
        if(prefs.containsKey("labels")){
          String memLabels = "";
          memLabels = prefs.getString("labels")??"";
          labels = jsonDecode(decrypt(Encrypted.fromBase64(memLabels)));
        }
        for(int i=0; i<known.length;i++){
          var keyVar = known[known.keys.toList()[i]]["addr"];
          await logAdd("Checking connection to $keyVar...", "info", "startup", false);
          notifyListeners();
          await checkConnect(keyVar).then((value) async {
            availables[keyVar] = value;
            if(value){
              checkLogin(keyVar);
            }
          });
        }
        filterServers();
        domainsLoading = false;

        await logAdd("Loading users...", "info", "startup", false);
        await getAllUsers().then((value){
          filterUsers();
        });

        domainsLoading = false;
        emaisLoading = false;
        loading = false;
        notifyListeners();
      }else{
        await logAdd("Main server is unreachable. What are you doing?", "error", "startup", false);
      }
    });



  }
  Future deleteUser(user) async {
    newbieDomains.clear();
    loading = true;
    await logAdd("Deleting ${user["address"]}...", "info", "deletion", false);
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
        await logAdd(value, "info", "deletion", true);
        loading = false;
        await logAdd("User ${user["address"]} deleted.", "info", "deletion", false);
        notifyListeners();
        filterUsers();
      });
    });
  }
  Future updateUser(user) async {
    loading = true;
    var pass = updatePassword.text == ""?generateRandomString(12):updatePassword.text;
    await logAdd("Updating ${user["address"]}...", "info", "updating", false);
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
        await logAdd(value, "info", "updating", true);
        loading = false;
        await logAdd("User ${user["address"]} updated.", "info", "updating", false);
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
    await logAdd("Creating ${normUsername(userL.text)}...", "info", "creation", false);
      String pass = userP.text == ""?generateRandomString(12):userP.text;
      String uname = normUsername(userL.text);
      String multiUserCopy = "";
      List multiUsers = [];
      if(multiUserCreate){
        for(int h=0; h<userL.text.split('\n').length;h++) {
          pass = userL.text.contains("	")
              ? userL.text.split('\n')[h].split("	")[1] == "" ? generateRandomString(12) : userL.text.split('\n')[h].split("	")[1]
              : generateRandomString(12);
          uname = normUsername(userL.text.split('\n')[h].split("	")[0].replaceAll("\r", ""));
          if(uname.length > 1){
            if(userDomains.length==1){
              multiUserCopy = "$multiUserCopy$uname@${userDomains[0]["name"]}	$pass\n";
            }else{
              multiUserCopy = "$multiUserCopy$uname	$pass\n";
            }
            multiUsers.add({"l":uname,"p":pass});
          }
        }
      }
      for(int a=0; a < userDomains.length;a++) {
        await logAdd("Validating login on ${userDomains[a]["name"]}...", "info", "login", false);
        if (userDomains[a].containsKey("data")) {
          await checkLogin(userDomains[a]["data"]["server"]).then((value) async {
            await logAdd("Renewed login on ${userDomains[a]["name"]}", "info", "login", false);
          });
        } else {
          await checkLogin(userDomains[a]["server"]).then((value) async {
            await logAdd("Valid login on ${userDomains[a]["name"]}", "info", "login", false);
          });
        }
        toUpdate.add(userDomains[a]["name"]);
        if(multiUserCreate){
          for(int h=0; h<multiUsers.length;h++) {
            pass = multiUsers[h]["p"];
            uname = multiUsers[h]["l"];
            if (pass.length < 4) {
              await logAdd("User not created as login data is empty", "warn", "creation", false);
            }else{
              await logAdd("Creating ${multiUserCreate?uname:normUsername(userL.text)} on ${userDomains[a]["name"]}...", "info", "creation", false);
              await fastpanelCreateUser(
                  userDomains[a]["id"],
                  userDomains[a]["server"],
                  uname,
                  pass.replaceAll("\r", ""),
                  logins[userDomains[a]["server"]]["token"]
              ).then((value) async {
                await logAdd(value, "info", "creation", true);
                await logAdd("Created ${multiUserCreate?uname:normUsername(userL.text)} on ${userDomains[a]["name"]}.", "info", "creation", false);
              });
            }
          }
        }else{
          await logAdd("Creating ${normUsername(userL.text)} on ${userDomains[a]["name"]}...", "info", "creation", false);
          await fastpanelCreateUser(
              userDomains[a]["id"],
              userDomains[a]["server"],
              uname,
              pass,
              logins[userDomains[a]["server"]]["token"]
          ).then((value) async {
            await logAdd(value, "info", "creation", true);
            await logAdd("Created ${normUsername(userL.text)} on ${userDomains[a]["name"]}.", "info", "creation", false);
          });
        }
      }
      await getAllUsers().then((value) async {
        await filterUsers().then((value) async {
          loading = false;
          await logAdd("Created ${multiUsers.map((user){return user["l"];}).toList()}.", "info", "creation", false);
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
    await fastpanelSites(ip, logins[ip]["token"]).then((site) {
      for(int i=0;i < site["data"].length;i++){
        fastpanelDomains(ip,site["data"][i]["id"], logins[ip]["token"]).then((domain) {
          if(domain["data"].length > 0){
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
          }
          notifyListeners();
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
    await setData("known", encrypt(jsonEncode(known)).base64).then((value){
      filterServers();
      return true;
    });
    return false;
  }
  Future<bool> saveLabels() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("labels", encrypt(jsonEncode(labels)).base64);
    notifyListeners();
    return true;
  }
  Future<bool> saveBrandList() async{
    await setData("known", encrypt(jsonEncode(known)).base64).then((value){
      filterServers();
      return true;
    });
    return false;
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
    await logAdd("Validating users...", "info", "filtering", false);
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
    await windowManager.setTitle("");
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
    await logAdd("Updating users...", "info", "filtering", false);
    users.clear();
    for(int i = 0; i < domainUsers.length;i++){
      for(int b = 0; b < domainUsers[domainUsers.keys.toList()[i]].length;b++){
        users.add(domainUsers[domainUsers.keys.toList()[i]][b]);
      }
    }
    loading = false;
    await logAdd("Updated users!", "info", "filtering", false);
  }
  Future<List> getAllUsers() async {
    users.clear();
    loading = true;
    await logAdd("Loading users...", "info", "users", false);
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
                await logAdd("Getting users from ${domains[keyVar][a]["name"]}...", "info", "getting", false);
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
                  await logAdd("Getting users from ${domains[keyVar][a]["name"]}...", "info", "getting", false);
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
    await windowManager.setTitle("");
    loading = false;
    notifyListeners();
    return users;
  }
  Future<bool> saveDomains() async{
    notifyListeners();
    setData("domains", encrypt(jsonEncode(domains)).base64);
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