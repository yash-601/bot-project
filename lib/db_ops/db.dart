

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

DatabaseReference ref = FirebaseDatabase.instance.ref("user_profile");

String getId () {
  String id = "";
  FirebaseFirestore.instance.collection("myCollection").doc("myDoc").get().then((docSnapshot) {
    if (docSnapshot.exists) {
      id = docSnapshot.id;
    }
  });
  return id;
}

void addUser(String email, List links) async{
  String id = getId();
  await ref.set({
    "$id/email": "mail@ml.com",
    "$id/links_visited" : links
  });
}

