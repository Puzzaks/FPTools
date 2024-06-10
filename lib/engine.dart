import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:latinize/latinize.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'network.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

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
  material.TextEditingController dropController = material.TextEditingController(text: "Voiso: cc-ams05");
  material.TextEditingController userDropController = material.TextEditingController();
  material.TextEditingController userSearch = material.TextEditingController(text: "");
  material.TextEditingController cpSearch = material.TextEditingController(text: "");
  material.TextEditingController cdrSearch = material.TextEditingController(text: "");
  material.TextEditingController cdrFromSearch = material.TextEditingController(text: "");
  material.TextEditingController voisoSearch = material.TextEditingController(text: "");
  material.TextEditingController voisoUserName = material.TextEditingController(text: "");
  material.TextEditingController voisoUserEmail = material.TextEditingController(text: "");
  material.TextEditingController voisoUserPassword = material.TextEditingController(text: "");
  material.TextEditingController voisoUserExtension = material.TextEditingController(text: "");
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
  material.TextEditingController cpKey = material.TextEditingController();
  material.TextEditingController cpCluster = material.TextEditingController();
  material.TextEditingController numinput = material.TextEditingController();
  Map known = {};
  Map displayKnown = {};
  Map logins = {};
  Map availables = {};
  Map filtered = {};
  Map domains = {};
  Map availdomains = {};
  Map proxy = {};
  Map tempLabel = {};
  Map glowDomains = {};
  Map voisoUser = {};
  List allUsers = [];
  List logs = [];
  List users = [];
  List toUpdate = [];
  Map domainUsers = {};
  List domainNames = [];
  List doubleDomains = [];
  List userDomains = [];
  List creationDomains = [];
  List selectedUsers = [];
  List selectedGroups = [];
  List newbieDomains = [];
  List userErrors = [];
  List labels = [];
  List labelDomains = [];
  List selectedLabels = [];
  String globalPassword = md5.convert(utf8.encode(md5.convert(utf8.encode("113245-FPT")).toString())).toString();
  String action = "Loading...";
  String userMessage = "Leave password field empty for random password";
  String proxyStatus = "Loading...";
  String voisoStatus = "";
  bool loading = false;
  bool loadOnLaunch = false;
  bool displayUsers = true;
  bool allowClipboard = true;
  bool remoteRWMode = false;
  bool tempPanelAddReady = false;
  bool tempPanelAddloading = false;
  bool loggedIn = false;
  bool isProxyUsed = false;
  bool voisoLoading = true;
  bool emaisLoading = true;
  bool domainsLoading = true;
  bool multiUserCreate = false;
  bool voisoCorrect = false;
  bool clusterValid = false;
  bool userValid = false;
  bool centerValid = false;
  bool userCreateMode = false;
  double balance = 0.0;
  int lastUpdateTime = 0;
  Map updateTimes = {};
  Map recentRemoteCreate = {};
  RestartableTimer fetchTimer = RestartableTimer(Duration(seconds: 10), (){});
  String serverAddr = "";
  List existDomains = [];
  bool toOpenUCM = false;
  bool toOpenDCM = false;
  bool toOpenLCM = false;
  String updateStatus = "";
  double updatePercent = 0;
  double loadPercent = 0;
  int voisoUserCount = 0;
  Map voisoClusters = {};//cluster id > clusterkey, userkey, clusterid
  Map voisoBalances = {};
  Map voisoUsers = {}; //cluster > users
  Map voisoTeams = {};
  Set activeVoisoClusters = {};
  List filteredVoisoAgents = [];
  String numCheckStatus = "";
  double  numCheckProgress = 0;
  Map numCheckResult = {};
  String numCheckVerdict = "";
  int screenIndex = 0;
  Map voisoCDR = {};
  Map cpCDR = {};
  bool answCDR = false;
  bool answCPCDR = false;
  DateTime dateCDR = DateTime(2021,9,11);
  DateTime dateCPCDR = DateTime(2021,9,11);
  double progressCDR = 0;
  int cdrSelector = 0;
  Map availCPs = {
    "bnbs": "r2ghSS7B4GlKRyG6VT10iGl8pNYVMgAcwMImA8FS24tyQmLXx9iOn5ZPCXDa2tQk",
    "bnbs07": "BFgD1jlqHek2KuM6Ahck8T6kk8IkaOjW1MR7TbgsXrZPPnZTNUAciEf4Xj6RMp1r"
  };
  String selectCP = "bnbs";
  Map clusters = {};
  Map allClusters = {};
  bool isNumCheck = false;
  List voisoNumbers = [];
  Map numbersFromAmountCalls = {};
  bool demoMode = false;


  String            decrypt(Encrypted encryptedData) {
    final key = Key.fromUtf8(globalPassword);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(globalPassword.substring(0, 16));
    return encrypter.decrypt(encryptedData, iv: initVector);
  }
  Encrypted         encrypt(String plainText) {
    final key = Key.fromUtf8(globalPassword);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    String pwd = globalPassword.substring(0, 16);
    final initVector = IV.fromUtf8(pwd);
    Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
    return encryptedData;
  }
  Future<void>      logAdd (log, type, thread, bool isArray) async {
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
  String            normUsername(username){
    return Translit().toTranslit(source: latinize(username.split("@")[0].replaceAll("\r", "").replaceAll("\n", "").replaceAll("	", "").trim())).replaceAll(" ", ".").replaceAll("..", ".").toLowerCase();
  }
  Future<Map>       getAppData() async {
    final info = await PackageInfo.fromPlatform();
    Map output = {};
    output = {
      "version": info.version,
      "build": info.buildNumber,
    };
    return output;
  }
                    launch() async {
    loadPercent = 0;
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle("OneTool: $action");
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    loading = true;
    loadPercent = 0;
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
    loadPercent = 0.05;
    pingServer().then((value) async {
      if(value.isNotEmpty){//if online
        serverAddr = value;
        await logAdd("Checking version...", "info", "startup", false);
        await getAppData().then((value){

        });
        await logAdd("Downloading data...", "info", "startup", false);
        await getData(serverAddr, "known").then((value) async {
          loadPercent = 0.1;
          known = jsonDecode(decrypt(Encrypted.fromBase64(value)));
        });
        await getData(serverAddr, "voiso").then((value) async {
          loadPercent = 0.125;
          voisoClusters = jsonDecode(decrypt(Encrypted.fromBase64(value)));
          ignite();
        });
        await getData(serverAddr, "labels").then((value) async {
          loadPercent = 0.15;
          labels = jsonDecode(decrypt(Encrypted.fromBase64(value)));
        });
        await getData(serverAddr, "domains").then((value) async {
          loadPercent = 0.2;
          domains = jsonDecode(decrypt(Encrypted.fromBase64(value)));
          for(int n=0; n<domains.keys.toList().length;n++){
            if(!known.containsKey(domains.keys.toList()[n])){
              print("Not found: ${domains.keys.toList()[n]} - ${domains[domains.keys.toList()[n]]}");
              domains.remove(domains.keys.toList()[n]);
            }
          }
          loadPercent = 0.25;
        });

        await logAdd("Loading settings...", "info", "startup", false);
        if(prefs.containsKey("displayUsers")){
          displayUsers = prefs.getBool("displayUsers")??true;
        }
        if(prefs.containsKey("allowClipboard")){
          allowClipboard = prefs.getBool("allowClipboard")??false;
        }
        if(prefs.containsKey("remoteRWMode")){
          remoteRWMode = prefs.getBool("remoteRWMode")??false;
        }


        await logAdd("Checking servers...", "info", "startup", false);
        if(prefs.containsKey("logins")){
          String memLogs = "";
          memLogs = await prefs.getString("logins")??"";
          logins = jsonDecode(decrypt(Encrypted.fromBase64(memLogs)));
        }
        // if(prefs.containsKey("labels")){
        //   String memLabels = "";
        //   memLabels = prefs.getString("labels")??"";
        //   labels = jsonDecode(decrypt(Encrypted.fromBase64(memLabels)));
        // }
        loadPercent = 0.33;
        for(int i=0; i<known.length;i++){
          var keyVar = known[known.keys.toList()[i]]["addr"];
          notifyListeners();
          await checkConnect(keyVar).then((value) async {
            availables[keyVar] = value;
            if(value){
              checkLogin(keyVar);
            }else{
              await logAdd("$keyVar is unavailable!", "error", "network", false);
            }
            loadPercent = ((i+1)/known.length)/3 + 0.33;
          });
        }
        filterServers();
        domainsLoading = false;

        await logAdd("Loading users...", "info", "startup", false);
        await getAllUsers().then((value){
        });
        lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
        fetchTimer = RestartableTimer(
          Duration(seconds: 10),
            (){
              checkFetchData();
            }
        );
        fetchTimer.reset();
        domainsLoading = false;
        emaisLoading = false;
        loading = false;
        loadOnLaunch = true;
        notifyListeners();
      }else{
        await logAdd("Main server is unreachable. What are you doing?", "error", "startup", false);
      }
    });
  }
                    checkFetchData() async{
    if(userCreateMode){
      // await logAdd("Skipping data refresh...", "info", "getting", false);
    }else{
      // await logAdd("Refreshing data...", "info", "getting", false);
      await getData(serverAddr, "known").then((value) async {
        known = jsonDecode(decrypt(Encrypted.fromBase64(value)));
      });
      await getData(serverAddr, "labels").then((value) async {
        labels = jsonDecode(decrypt(Encrypted.fromBase64(value)));
      });
      await getData(serverAddr, "domains").then((value) async {
        domains = jsonDecode(decrypt(Encrypted.fromBase64(value)));
      });
      // await logAdd("Reading updates...", "info", "getting", false);
      await getAllUpdates();
      // await logAdd("Data is up to date!", "info", "getting", false);
    }
    lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
    await windowManager.setTitle("");
    fetchTimer.reset();
  }
  Future<List>      getAllUpdates() async {
    fetchTimer.cancel();
    bool needsUpdate = false;
    updateStatus = "Getting updates...";
    for(int i=0; i<known.length;i++){
      updatePercent = (i+1)/known.length;
      var keyVar = known[known.keys.toList()[i]]["addr"];
      if(!domains.containsKey(keyVar)){
        domains[keyVar] = [];
      }
      for(int a=0; a<domains[keyVar].length;a++){
        if(availables[keyVar]){
          if(logins.containsKey(keyVar)){
            await checkLogin(keyVar).then((huh) async {
              // await logAdd("Getting updates from ${domains[keyVar][a]["name"]}...", "info", "getting", false);
              await fastpanelActions(keyVar, logins[keyVar]["token"]).then((value) async {
                if(value["data"].isNotEmpty){
                  if(value["data"][0]["type"] == "MAILBOX"&&updateTimes.containsKey(value["data"][0]["name"].split("@")[1])){
                    if(DateTime.fromMillisecondsSinceEpoch(updateTimes[value["data"][0]["name"].split("@")[1]]).isBefore(DateTime.parse(value["data"][0]["created_at"]))){
                      // await logAdd("User ${value["data"][0]["name"]} was created...", "info", "creating", false);
                      recentRemoteCreate = value["data"][0];
                      toUpdate.add(value["data"][0]["name"].split("@")[1]);
                      needsUpdate = true;
                    }
                  }
                }
              });
            });
          }
        }
      }
    }
    if(needsUpdate){
      updatePercent = 0;
      updateStatus = "Receiving users...";
      await getAllUsers().then((value){
      });
    }
    fetchTimer.reset();
    return [];
  }
  Future            deleteUser(user) async {
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
  Future            updateUser(user) async {
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
  String            generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }
  Future            createUser() async {
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
          uname = normUsername(userL.text.split('\n')[h].split("	")[0].split("@")[0].replaceAll("\r", ""));
          if(uname.length > 1){
            if(userExists(uname)) {
              multiUserCopy = "$multiUserCopy	\n";
            }else{
              if(userDomains.length==1){
                multiUserCopy = "$multiUserCopy$uname@${userDomains[0]["name"]}	$pass\n";
              }else{
                multiUserCopy = "$multiUserCopy$uname	$pass\n";
              }
              multiUsers.add({"l":uname,"p":pass});
            }
          }else if(uname == ""){
            multiUserCopy = "$multiUserCopy	\n";
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
    return "WTF";
  }
  Future            saveToggle(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
  Future            getDomains(ip) async{
    await checkLogin(ip);
    if(!availdomains.containsKey(ip)){
      await fastpanelSites(ip, logins[ip]["token"]).then((site) {
        for(int i=0;i < site["data"].length;i++){
          fastpanelDomains(ip, site["data"][i]["id"], logins[ip]["token"]).then((domain) {
            if(domain["data"].length > 0){
              if(!domain["data"][0]["name"].contains("smtp.")){
                if(!availdomains.containsKey(ip)){
                  availdomains[ip] = [];
                }
                if(!domainNames.contains(domain["data"][0]["name"])){
                  availdomains[ip].add(domain);
                  domainNames.add(domain["data"][0]["name"]);
                }
              }
            }
            notifyListeners();
          });
        }
      });
    }
    return availdomains[ip];
  }
  Future <String?>  checkLogin(ip) async {
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
  Future <void>     checkAndCacheBrand() async{
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
  Future<bool>      saveBrand() async{
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
    await setData(serverAddr, "known", encrypt(jsonEncode(known)).base64).then((value){
      filterServers();
      return true;
    });
    return false;
  }
  Future<bool>      saveLabels() async{
    await setData(serverAddr, "labels", encrypt(jsonEncode(labels)).base64).then((value){
      filterServers();
      return true;
    });
    notifyListeners();
    return true;
  }
  Future<bool>      saveBrandList() async{
    await setData(serverAddr, "known", encrypt(jsonEncode(known)).base64).then((value){
      filterServers();
      return true;
    });
    return false;
  }
  List              getUserLabels(domain) {
    List candidates = [];
    for(int i=0;i<labels.length;i++){
      for(int g=0;g<labels[i]["domains"].length;g++){
        if(labels[i]["domains"][g] == domain){
          candidates.add(labels[i]["name"]);
        }
      }
    }
    return candidates;
  }
  bool              userExists(email){
    if(allUsers.contains(email.split("@")[0])) {
      existDomains.clear();
      for (int i = 0; i < userDomains.length; i++) {
        for(int b=0; b<domainUsers[userDomains[i]["name"]].length;b++){
          if(domainUsers[userDomains[i]["name"]][b]["login"] == email.split("@")[0]){
            existDomains.add(userDomains[i]["name"]);
            return true;
          }
        }
      }
    }
    return false;
  }
  Future<bool>      saveProxy() async{
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
  Future <Map>      filterUsers() async {
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
        if (users[i]["address"].contains(normUsername(userSearch.text))) {
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
  Future <Map>      filterServers() async {
    displayKnown.clear();
    for (int i = 0; i < known.length; i++) {
      if(known[known.keys.toList()[i]]["name"].toString().toLowerCase().contains(serverSearch.text.toLowerCase())){
        displayKnown[known.keys.toList()[i]] = known[known.keys.toList()[i]];
      }
    }
    notifyListeners();
    return displayKnown;
  }
  Future            updateCachedUsers() async{
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
  Future<List>      getAllUsers() async {
    // users.clear();
    loading = true;
    await logAdd("Loading users...", "info", "users", false);
    for(int i=0; i<known.length;i++){
      updatePercent = (i+1) / known.length;
      var keyVar = known[known.keys.toList()[i]]["addr"];
      if(!domains.containsKey(keyVar)){
        domains[keyVar] = [];
      }
      for(int a=0; a<domains[keyVar].length;a++){
        if(availables[keyVar]){
          if(toUpdate.isEmpty){
            if(logins.containsKey(keyVar)){
              await checkLogin(keyVar).then((huh) async {
                await fastpanelMailboxes(keyVar, domains[keyVar][a], logins[keyVar]["token"]).then((value) async {
                  updateTimes[domains[keyVar][a]["name"]] = DateTime.now().toUtc().millisecondsSinceEpoch;
                  domainUsers[domains[keyVar][a]["name"]] = value["data"];
                });
              });
            }
          }else{
            if(toUpdate.contains(domains[keyVar][a]["name"])){
              if(logins.containsKey(keyVar)){
                toUpdate.remove(domains[keyVar][a]["name"]);
                await checkLogin(keyVar).then((huh) async {
                  await fastpanelMailboxes(keyVar, domains[keyVar][a], logins[keyVar]["token"]).then((value) async {
                    updateTimes[domains[keyVar][a]["name"]] = DateTime.now().toUtc().millisecondsSinceEpoch;
                    domainUsers[domains[keyVar][a]["name"]] = value["data"];
                  });
                });
              }
            }
          }
        }
      }
      loadPercent = ((i+1)/known.length)/3 + 0.66;
    }
    await filterUsers();
    lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
    toUpdate.clear();
    await windowManager.setTitle("");
    loading = false;
    notifyListeners();
    return users;
  }
  Future<bool>      saveDomains() async{
    notifyListeners();
    setData(serverAddr, "domains", encrypt(jsonEncode(domains)).base64);
    return true;
  }
                    ignite() async {
    voisoLoading = true;
    voisoStatus = "Loading settings...";
    getVoisoBalances();
    activeVoisoClusters = {...voisoClusters.keys};
    getAllVoisoNumbers();
    List tempClusters = [];
    tempClusters.addAll(voisoClusters.keys);
    tempClusters.addAll(availCPs.keys);
    clusters = {
      "Voiso": voisoClusters.keys,
      "CP": availCPs.keys
    };
    for(int i=0;i<tempClusters.length;i++){
      if(clusters["CP"].contains(tempClusters[i])){
        cpCDR[tempClusters[i]] = {};
        allClusters[tempClusters[i]] = "CP";
      }else if(clusters["Voiso"].contains(tempClusters[i])){
        voisoCDR[tempClusters[i]] = {};
        allClusters[tempClusters[i]] = "Voiso";
      }else{
        allClusters[tempClusters[i]] = "UNKNOWN";
      }
    }
    getVoisoUsers().then((value){
      getVoisoTeams().then((value){
        filterVoisoUsers();
      });
    });
    voisoLoading = false;
    voisoStatus = "Loaded";
    print(allClusters);
  }
  Future<Map>       getVoisoUsers() async {
    for(int i=0; i < voisoClusters.length;i++){
      String endpoint = "${voisoClusters.keys.toList()[i]}.voiso.com";
      var params = {
        "key": voisoClusters[voisoClusters.keys.toList()[i]]["user"]
      };
      String method = "api/v3/cdr/users";
      final response = await http.get(
        Uri.https(
            endpoint, method, params
        ),
      );
      voisoUsers[voisoClusters.keys.toList()[i]] = jsonDecode(response.body);
    }
    return voisoUsers;
  }
  Future<Map>       getVoisoNumbers(page) async {
    String endpoint = "${activeVoisoClusters.elementAt(0)}.voiso.com";
    var params = {
      "page": page.toString()
    };
    var headers = {
      "Authorization": "Bearer ${voisoClusters[activeVoisoClusters.elementAt(0)]["center"]}"//hardcoded key is bad
    };
    String method = "api/numbers/v1/numbers";
    final response = await http.get(
      Uri.https(
          endpoint, method, params
      ),
      headers: headers
    );
    return jsonDecode(response.body);
  }
  Future<Map>       getAllVoisoNumbers() async {
    int numbersTotal = 0;
    int perPage =0;
    await getVoisoNumbers(1).then((value) async {
      numbersTotal = value["metadata"]["total"];
      perPage = value["metadata"]["page_size"];
      voisoNumbers.addAll(value["numbers"]);
      for(int i=2; i <= (numbersTotal ~/ perPage)+1;i++){
        await getVoisoNumbers(i).then((value){
          voisoNumbers.addAll(value["numbers"]);
        });
      }
    });
    return voisoUsers;
  }
  Map               getVoisoNumberInfo(number){
    for(int i=0;i<voisoNumbers.length;i++){
      if(voisoNumbers[i]["number"]==number){
        return voisoNumbers[i];
      }
    }
    return {};
  }
  String            getTeamByUserId(userid){
    var cluster = activeVoisoClusters.toList()[0];
    for(int s=0; s<voisoUsers[cluster].length;s++){
      if (voisoUsers[cluster][s]["id"].toString() == userid.toString()) {
        if(voisoUsers[cluster][s]["agent_in_teams"] == ""){
          print(voisoUsers[cluster][s]);
        }else{
          return voisoUsers[cluster][s]["agent_in_teams"].split(", ")[0];
        }
      }
    }
    return " - ";
  }
  String            getTeamName(id){
    for(int h=0; h < voisoClusters.length;h++) {
      for (int i = 0; i < voisoTeams[voisoClusters.keys.toList()[h]].length; i++) {
        if (voisoTeams[voisoClusters.keys.toList()[h]][i]["id"].toString() == id) {
          return voisoTeams[voisoClusters.keys.toList()[h]][i]["name"];
        }
      }
    }
    return " - ";
  }
  Future<Map>       getVoisoTeams() async {
    for(int i=0; i < voisoClusters.length;i++){
      String endpoint = "${voisoClusters.keys.toList()[i]}.voiso.com";
      var params = {
        "key": voisoClusters[voisoClusters.keys.toList()[i]]["user"]
      };
      String method = "api/v2/cdr/teams";
      final response = await http.get(
        Uri.https(
            endpoint, method, params
        ),
      );
      voisoTeams[voisoClusters.keys.toList()[i]] = jsonDecode(response.body);
    }
    return voisoTeams;
  }
  Future<Map>       getVoisoCDR(Map<String, dynamic> params, cluster) async {
    String endpoint = "$cluster.voiso.com";
    print("Sending Voiso CDR with $params");
    params["key"] = voisoClusters[cluster]["user"];
    String method = "api/v2/cdr";
    final response = await http.get(
      Uri.https(
          endpoint, method, params
      ),
    );
    return jsonDecode(response.body);
  }
  Future<Map>       getCPCDR(Map<String, dynamic> params, cluster) async {
    String endpoint = "${cluster}.stats.pbx.commpeak.com";
    params["api_key"] = availCPs[cluster];
    String method = "api/cdrs";
    final response = await http.post(
      Uri.https(
          endpoint, method, params
      ),
    );
    print(utf8.decoder.convert(response.bodyBytes));
    if(jsonDecode(utf8.decoder.convert(response.bodyBytes)).isEmpty){
      return {};
    }
    return jsonDecode(utf8.decoder.convert(response.bodyBytes));
  }
  Future<Map>       getStupidCDR() async {
    String cluster = dropController.text.split(": ")[1];
    switch(dropController.text.split(": ")[0]){
      case "Voiso":
        getVoisoStupidCDR(cdrSearch.text, cdrFromSearch.text, {
          "start_date": dateCDR.toIso8601String().split("T")[0],
          "disposition": answCDR ? "answered" : ""
        }, cluster).then((value) {});
        break;
      case "CP":
        getCPStupidCDR(cdrSearch.text, cdrFromSearch.text, {
          "from": "${dateCDR.toIso8601String().split("T")[0]} 00:00:00",
          "hangup_cause": answCDR ? "answered" : ""
        }, cluster).then((value) {});
        break;
    }
    return {};
  }
  Future<Map>       getVoisoStupidCDR(String load, String loadFrom, Map<String, dynamic> params, cluster) async {
    voisoCDR[cluster] = {};
    List numbers = RegExp(r'\d+').allMatches(load).map((m) => m.group(0)).toList();
    List numbersCli = RegExp(r'\d+').allMatches(loadFrom).map((m) => m.group(0)).toList();
    if(numbersCli.isEmpty){
      numbersCli.add("0");
    }
    if(numbers.isEmpty){
      numbers.add("0");
    }
    voisoCDR[cluster] = {};
    print(numbersCli);
    for(int h=0;h<numbersCli.length;h++) {
      await getVoisoCDR({
        "wildcard_cli": numbersCli[h].toString(),
        "per_page":1.toString()
      }, cluster).then((value){
        numbersFromAmountCalls[numbersCli[h]] = value["total"];
      });
    }
    for(int i=0;i<numbers.length;i++) {
      for(int s=0;s<numbersCli.length;s++) {
        int number = int.parse(numbers[i].trim().replaceAll(RegExp(r'[^0-9]'), ''));
        int numberCli = int.parse(numbersCli[s].trim().replaceAll(RegExp(r'[^0-9]'), ''));
        if(!(numberCli.toString=="0")){
          params["wildcard_cli"] = numberCli.toString();
        }
        if(!(number.toString()=="0")){
          print("Numeber = $number");
          params["number"] = number.toString();
        }
        await getVoisoCDR(params, cluster).then((value){
          if(numbers.isEmpty){
            voisoCDR[cluster][numberCli.toString()] = [];
            voisoCDR[cluster][numberCli.toString()].addAll(value["records"]);
          }else{
            voisoCDR[cluster][number.toString()] = [];
            voisoCDR[cluster][number.toString()].addAll(value["records"]);
          }
          progressCDR = i/numbers.length;
          notifyListeners();
          print(voisoCDR);
        });
      }
    }
    progressCDR = 0;
    notifyListeners();
    return voisoCDR;
  }
  Future<Map>       getCPStupidCDR(String load, String loadFrom, Map<String, dynamic> params, String cluster) async {
    cpCDR[cluster] = {};
    List numbers = RegExp(r'\d+').allMatches(load).map((m) => m.group(0)).toList();
    List numbersCli = RegExp(r'\d+').allMatches(loadFrom).map((m) => m.group(0)).toList();
    if(numbersCli.isEmpty){
      numbersCli.add("0");
    }
    if(numbers.isEmpty){
      numbers.add("0");
    }
    cpCDR[cluster] = {};
    for(int i=0;i<numbers.length;i++) {
      for(int s=0;s<numbersCli.length;s++) {
        int number = int.parse(numbers[i].trim().replaceAll(RegExp(r'[^0-9]'), ''));
        int numberCli = int.parse(numbersCli[s].trim().replaceAll(RegExp(r'[^0-9]'), ''));
        if(!(number.toString=="0")){
          params["destination"] = number.toString();
        }
        if(!(numberCli.toString=="0")){
          params["source"] = numberCli.toString();
        }
        params["sort_direction"] = "desc";
        await getCPCDR(params, cluster).then((value){
          if(value.isEmpty){
            cpCDR[cluster][number.toString()] = [];
          }else{
            cpCDR[cluster][number.toString()] = [];
            cpCDR[cluster][number.toString()].addAll(value["cdrs"]);
          }
          progressCDR = i/numbers.length;
          notifyListeners();
          print(cpCDR);
        });
      }
    }
    progressCDR = 0;
    notifyListeners();
    return cpCDR;
  }
  Future<List>      filterVoisoUsers() async {
    voisoUserCount = 0;
    filteredVoisoAgents.clear();
    for(int i=0; i < activeVoisoClusters.length;i++){
      print(activeVoisoClusters.toList()[i]);
      for(int s=0; s<voisoUsers[activeVoisoClusters.elementAt(i)].length;s++){
        voisoUserCount++;
        if (displayUsers) {
          if (filteredVoisoAgents.length < 100) {
            if(voisoUsers[activeVoisoClusters.elementAt(i)][s]["email"].contains(normUsername(voisoSearch.text))){
              filteredVoisoAgents.add(voisoUsers[activeVoisoClusters.elementAt(i)][s]);
            }
            if(!(voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"]==null)?voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"].contains(normUsername(voisoSearch.text)):false){
              if(!filteredVoisoAgents.contains(voisoUsers[activeVoisoClusters.elementAt(i)][s])){
                filteredVoisoAgents.add(voisoUsers[activeVoisoClusters.elementAt(i)][s]);
              }
            }
            if(!(voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"]==null)?voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"].contains(normUsername(voisoSearch.text)):false){
              if(!filteredVoisoAgents.contains(voisoUsers[activeVoisoClusters.elementAt(i)][s])){
                filteredVoisoAgents.add(voisoUsers[activeVoisoClusters.elementAt(i)][s]);
              }
            }
            if(voisoUsers[activeVoisoClusters.elementAt(i)][s]["email"].toLowerCase().trim().contains(normUsername(voisoSearch.text))){
              if(!filteredVoisoAgents.contains(voisoUsers[activeVoisoClusters.elementAt(i)][s])){
                filteredVoisoAgents.add(voisoUsers[activeVoisoClusters.elementAt(i)][s]);
              }
            }
          }
        }else{
          if(voisoUsers[activeVoisoClusters.elementAt(i)][s]["email"].contains(normUsername(voisoSearch.text))){
            filteredVoisoAgents.add(voisoUsers[activeVoisoClusters.elementAt(i)][s]);
          }
          if(!(voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"]==null)?voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"].contains(normUsername(voisoSearch.text)):false){
            if(!filteredVoisoAgents.contains(voisoUsers[activeVoisoClusters.elementAt(i)][s])){
              filteredVoisoAgents.add(voisoUsers[activeVoisoClusters.elementAt(i)][s]);
            }
          }
          if(!(voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"]==null)?voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"].contains(normUsername(voisoSearch.text)):false){
            if(!filteredVoisoAgents.contains(voisoUsers[activeVoisoClusters.elementAt(i)][s])){
              filteredVoisoAgents.add(voisoUsers[activeVoisoClusters.elementAt(i)][s]);
            }
          }
          if(voisoUsers[activeVoisoClusters.elementAt(i)][s]["email"].toLowerCase().trim().contains(normUsername(voisoSearch.text))) {
            if (!filteredVoisoAgents.contains(voisoUsers[activeVoisoClusters.elementAt(i)][s])) {
              filteredVoisoAgents.add(voisoUsers[activeVoisoClusters.elementAt(i)][s]);
            }
          }
        }
      }
    }
    notifyListeners();
    return filteredVoisoAgents;
  }
  bool              hasVoiso(search) {
    for(int i=0; i < activeVoisoClusters.length;i++){
      for(int s=0; s<voisoUsers[activeVoisoClusters.elementAt(i)].length;s++){
        if(voisoUsers[activeVoisoClusters.elementAt(i)][s]["email"].contains(search.toLowerCase().trim())){
          return true;
        }
        if(!(voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"]==null)?voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"].contains(search.toLowerCase().trim()):false){
          return true;
        }
        if(!(voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"]==null)?voisoUsers[activeVoisoClusters.elementAt(i)][s]["extension"].contains(search.toLowerCase().trim()):false){
          return true;
        }
        if(voisoUsers[activeVoisoClusters.elementAt(i)][s]["email"].toLowerCase().trim().contains(search.toLowerCase().trim())) {
          return true;
        }
      }
    }
    return false;
  }
                    getVoisoBalances(){
    Timer.periodic(Duration(seconds: 1), (timer) async {
      double sumBalances = 0;
      for(int i=0; i < voisoClusters.length;i++){
        String endpoint = "${voisoClusters.keys.toList()[i]}.voiso.com";
        String method = "api/v1/${voisoClusters[voisoClusters.keys.toList()[i]]["center"]}/balance";
        try {
          final response = await http.get(
            Uri.https(
                endpoint, method
            ),
          );
          if(jsonDecode(response.body).containsKey("error")){
            voisoBalances[voisoClusters.keys.toList()[i]] = 0;
          }else{
            voisoBalances[voisoClusters.keys.toList()[i]] = jsonDecode(response.body)["balance"];
            sumBalances = sumBalances + jsonDecode(response.body)["balance"];
          }
        } catch (_) {
          voisoBalances[voisoClusters.keys.toList()[i]] = 0;
        }
      }
      balance = double.parse(sumBalances.toStringAsFixed(2));
      notifyListeners();
    });
  }
                    getCPBalances(){
    Timer.periodic(Duration(seconds: 1), (timer) async {
      double sumBalances = 0;
      for(int i=0; i < availCPs.length;i++){
        String endpoint = "${availCPs.keys.toList()[i]}.voiso.com";
        String method = "api/v1/${voisoClusters[availCPs.keys.toList()[i]]["center"]}/balance";
        try {
          final response = await http.get(
            Uri.https(
                endpoint, method
            ),
          );
          if(jsonDecode(response.body).containsKey("error")){
            voisoBalances[voisoClusters.keys.toList()[i]] = 0;
          }else{
            voisoBalances[voisoClusters.keys.toList()[i]] = jsonDecode(response.body)["balance"];
            sumBalances = sumBalances + jsonDecode(response.body)["balance"];
          }
        } catch (_) {
          voisoBalances[voisoClusters.keys.toList()[i]] = 0;
        }
      }
      balance = double.parse(sumBalances.toStringAsFixed(2));
      notifyListeners();
    });
  }
  Future<bool>      checkVoisoCluster(endpoint) async {
    try {
      final response = await http.head(Uri.https("$endpoint.voiso.com"));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
  Future<bool>      checkCPCluster(endpoint) async {
    try {
      final response = await http.head(Uri.https("$endpoint.stats.pbx.commpeak.com"));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
  Future<bool>      checkVoisoCCKey(cluster, center) async {
    var endpoint = "$cluster.voiso.com";
    var method = "api/v1/$center/balance";
    final response = await http.get(
      Uri.https(
          endpoint, method
      ),
    );
    if(jsonDecode(response.body).containsKey("error")){
      return false;
    }else{
      return true;
    }
  }
  Future<bool>      checkVoisoUKey(cluster, agent) async {
    var params = {
      "key": agent
    };
    var endpoint = "$cluster.voiso.com";
    var method = "api/v2/cdr/wrapup_codes";
    final response = await http.get(
      Uri.https(
          endpoint, method, params
      ),
    );
    try{
      if(jsonDecode(response.body)[0]["description"] == "0000: Click here"){
        return true;
      }else{
        return false;
      }
    }catch(_){
      return false;
    }
  }
  Future<bool>      saveVoisoKeys(cluster, agent, center) async{
    clusterValid = await checkVoisoCluster(cluster);
    userValid = await checkVoisoUKey(cluster, agent);
    centerValid = await checkVoisoCCKey(cluster, center);
    if(clusterValid&&userValid&&centerValid){
      voisoClusters[cluster] = {
        "cluster":cluster,
        "user":agent,
        "center":center
      };
    }
    setData(serverAddr, "voiso", encrypt(jsonEncode(voisoClusters)).base64);
    return true;
  }
  Future<bool>      updateVoisoData() async{
    setData(serverAddr, "voiso", encrypt(jsonEncode(voisoClusters)).base64);
    return true;
  }
  Future<Map>       checkNumber(num) async {
    numCheckStatus = "Parsing numbers";
    isNumCheck = true;
    numCheckProgress = 0;
    notifyListeners();
    Map checks = {};
    numCheckVerdict = "";
    List numbers = RegExp(r'\d+').allMatches(numinput.text).map((m) => m.group(0)).toList();
    if(numbers.toString() == ""){
      return checks;
    }
    for(int i=0;i<numbers.length;i++){
      int number = int.parse(numbers[i].trim().replaceAll(RegExp(r'[^0-9]'), ''));
      numCheckStatus = "Checking $number on UNIVoIP (1/2)";
      numCheckProgress = numbers.length<2?0:(i)/numbers.length;
      notifyListeners();
      checks[number] = {};
      numCheckVerdict = "$numCheckVerdict${number.toString()}";
      await checkUNIFixed(number).then((value) async {
        numCheckStatus = "Checking $number on UNIVoIP (2/2)";
        numCheckProgress = numbers.length<2?0:(i+0.25)/numbers.length;
        notifyListeners();
        checks[number]["UNIFixed"] = value;
        await checkUNIHLR(number).then((value) async {
          numCheckStatus = "Checking $number on CommPeak";
          numCheckProgress = numbers.length<2?0:(i+0.5)/numbers.length;
          notifyListeners();
          checks[number]["UNIHLR"] = value;
          await checkCP(number).then((value) async {
            numCheckStatus = "Got HRL for $number";
            numCheckProgress = numbers.length<2?0:(i+0.75)/numbers.length;
            checks[number]["CP"] = value;
            bool isValid = false;
            bool isMobile = false;
            bool isAvailable = false;

            if(checks[number]["UNIFixed"]["error"] == 1 && checks[number]["UNIHLR"]["error"]==1){
              await logAdd("UNIVoip is unavailable for HLR", "error", "voip", false);
              if(checks[number]["CP"]["hlr"]["hlr_status"]=="Active"){
                isAvailable = true;
              }
              if(checks[number]["CP"]["validation"]["mobile"]){
                isMobile = true;
              }
              if(checks[number]["CP"]["validation"]["valid"]){
                isValid = true;
              }
            }else{
              if(checks[number]["UNIHLR"]["result"]=="DELIVERED" && checks[number]["CP"]["hlr"]["hlr_status"]=="Active"){
                isAvailable = true;
              }
              if(checks[number]["UNIFixed"]["result"]=="mobile" && checks[number]["CP"]["validation"]["mobile"]){
                isMobile = true;
              }
              if(checks[number]["CP"]["validation"]["valid"]){
                isValid = true;
              }
            }
            await logAdd("HLR test performed for $number", "info", "voip", false);
            numCheckVerdict = "$numCheckVerdict - ${isValid?"Valid, ${isMobile?"Mobile, ${(isAvailable)?"Available":"Unreachable"}":"Fixed"}":"Invalid"}";

            // if(checks[number]["UNIFixed"]["error"] == 1 && checks[number]["UNIHLR"]["error"]==1){
            //   if(checks[number]["CP"]["validation"]["mobile"]){
            //     verdict = "$verdict - Valid${checks[number]["CP"]["validation"]["number_type"]==null?"":" (${checks[number]["CP"]["validation"]["mobile"]==null?"Unavailable":checks[number]["CP"]["validation"]["mobile"]?"Mobile":"Fixed"}, ${checks[number]["CP"]["result"]})"}";
            //   }else{
            //     verdict = "$verdict - Invalid (${checks[number]["CP"]["result"]=="unsupported request"?"${checks[number]["CP"]["validation"]["mobile"]==null?"Unavailable/":checks[number]["CP"]["validation"]["mobile"]?"Mobile/":"Fixed/"}${checks[number]["CP"]["validation"]["number_type"]}":checks[number]["CP"]["result"]})";
            //   }
            // }else{
            //   if(checks[number]["UNIFixed"]["result"]=="mobile" && checks[number]["CP"]["validation"]["mobile"] && checks[number]["UNIHLR"]["result"]=="DELIVERED"){
            //     verdict = "$verdict - Valid${checks[number]["CP"]["validation"]["number_type"]==null?"":" (${checks[number]["CP"]["validation"]["mobile"]==null?"Unavailable":checks[number]["CP"]["validation"]["mobile"]?"Mobile":"Fixed"}, ${checks[number]["CP"]["result"]})"}";
            //   }else{
            //     verdict = "$verdict - Invalid (${checks[number]["CP"]["result"]=="unsupported request"?"${checks[number]["CP"]["validation"]["mobile"]==null?"Unavailable/":checks[number]["CP"]["validation"]["mobile"]?"Mobile/":"Fixed/"}${checks[number]["CP"]["validation"]["number_type"]}":checks[number]["CP"]["validation"]["number_type"]})";
            //   }
            // }
            if(i+1<numbers.length){
              numCheckVerdict = "$numCheckVerdict\n";
            }
          });
        });
      });
    }
    await Clipboard.setData(ClipboardData(text: numCheckVerdict));
    numCheckResult = checks;
    isNumCheck = false;
    return checks;
  }
  Future<Map>       checkCP(number) async {
    var headers = {
      "Authorization": "1dd38d6df256bfc96229aada394752cc"//hardcoded key is bad
    };
    var endpoint = "hlr.commpeak.com";
    var method = "sync/hlr/$number";
    final response = await http.get(
        Uri.https(
            endpoint, method
        ),
        headers: headers
    );
    return jsonDecode(response.body);
  }
  Future<Map>       checkUNIHLR(number) async {
    // return {"error":1,"result":"Server unavailable"};
    var params = {
      "loc": "voip_api_get_hlr"
    };
    var body = {
      "token": "2d4a81cc23a4ae7f4d2e0d609370ae12",//hardcoded key is bad
      "number": number.toString()
    };
    var endpoint = "univoip.co";
    var method = "";
    try {
      final response = await http.post (
          Uri.https(
              endpoint, method,params
          ),
          body: body
      );
      return jsonDecode(response.body);
    } catch (_) {
      return {"error":1,"result":"Server unavailable"};
    }
  }
  Future<Map>       checkUNIFixed(number) async {
    // return {"error":1,"result":"Server unavailable"};
    var params = {
      "loc": "voip_api_get_mobile"
    };
    var body = {
      "token": "2d4a81cc23a4ae7f4d2e0d609370ae12",//hardcoded key is bad
      "number": number.toString()
    };
    var endpoint = "univoip.co";
    var method = "";
    try {
      final response = await http.post (
          Uri.https(
              endpoint, method,params
          ),
          body: body
      );
      return jsonDecode(response.body);
    } catch (_) {
      return {"error":1,"result":"Server unavailable"};
    }
  }
}