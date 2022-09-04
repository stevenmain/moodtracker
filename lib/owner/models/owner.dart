import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Owners {
  final String id;
  String username;
  String email;
  String phoneNumber;
  String state;
  String image;
  String description;

  Owners(
      {required this.id,
      required this.username,
      required this.email,
      required this.phoneNumber,
      required this.state,
      required this.image,
      required this.description});

  void getOwnerDetails(uid) {}
}

class OwnersProvider with ChangeNotifier {
  List<Owners> _ownerList = [
    Owners(
        id: 'sdssdsd',
        username: '',
        email: '',
        phoneNumber: '',
        state: '',
        image: 'https://www.ateneo.edu/sites/default/files/styles/large/public/2021-11/istockphoto-517998264-612x612.jpeg?itok=aMC1MRHJ',
        description: ''),
  ];

  List<Owners> get ownerList {
    return [..._ownerList];
  }

  Future<void> addOwnerDataEdit(
      id, username, email, phoneNumber, state, image, description) async {
    try {
      List<Owners> imagesData = [];

      imagesData.add(
        Owners(
            id: id,
            username: username,
            email: email,
            phoneNumber: phoneNumber,
            state: state,
            image: image,
            description: description),
      );
      _ownerList = imagesData;
      print(_ownerList.toString() + 'shshh');
      notifyListeners();
    } catch (error) {
      print(error);
      // throw error;
    }
  }

  Future<void> getOwnerDetails(uid) async {
    List<Owners> tempOwnerList = [];
    print(uid);
    FirebaseFirestore.instance
        .collection("owner")
        .doc(uid)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.exists != false) {
        tempOwnerList.add(
          Owners(
              id: querySnapshot.id,
              username: querySnapshot['username'],
              email: querySnapshot['email'],
              phoneNumber: querySnapshot['phone'],
              state: querySnapshot['state'],
              image: querySnapshot['image'],
              description: querySnapshot['description']),
        );
        _ownerList = tempOwnerList;
        notifyListeners();
      }
    });
  }
}
