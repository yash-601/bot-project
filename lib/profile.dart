import 'package:bot/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'db_ops/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class Profile extends StatefulWidget {
  final String id;
  const Profile({Key? key, required this.id}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  
  late XFile? image = null;
  String? path = '';
  bool changedProfile = false;
  String displayName = '';
  String displayEmail = '';
  final ImagePicker picker = ImagePicker();


  void addImage(XFile? img) async {
    String imageUrl = '';
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    // upload to firebase storage
    // get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceImages = referenceRoot.child('Images');

    // create a reference for the image to be stored
    Reference referenceImageToUpload = referenceImages.child(uniqueFileName);

    // Error handling
    try {
      await referenceImageToUpload.putFile(File(img!.path));
      // successfully uploaded image to storage ; get the download url for image
      imageUrl = await referenceImageToUpload.getDownloadURL();
      Database db = Database(uid: widget.id);
      db.updateUser({'profile_photo': imageUrl});

      setState(() {
        path = imageUrl;
      });
    } catch(error) {}
  }

  void openGallery() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        path = image!.path;
      });
    }
    addImage(image);
  }

  void openCamera() async {
   image = await picker.pickImage(source: ImageSource.camera);
   if (image != null) {
     setState(() {
       path = image!.path;
     });
   }
   addImage(image);
  }


  void pickImage() async {
    showModalBottomSheet(context: context, builder: (context) {
      return Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: openGallery,
                  child: const Text(
                      'Open Gallery',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  )
              ),
              ElevatedButton(
                  onPressed: openCamera,
                  child: const Text(
                      'Open Camera',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  )
              ),
              const SizedBox(height: 50),
            ],
        )
        ],
      );
    });
  }

  void editProfile() async {
    TextEditingController _name = TextEditingController();
    TextEditingController _mail = TextEditingController();

    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          children: [
            TextField(
              controller: _name,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                  labelText: 'name',
                )
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _mail,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                  labelText: 'mail',
                )
            ),
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                },
                  child: const Center(
                    child: Text('cancel')
                  ),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () async {
                    Database db = Database(uid: widget.id);
                    await db.updateUser({'name': _name.text, 'mail': _mail.text});
                    setState(() {
                      displayName = _name.text;
                      displayEmail = _mail.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Text("change"),
                  ),
                ),
              ],
            ),
          ]
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.id).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
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
                              child: Text('Settings')
                          ),
                          const PopupMenuItem<int>(
                              value : 1,
                              child: Text('Preferences')
                          ),
                        ];
                      },
                      onSelected: (value) async {
                        if (value == 0) {
                          editProfile();
                        }
                        else if (value == 1) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Preferences()));
                        }
                      }
                  )
                ],
              ),
              resizeToAvoidBottomInset : true,
              body: Container(
                color: Colors.blueGrey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 70.0, 10.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 65.0,
                            backgroundImage: data['profile_photo'].toString().isNotEmpty ? Image.network(data['profile_photo']).image : Image.file(File(path!)).image
                          ),
                        ),
                      ),
                      Divider(height: 120, color: Colors.grey[900], thickness: 3, indent: 20.0, endIndent: 20.0),
                      Row(
                          children:[
                            const SizedBox(width: 20.0),
                            const Text(
                              'username : ',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              displayName.isNotEmpty? displayName: data['name'],
                              style: const TextStyle(
                                fontSize: 23.0,
                                color: Colors.amber,
                              ),
                            )
                          ]
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                          children:[
                            const SizedBox(width: 20.0),
                            const Text(
                              'email : ',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              displayEmail.isNotEmpty? displayEmail: data['mail'],
                              style: const TextStyle(
                                fontSize: 23.0,
                                color: Colors.amber,
                              ),
                            )
                          ]
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const CupertinoActivityIndicator();
      },
    );
  }
}

