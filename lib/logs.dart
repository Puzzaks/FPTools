import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'engine.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});
  @override
  LogsPageState createState() => LogsPageState();
}
extension DateTimeExtension on DateTime {
  String timeAgo({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(this);
    if ((difference.inDays / 7).floor() >= 1) {
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
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}
class LogsPageState extends State<LogsPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
    final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
    List expanded = [];
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
          return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            double scaffoldHeight = constraints.maxHeight;
            double scaffoldWidth = constraints.maxWidth;
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: scaffoldHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          children: engine.logs.reversed.map((log) {
                            DateTime time = DateTime.fromMillisecondsSinceEpoch(log["time"]);
                            Icon logIco = Icon(Icons.error_rounded);
                            Color entryColor = Colors.transparent;
                            switch(log["type"]){
                              case ("info"):
                                entryColor = Theme.of(context).colorScheme.background;
                                break;
                              case("error"):
                                entryColor = Theme.of(context).colorScheme.error;
                                break;
                              default:entryColor = Colors.transparent;
                            }
                            switch(log["thread"]){
                              case "filtering":
                                logIco = Icon(Icons.filter_alt_rounded);
                                break;
                              case "getting":
                                logIco = Icon(Icons.download_rounded);
                                break;
                              case "users":
                                logIco = Icon(Icons.person_outline_rounded);
                                break;
                              case "creation":
                                logIco = Icon(Icons.person_add_alt_outlined);
                                break;
                              case "deletion":
                                logIco = Icon(Icons.person_remove_outlined);
                                break;
                              case "updating":
                                logIco = Icon(Icons.person_pin_rounded);
                                break;
                              case "startup":
                                logIco = Icon(Icons.update_rounded);
                                break;
                              case "login":
                                logIco = Icon(Icons.login_rounded);
                                break;
                              case "voip":
                                logIco = Icon(Icons.dialer_sip_rounded);
                                break;
                              default:
                                logIco = Icon(Icons.question_mark_rounded);
                            }
                            return Container(
                              width: scaffoldWidth - 12,
                              color: entryColor,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    logIco,
                                    Container(
                                      width: 200,
                                      child: Text("${DateFormat('HH:mm:ss').format(time)} (${time.timeAgo(numericDates: false)})  ")
                                    ),
                                    Container(
                                        width: scaffoldWidth-246,
                                        child: log["array"]?GestureDetector(
                                          onTap: (){if(expanded.contains(log["log"])){
                                            expanded.remove(log["log"]);
                                          }else{
                                            expanded.add(log["log"]);
                                          }
                                            setState(() {

                                          });},
                                          child: expanded.contains(log["log"])?Text(
                                            log["log"].toString(),
                                          ):Text("Data from ${log["thread"]} thread. Click to expand."),
                                        ):Text(
                                          log["log"].toString(),
                                        )
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