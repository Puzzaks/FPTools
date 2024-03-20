
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
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
    'login': username,
    'password': password
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