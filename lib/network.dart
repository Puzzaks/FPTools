
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:onetool/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProxyOverride extends HttpOverrides{
  late Map proxy;
  ProxyOverride({required this.proxy});
  @override
  HttpClient createHttpClient(SecurityContext? context){
    HttpClient client = super.createHttpClient(context);
    client.addProxyCredentials(
          proxy["address"],
          int.parse(proxy["port"]),
          'main',
          HttpClientBasicCredentials(
              proxy["username"],
              proxy["password"]
          )
      );
    client.findProxy = ((uri) => 'PROXY ${proxy["address"]}:${proxy["port"]}');
    client.badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
    return client;
  }
}
class CertificateOverride extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

String decrypt(Encrypted encryptedData) {
  final key = Key.fromUtf8(md5.convert(utf8.encode(md5.convert(utf8.encode("113245-FPT")).toString())).toString());
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final initVector = IV.fromUtf8(md5.convert(utf8.encode(md5.convert(utf8.encode("113245-FPT")).toString())).toString().substring(0, 16));
  return encrypter.decrypt(encryptedData, iv: initVector);
}

Future<String> getData(val) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isProxyUsed = false;
  if(prefs.containsKey("isProxyUsed")){
    isProxyUsed = prefs.getBool("isProxyUsed")??false;
  }
  var params = {
  'type': val
  };
  var endpoint = isProxyUsed?"95.67.123.210:6060":"172.17.6.248:6060";
  var method = "api/getData.php";
  final response = await http.get(
    Uri.http(
        endpoint, method, params
    ),
  );
  return response.body;
}

Future<String> setData(data, body) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isProxyUsed = false;
  if(prefs.containsKey("isProxyUsed")){
    isProxyUsed = prefs.getBool("isProxyUsed")??false;
  }
  var endpoint = isProxyUsed?"95.67.123.210:6060":"172.17.6.248:6060";
  const method = "api/setData.php";
  final response = await http.post(
    Uri.http(
        endpoint, method
    ),
      body: jsonEncode(
          {
          "type": data,
          "data": body
        }
      )
  );
  return response.body;
}

Future <Map> fastpanelLogin(ip, user, key) async {
  Map data = {
    'username': user,
    'password': key
  };
  var body = json.encode(data);
  var endpoint = "$ip:8888";
  const method = "login";
  final response = await http.post(
      Uri.https(
          endpoint, method
      ),
      body: body
  );
  return jsonDecode(response.body);
}

Future fastpanelMailboxes(ip, domain, key) async {
  var headers = {
    'Authorization': "Bearer $key",
  };
  var endpoint = "$ip:8888";
  var method = "api/email/domains/${domain["id"]}/boxs";
  final response = await http.get(
      Uri.https(endpoint, method),
      headers: headers
  );
  return jsonDecode(response.body);
}

Future<Map> fastpanelDeleteUser(id, ip, key) async {
  var headers = {
    'Authorization': "Bearer $key",
  };
  var endpoint = "$ip:8888";
  var method = "/api/mail/box/$id";
  final response = await http.delete(
      Uri.https(endpoint, method),
      headers: headers
  );
  return jsonDecode(response.body);
}

Future<Map> fastpanelUpdateUser(id, newpass, ip, key) async {
  var headers = {
    'Authorization': "Bearer $key",
  };
  Map data = {
    'password': newpass
  };
  var body = json.encode(data);
  var endpoint = "$ip:8888";
  var method = "/api/mail/box/$id";
  final response = await http.put(
      Uri.https(endpoint, method),
      body: body,
      headers: headers
  );
  return jsonDecode(response.body);
}

Future<Map> fastpanelCreateUser(id, ip, username, password, key) async {
  var headers = {
    'Authorization': "Bearer $key",
  };
  Map data = {
    "login": "$username",
    "password": "$password"
  };
  var body = json.encode(data);
  var endpoint = "$ip:8888";
  var method = "api/email/domains/$id/boxs";
  final response = await http.post(
      Uri.https(
          endpoint, method
      ),
      body: body,
      headers: headers
  );
  return jsonDecode(response.body);
}

Future fastpanelSites(ip, key) async {
  var params = {
    "filter[limit]": "20",
    "filter[type]": "all"
  };
  var headers = {
    'Authorization': "Bearer $key",
  };
  var endpoint = "$ip:8888";
  const method = "api/sites/list";
  final response = await http.get(
      Uri.https(endpoint, method, params),
      headers: headers
  );
  return jsonDecode(response.body);
}

Future fastpanelDomains(ip, site, key) async {
  var headers = {
    'Authorization': "Bearer $key",
  };
  var endpoint = "$ip:8888";
  var method = "api/sites/$site/email/domains";
  final response = await http.get(
      Uri.https(endpoint, method),
      headers: headers
  );
  return jsonDecode(response.body);
}

Future<bool> checkConnect(ip) async {
  var endpoint = "$ip:8888";
  try {
    final response = await http.head(Uri.https(endpoint));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
Future<bool> pingServer() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isProxyUsed = false;
  if(prefs.containsKey("isProxyUsed")){
    isProxyUsed = prefs.getBool("isProxyUsed")??false;
  }
  var endpoint = isProxyUsed?"95.67.123.210:6060":"172.17.6.248:6060";
  try {
    final response = await http.get(Uri.http(endpoint));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
Future<bool> pingProxy(address, creds) async {
  try {
    final response = await http.head(
        Uri.http(address),
        headers: {
          "Proxy-Authorization": "Basic ${base64.encode(utf8.encode(creds))}"
        }
    );
    return response.statusCode == 503;
  } catch (e) {
    return false;
  }
}