import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';


class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          centerTitle: true,
          leading: BackButton(
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        resizeToAvoidBottomInset : false,
        body: const Page(),
    ));
  }
}

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  bool emailValidator = false;
  bool passValidator = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 50.0, 40.0, 170.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                labelText: 'Email',
                errorText: emailValidator ?'Value can\'t be empty!' : null,
              ),
            ),
            const SizedBox(height: 15.0),
            TextField(
              controller: _pass,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                labelText: 'password',
                errorText: passValidator ? 'Value can\'t be empty!' : null,
              ),
            ),
            const SizedBox(height: 60.0),
            SizedBox(
              height: 45.0,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _email.text.isEmpty ? emailValidator = true : emailValidator = false;
                    _pass.text.isEmpty ? passValidator = true : passValidator = false;
                  });
                  try {
                    UserCredential userCreds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _email.text,
                      password: _pass.text,
                    );
                  } on FirebaseAuthException catch(e) {
                    if (e.code == 'weak-password') {
                      const snackBar = SnackBar(
                        content: Text('The password provided is weak!!'),
                        duration: Duration(seconds: 1),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else if (e.code == 'email-already-in-use') {
                      const snackBar = SnackBar(
                        content: Text('This email is already in use'),
                        duration: Duration(seconds: 1),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                  if (_email.text.isNotEmpty) {
                    _email.text = "";
                    _pass.text = "";
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home())
                    );
                  }
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        )
                    )),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
