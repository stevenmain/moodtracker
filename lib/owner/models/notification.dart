import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

// class Images {
//   final String id;
//   String fileName;
//   String fileUrl;
//   File? image;

//   Images(
//       {required this.id,
//       required this.fileName,
//       this.image,
//       this.fileUrl = ''});
// }

class NotificationProvider with ChangeNotifier {
  var firebaseUser;

  Future<void> addSubcribeAgentNotification(
      senderID, receiverID, action, pid, type, message, image) async {
    FirebaseFirestore.instance.collection("notification").add({
      "receiverId": receiverID,
      "senderId": senderID,
      "pid": pid,
      'type': type,
      'action': action,
      'message': message,
      'image': image,
      "createdTime": DateTime.now().toString(),
    });
  }

  Future<void> getUserNotification(uid) async {
    firebaseUser = FirebaseFirestore.instance
        .collection('notification')
        // .where('receiverId', isEqualTo: uid)
        .where('receiverId', isEqualTo: uid)
        .orderBy('createdTime', descending: true)
        //  .where('senderId', isEqualTo: uid)
        .snapshots();
  }
}
