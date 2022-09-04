import 'package:flutter/material.dart';
import '../../widgets/drawer.dart';
import '../property/property_upload_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../property/propertyDetails_screen.dart';
import 'package:provider/provider.dart';
import '../../models/images.dart';
import '../../widgets/property/propertyList.dart';

class PropertyScreen extends StatefulWidget {
  PropertyScreen({Key? key}) : super(key: key);
  static const routeName = '/propertyScreen';

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  var _me;
  void initState() {
    _me = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Property')),
      drawer: MainDrawer(),
      body: 
      Container(
        color: Theme.of(context).backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           PropertyList(_me, 'all'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(PropertyUploadScreen.routeName);
        },
        backgroundColor: Theme.of(context).accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
