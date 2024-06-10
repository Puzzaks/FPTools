import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'engine.dart';

class NumberCheckPage extends StatefulWidget {
  const NumberCheckPage({super.key});
  @override
  NumberCheckPageState createState() => NumberCheckPageState();
}

class NumberCheckPageState extends State<NumberCheckPage> {
  @override
  @override
  void initState() {
    super.initState();
  }
  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  int checkCount = 0;
  bool isShift = false;
  final FocusNode _focusNode = FocusNode();
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
          return KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (event) {
              if (event is KeyUpEvent && event.logicalKey.keyLabel == "Shift Left") {
                isShift = false;
              }
              if (event is KeyDownEvent && event.logicalKey.keyLabel == "Shift Left") {
                isShift = true;
              }
              if (event is KeyUpEvent && event.logicalKey.keyLabel == "Enter" && !isShift) {
                if(engine.numinput.text.isEmpty && !engine.isNumCheck){}else{
                  engine.numCheckResult = {};
                  checkCount = 0;
                  if(engine.numinput.text.isEmpty){

                  }else{
                    engine.checkNumber(engine.numinput.text).then((value){});
                    checkCount = 0;
                  }
                }
              }
            },
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double scaffoldHeight = constraints.maxHeight;
                  double scaffoldWidth = constraints.maxWidth;
                  return Scaffold(
                    floatingActionButton: engine.numCheckResult.isEmpty?null:FloatingActionButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: engine.numCheckVerdict));
                      },
                      child: const Icon(Icons.copy_rounded),
                    ),
                    body: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextField(
                                controller: engine.numinput,
                                autofocus: true,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                                scrollPadding: const EdgeInsets.all(0),
                                expands: false,
                                minLines: null,
                                maxLines: null,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(top:15, bottom: 0,left: 10, right: 10),
                                  // prefixIcon: const Icon(Icons.dialpad_rounded),
                                  labelText: 'Enter numbers',
                                  constraints: BoxConstraints(
                                      maxWidth: 200,
                                      minHeight: 120,
                                      maxHeight: scaffoldHeight - 57
                                  ),
                                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                                ),
                              ),
                            ),
                            Container(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5,bottom: 10),
                                child: FilledButton(
                                    onPressed: engine.numinput.text.isEmpty && !engine.isNumCheck?null:(){
                                      engine.numCheckResult = {};
                                      checkCount = 0;
                                      if(engine.numinput.text.isEmpty){

                                      }else{
                                        engine.checkNumber(engine.numinput.text).then((value){});
                                        checkCount = 0;
                                      }
                                    },
                                    child: const Text("Send")
                                ),
                              ),
                            )
                          ],
                        ),
                        const VerticalDivider(thickness: 1, width: 1,),
                        engine.numCheckResult.isEmpty?Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            !engine.isNumCheck?Container(
                              width: scaffoldWidth - 211,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(),
                                  Card(
                                    child: Container(
                                      width: 320,
                                      child: const Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 0),
                                              child: Text(
                                                "Send numbers to load HLR",
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                              ),
                                            ),
                                            Text(
                                              "Results are copied automatically.",
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container()
                                ],
                              ),
                            ):
                            Container(
                              width: scaffoldWidth - 211,
                              height: scaffoldHeight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                  ),
                                  Card(
                                    child: Container(
                                      width: 320,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(padding: const EdgeInsets.only(bottom: 10),
                                              child: Text(engine.numCheckStatus),),
                                            LinearProgressIndicator(
                                              value: engine.numCheckProgress == 0?null:engine.numCheckProgress,
                                              backgroundColor: Colors.transparent,
                                              borderRadius: const BorderRadius.all(Radius.circular(3)),
                                              color: Theme.of(context).colorScheme.primary,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                            : SingleChildScrollView(
                          child: Column(
                            children: engine.numCheckResult.keys.map((number){
                              String verdict = "";
                              bool isValid = false;
                              bool isMobile = false;
                              bool isAvailable = false;
                              checkCount + 1;
                              if(engine.numCheckResult[number]["UNIFixed"]["error"] == 1 && engine.numCheckResult[number]["UNIHLR"]["error"]==1){
                                if(engine.numCheckResult[number]["CP"]["hlr"]["hlr_status"]=="Active"){
                                  isAvailable = true;
                                }
                                if(engine.numCheckResult[number]["CP"]["validation"]["mobile"]){
                                  isMobile = true;
                                }
                                if(engine.numCheckResult[number]["CP"]["validation"]["valid"]){
                                  isValid = true;
                                }
                              }else{
                                if(engine.numCheckResult[number]["UNIHLR"]["result"]=="DELIVERED" && engine.numCheckResult[number]["CP"]["hlr"]["hlr_status"]=="Active"){
                                  isAvailable = true;
                                }
                                if(engine.numCheckResult[number]["UNIFixed"]["result"]=="mobile" && engine.numCheckResult[number]["CP"]["validation"]["mobile"]){
                                  isMobile = true;
                                }
                                if(engine.numCheckResult[number]["CP"]["validation"]["valid"]){
                                  isValid = true;
                                }
                              }
                              verdict = "${isValid?"Valid, ${isMobile?"Mobile, ${(isAvailable)?"Available":"Unreachable"}":"Fixed"}":"Invalid"}";

                              // if(engine.numCheckResult[number]["UNIFixed"]["error"] == 1 && engine.numCheckResult[number]["UNIHLR"]["error"]==1){
                              //   if(engine.numCheckResult[number]["CP"]["validation"]["mobile"]){
                              //     verdict = "Check UNI / Valid ${engine.numCheckResult[number]["CP"]["validation"]["number_type"]==null?"":" (${engine.numCheckResult[number]["CP"]["validation"]["mobile"]==null?"Unavailable":engine.numCheckResult[number]["CP"]["validation"]["mobile"]?"Mobile":"Fixed"}, ${engine.numCheckResult[number]["CP"]["result"]})"}";
                              //   }else{
                              //     verdict = "Check UNI / Invalid (${engine.numCheckResult[number]["CP"]["result"]=="unsupported request"?"${engine.numCheckResult[number]["CP"]["validation"]["mobile"]==null?"Unavailable/":engine.numCheckResult[number]["CP"]["validation"]["mobile"]?"Mobile/":"Fixed/"}${engine.numCheckResult[number]["CP"]["validation"]["number_type"]}":engine.numCheckResult[number]["CP"]["result"]})";
                              //   }
                              // }else{
                              //   if(engine.numCheckResult[number]["UNIFixed"]["result"]=="mobile" && engine.numCheckResult[number]["CP"]["validation"]["mobile"] && engine.numCheckResult[number]["UNIHLR"]["result"]=="DELIVERED"){
                              //     verdict = "Valid${engine.numCheckResult[number]["CP"]["validation"]["number_type"]==null?"":" (${engine.numCheckResult[number]["CP"]["validation"]["mobile"]==null?"Unavailable":engine.numCheckResult[number]["CP"]["validation"]["mobile"]?"Mobile":"Fixed"}, ${engine.numCheckResult[number]["CP"]["result"]})"}";
                              //   }else{
                              //     verdict = "Invalid (${engine.numCheckResult[number]["CP"]["result"]=="unsupported request"?"${engine.numCheckResult[number]["CP"]["validation"]["mobile"]==null?"Unavailable/":engine.numCheckResult[number]["CP"]["validation"]["mobile"]?"Mobile/":"Fixed/"}${engine.numCheckResult[number]["CP"]["validation"]["number_type"]}":engine.numCheckResult[number]["CP"]["validation"]["number_type"]})";
                              //   }
                              // }
                              return Container(
                                width: scaffoldWidth - 211,
                                child: ExpansionTileTheme(
                                    data: const ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15)),
                                    child: Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                          title: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              engine.numCheckResult[number]["CP"]["validation"]["country_iso2"]==null?Container():Padding(
                                                padding: const EdgeInsets.only(top: 4, right: 10),
                                                child: Image.network(
                                                  "https://flagsapi.com/${engine.numCheckResult[number]["CP"]["validation"]["country_iso2"]}/flat/64.png",
                                                  height: 28,
                                                ),
                                              ),
                                              Container(
                                                width: 120,
                                                child: Text(
                                                  number.toString(),
                                                  style: TextStyle(
                                                      fontFamily: engine.demoMode?"Flow":null
                                                  ),
                                                ),
                                              ),
                                              const VerticalDivider(),
                                              Text(
                                                verdict,
                                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Card(
                                                  color: (engine.numCheckResult[number]["UNIFixed"]["error"] == 1 && engine.numCheckResult[number]["UNIHLR"]["error"]==1)?Theme.of(context).colorScheme.errorContainer:null,
                                                  clipBehavior: Clip.hardEdge,
                                                  elevation: 2,
                                                  child: Container(
                                                    width: scaffoldWidth - 220,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Padding(
                                                              padding: EdgeInsets.only(bottom: 5),
                                                              child:Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    "UNIVoip",
                                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                                  ),
                                                                  Text(
                                                                    "бесценно",
                                                                    style: TextStyle(),
                                                                  )
                                                                ],
                                                              )
                                                          ),
                                                          Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              const Text(
                                                                "Type",
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text(
                                                                "${engine.numCheckResult[number]["UNIFixed"]["result"]}",
                                                                style: const TextStyle(),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              const Text(
                                                                "Status",
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text(
                                                                "${engine.numCheckResult[number]["UNIHLR"]["result"]=="DELIVERED"?"Available":"Unavailable"}",
                                                                style: const TextStyle(),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  elevation: 2,
                                                  child: Container(
                                                    width: scaffoldWidth - 220,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Padding(
                                                              padding: EdgeInsets.only(bottom: 5),
                                                              child:Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    "CommPeak Validation",
                                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                                  ),
                                                                  Text(
                                                                    "0\$",
                                                                    style: TextStyle(),
                                                                  )
                                                                ],
                                                              )
                                                          ),
                                                          Container(
                                                            color: engine.numCheckResult[number]["CP"]["validation"]["valid"]?null:Theme.of(context).colorScheme.errorContainer,
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                const Text(
                                                                  "Valid?",
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                                Text(
                                                                  engine.numCheckResult[number]["CP"]["validation"]["valid"]?"Valid":"Invalid",
                                                                  style: const TextStyle(fontWeight: FontWeight.w500,),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              const Text(
                                                                "Full Number",
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text(
                                                                "${engine.numCheckResult[number]["CP"]["validation"]["international"]==null?"Incorrect number":engine.numCheckResult[number]["CP"]["validation"]["international"]}",
                                                                  style: TextStyle(
                                                                  fontFamily: engine.demoMode?"Flow":null
                                                              ),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              const Text(
                                                                "Status",
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text(
                                                                "${engine.numCheckResult[number]["CP"]["result"]}",
                                                                style: const TextStyle(),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              const Text(
                                                                "Type",
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text(
                                                                "${engine.numCheckResult[number]["CP"]["validation"]["mobile"]==null?"Incorrect":engine.numCheckResult[number]["CP"]["validation"]["mobile"]?"Mobile":"Fixed"}${engine.numCheckResult[number]["CP"]["validation"]["number_type"]==null?"":" (${engine.numCheckResult[number]["CP"]["validation"]["number_type"]})"}",
                                                                style: const TextStyle(),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              const Text(
                                                                "Country",
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text(
                                                                "${engine.numCheckResult[number]["CP"]["validation"]["country_iso2"]==null?"Unavailable":engine.numCheckResult[number]["CP"]["validation"]["country_iso2"]}",
                                                                style: const TextStyle(),
                                                              )
                                                            ],
                                                          ),
                                                          engine.numCheckResult[number]["CP"]["validation"]["reason"]==null?Container():
                                                          Text("Notes: ${engine.numCheckResult[number]["CP"]["validation"]["reason"]}"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  elevation: 2,
                                                  child: Container(
                                                    width: scaffoldWidth - 220,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                              padding: const EdgeInsets.only(bottom: 5),
                                                              child:Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  const Text(
                                                                    "CommPeak HLR",
                                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                                                                  ),
                                                                  Text(
                                                                    "${engine.numCheckResult[number]["CP"]["cost"]}\$",
                                                                    style: const TextStyle(),
                                                                  )
                                                                ],
                                                              )
                                                          ),
                                                          engine.numCheckResult[number]["CP"]["hlr"]["hlr_status"] == "unsupported request"
                                                              ? Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const Text(
                                                                "Unable to perform HLR test",
                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text("Reason: ${engine.numCheckResult[number]["CP"]["hlr"]["description"]}"),
                                                            ],
                                                          )
                                                              : Column(
                                                            children: [
                                                              Row(
                                                                mainAxisSize: MainAxisSize.max,
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                    "Status",
                                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                                  ),
                                                                  Text(
                                                                    "${engine.numCheckResult[number]["CP"]["hlr"]["hlr_status"]}",
                                                                    style: const TextStyle(),
                                                                  )
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.max,
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                    "Network",
                                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                                  ),
                                                                  Text(
                                                                    "${engine.numCheckResult[number]["CP"]["hlr"]["network_name"]==null?"Unknown":engine.numCheckResult[number]["CP"]["hlr"]["network_name"]}",
                                                                    style: const TextStyle(),
                                                                  )
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.max,
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                    "Country",
                                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                                  ),
                                                                  Text(
                                                                    "${engine.numCheckResult[number]["CP"]["hlr"]["country_name"]}",
                                                                    style: const TextStyle(),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  elevation: 2,
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      launchUrlString("callto://${number.toString()}");
                                                    },
                                                    child: Container(
                                                      width: scaffoldWidth - 220,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(15),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Padding(
                                                                padding: const EdgeInsets.only(bottom: 0),
                                                                child:Text(
                                                                  "Call ${number.toString()}",
                                                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18,
                                                                      fontFamily: engine.demoMode?"Flow":null),
                                                                )
                                                            ),
                                                            Padding(
                                                                padding: const EdgeInsets.only(bottom: 0),
                                                                child:IconButton(
                                                                  icon: const Icon(Icons.call_rounded),
                                                                  onPressed: (){
                                                                    launchUrlString("callto://${number.toString()}");
                                                                  },
                                                                )
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                    )
                                ),
                              );
                            }).toList().cast<Widget>(),
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
          );
        }),
      );
    });
  }
}