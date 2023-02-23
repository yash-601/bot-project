import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List messages = [];
  final TextEditingController _input = TextEditingController();


  void addMsgToList(String message) {
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
              onSelected: (value) {
                if (value == 2) {
                  Navigator.pop(context);
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
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 8.0, 0.0),
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(60.0, 0.0, 5.0, 0.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15.0, 10.0, 8.0, 10.0),
                              child: Text(
                                '${messages[index]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0
                                ),
                              ),
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
                                fontSize: 20.0,
                                color: Colors.white
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            String msg = _input.text;
                            setState(() {
                              _input.text = "";
                            });
                            addMsgToList(msg);
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
