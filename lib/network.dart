
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:onetool/engine.dart';
import 'package:provider/provider.dart';

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
  fastEngine().logAdd(response.body, "info", "netlogin", true);
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
  fastEngine().logAdd(response.body, "info", "netusers", true);
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
  fastEngine().logAdd(response.body, "info", "netdelete", true);
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
  fastEngine().logAdd(response.body, "info", "netupdate", true);
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
  fastEngine().logAdd(response.body, "info", "netcreate", true);
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
  fastEngine().logAdd(response.body, "info", "netsites", true);
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
  fastEngine().logAdd(response.body, "info", "netdomains", true);
  return jsonDecode(response.body);
}

Future<bool> checkConnect(ip) async {
  var endpoint = "$ip:8888";
  try {
    final response = await http.head(Uri.https(endpoint));
    fastEngine().logAdd("Pinged $ip (${response.statusCode})", "info", "ping", true);
    return response.statusCode == 200;
  } catch (_) {
    fastEngine().logAdd("Pinged $ip (unavailable)", "warn", "ping", true);
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
    await fastEngine().logAdd("Proxy returned ${response.statusCode}", "info", "ping", true);
    return response.statusCode == 503;
  } catch (e) {
    return false;
  }
}