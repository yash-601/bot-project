import 'package:bot/templates/custombutton.dart';
import 'package:flutter/material.dart';


class Item {
  String expandedValue;
  String headerValue;
  bool isExpanded;

  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false
  });
}

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {

  List<Item> questions = [Item(expandedValue: 'Which websites do you usually prefer?', headerValue: 'First'),
    Item(expandedValue: 'What products do you buy?', headerValue: 'second')];

  void addPreferenceHelper (String title) {}



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Preferences'),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          leading: BackButton(
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            child: _buildPanel(),
          ),
        )
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          questions[index].isExpanded = !isExpanded;
        });
      },
      children: questions.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded){
              return ListTile(
                title: Text(item.headerValue),
              );
            },
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
                  child: Row(
                    children: [
                      CustomButton(title: 'Amazon', action: (){ addPreferenceHelper('Amazon');})
                    ],
                  ),
                ),
              ]
            ),
            isExpanded: item.isExpanded
        );
      }).toList(),
    );
  }
}
