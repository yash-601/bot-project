
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'profile.dart';
import 'api.dart';
import 'dart:convert';
import 'db_ops/db.dart';

class Home extends StatefulWidget {
  final String email;
  final String name;
  Home({Key? key, required this.name, required this.email}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int msgNo = 1;
  List messages = [];
  final TextEditingController _input = TextEditingController();

  // adding this to initialize dialogflowter
  late DialogFlowtter dialogFlowtter;
  @override
  void initState() {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    super.initState();
  }


  void addMsgToList(List message) {
    setState(() {
      messages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          leading: BackButton(
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<int>(
                    value : 0,
                    child: Text('Profile')
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text("Settings")
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text("Log out"),
                  ),
                ];
              },
              onSelected: (value) async {
                if (value == 0) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Profile(user: widget.name, mail: widget.email))
                  );
                }
                else if (value == 2) {
                  await FirebaseAuth.instance.signOut();
                }
              }
            )
          ],
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset(
              'assets/images/best.jpg',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Column(
              children: [
                const SizedBox(height: 30.0),
                Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        msgNo++;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 8.0, 0.0)  ,
                          child: Container(
                            margin: messages[index][1] ? const EdgeInsets.fromLTRB(100.0, 0.0, 5.0, 0.0) : const EdgeInsets.fromLTRB(5.0, 0.0, 100.0, 0.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15.0, 10.0, 8.0, 10.0),
                              child: messages[index][1] ? Text(
                                '${messages[index][0]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0
                                )
                              ) : Linkify(
                                text: '${messages[index][0]}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                ),
                                onOpen: _onOpen,
                              )
                            ),
                          ),
                        );
                      },
                    )
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    elevation: 20.0,
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 5.0),
                            child: TextField(
                              maxLines: null,
                              controller: _input,
                              cursorColor: Colors.white,
                              keyboardType: TextInputType.multiline,
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.white
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            String msg = _input.text;
                            // send query to python api here -> http://10.0.2.2:5000
                            Uri url = Uri.parse("https://bot-web-service.onrender.com/api?Query=$msg");
                            setState(() {
                              _input.text = "";
                            });
                            addMsgToList([msg, true]);

                            msg = msg.toLowerCase();
                            if (msg.contains('hii') || msg.contains('hey') || msg.contains('hello')
                                || msg.contains('bye') || msg.contains('see you') || msg.contains('thanks')
                            ) {
                              // response from the dialogflow
                              DetectIntentResponse response = await dialogFlowtter.detectIntent(
                                  queryInput: QueryInput(text: TextInput(text: msg)));
                              if (response.message != null) {
                                addMsgToList([response.message!.text!.text![0], false]);
                              }
                            }
                            else {
                              // retrieving data from python api
                              var data = await getData(url);
                              var decodedData = jsonDecode(data);
                              Map<String, dynamic> link = decodedData;
                              List links = [];
                              link.forEach((key, value) => links.add(value));
                              String combined = "";
                              for (int i=0; i<links.length; i++) {
                                combined += links[i];
                                if (i < links.length - 1) {
                                  combined += "\n\n";
                                }
                              }

                              addMsgToList([combined, false]);

                              // adding user visited links to database
                              addUser(widget.email, links);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(70.0)
                              )
                            )
                          ),
                          child: const Icon(
                            Icons.send
                          ),
                        )
                      ]
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}


Future<void> _onOpen (LinkableElement link) async {
  List links = link.url.split("\n\n");
  for (int i=0; i<links.length; i++) {
    Uri u = Uri.parse(links[i]);
    // if (await canLaunchUrl(u)) {
      await launchUrl(u);
    // }
  }
}
