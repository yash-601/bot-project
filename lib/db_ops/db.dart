
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';


class Database {

  final String uid;
  Database({ required this.uid });

  dynamic db = FirebaseFirestore.instance;

  Future addUser(Map<String, dynamic> data) async {
    final user = data;
    db
        .collection("users")
        .doc(uid)
        .set(user);
  }

  Future updateUser(Map<String, dynamic> data) async {
    final user = data;
    db
        .collection("users")
        .doc(uid)
        .update(user);
  }

}

