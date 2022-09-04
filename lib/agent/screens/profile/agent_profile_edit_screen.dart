import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/images.dart';
import 'package:provider/provider.dart';
import '../../../owner/models/dummyData.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.id});
  final String id;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  var _usernameController = TextEditingController();
  var _companyController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  var username = '';
  var phone = '';
  var companyName = '';
  var state = '';
  var description = '';
  var url =
      'https://www.ateneo.edu/sites/default/files/styles/large/public/2021-11/istockphoto-517998264-612x612.jpeg?itok=aMC1MRHJ';
  bool expendCategory = false;
  String? _myState = null;
  var _isLoading = false;
  File? image;
  Random random = new Random();
  List<dynamic>? selectedHobby = [];
  List<dynamic>? selectedAdType = [];
  List<dynamic>? selectedCategory = [];

  void initState() {
    // _me = FirebaseAuth.instance.currentUser;
    getOwnerData(widget.id);
    super.initState();
  }

  Future<void> getOwnerData(id) async {
    FirebaseFirestore.instance
        .collection("agent")
        .doc(id)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        url = querySnapshot['image'];
          selectedHobby = querySnapshot['focusArea'];
        selectedAdType = querySnapshot['adType'];
        selectedCategory = querySnapshot['propertyCategories'];
        _myState = querySnapshot['state'];
        _usernameController =
            TextEditingController(text: querySnapshot['username'].toString());
        _companyController = TextEditingController(
            text: querySnapshot['companyName'].toString());

        _descriptionController = TextEditingController(
            text: querySnapshot['description'].toString());
        _phoneController =
            TextEditingController(text: querySnapshot['phone'].toString());
      });
    });
  }

  Widget expandList(
      title1, List<String> listData, valueData1, expand, DummyData) {
    return Container(
        padding: EdgeInsets.all(2),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          left: 0, top: 0, right: 20, bottom: 5),
                      child: FittedBox(
                        child: Text(
                          title1,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ]),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  padding: EdgeInsets.all(0),
                  child: IconButton(
                    icon: Icon(Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        expendCategory = !expendCategory;
                      });
                    },
                  ),
                ),
              ]),
            ],
          ),
          if (expand)
            Container(
              height: min(1 * 60.0 + 10, 300),
              child: title1 != 'State'
                  ? Container()
                  : Card(
                      elevation: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          dropDownItemList(title1, listData, valueData1),
                        ],
                      ),
                    ),
            )
        ]));
  }

  Widget dropDownItemList(title, List<String> listData, valueData) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 5),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                    value: valueData,
                    iconSize: 30,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    hint: Text(title),
                    onChanged: (value) {
                      setState(() {
                        if (title == 'State') {
                          _myState = value.toString();
                        }
                      });
                    },
                    // items: DummyData.state.map((stateData) {
                    items: listData.map((data) {
                      return new DropdownMenuItem(
                        // ignore: sort_child_properties_last
                        child: Text(data),
                        value: data.toString(),
                      );
                    }).toList()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    print(" tesing");
    try {
      if (image != null) {
        print(" tesing2.2");
        String fileName = 'Agent' +
            (random.nextInt(100) * random.nextInt(1000) + 1).toString();
        final ref = FirebaseStorage.instance
            .ref()
            .child('Agent_images')
            .child(fileName.toString());
        await ref.putFile(image!);
        url = await ref.getDownloadURL();
      } else {}
      print(" tesing3");
      var firebaseUser = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance
          .collection("agent")
          .doc(firebaseUser!.uid)
          .update({
        'username': username,
        'companyName': companyName,
        'state': _myState,
        'phone': phone,
        'image': url,
        'description': description,
        'focusArea': selectedHobby,
        'adType': selectedAdType,
        'propertyCategories': selectedCategory

        // 'timestamp': DateTime.now().toString(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successful'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      const errorMessage = 'Could not authenticate you. Please try again later';
      print(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future _pickImage() async {
    final pickImageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImageFile == null) return;
    final imageTemporary = File(pickImageFile.path);
    String fileName = imageTemporary.path.split('/').last;

    setState(() {
      image = imageTemporary;
    });
  }

  Widget changeImageCallType() {
    if (image != null) {
      return CircleAvatar(
        backgroundImage: FileImage(image!),
        radius: 60.0,
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(url),
        radius: 60.0,
      );
    }
  }

  Widget multiSelection(data, isSelected, selectedData) {
    return GestureDetector(
      onTap: () {
        if (!selectedData!.contains(data)) {
          if (selectedData!.length < 17) {
            selectedData!.add(data);
            setState(() {});
            print(selectedData);
          }
        } else {
          selectedData!.removeWhere((value) => value == data);
          setState(() {});
          print(selectedData);
        }
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey, width: 2)),
            child: Text(
              data,
              style: TextStyle(
                  color: isSelected ? Colors.red : Colors.grey, fontSize: 14),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final pdata = Provider.of<ImagesProvider>(context, listen: false);
    final DummyData = Provider.of<dummyDataProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
              onPressed: () {
                _submit();
              },
              icon: Icon(Icons.save_as))
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
             color: Theme.of(context).backgroundColor,
            width: double.infinity,
            // height: deviceSize.height * 1.4,
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Column(
                      children: [
                        changeImageCallType(),
                        FlatButton.icon(
                          textColor: Colors.black,
                          onPressed: _pickImage,
                          icon: Icon(Icons.image),
                          label: Text('Image'),
                        ),
                      ],
                    )),
                    TextFormField(
                      // initialValue: _myTitle.toString(),
                      decoration: InputDecoration(labelText: 'Username'),
                      controller: _usernameController,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters';
                        } else if (value.length > 20) {
                          return 'Username cannot length no more than 20 character';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        username = value.toString();
                      },
                    ),
                    TextFormField(
                      // initialValue: _myTitle.toString(),
                      decoration: InputDecoration(labelText: 'Company Name'),
                      controller: _companyController,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        companyName = value.toString();
                      },
                    ),
                    TextFormField(
                      // initialValue: _myPrice.toString(),
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      controller: _phoneController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Price cannot be empty!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        phone = value.toString();
                      },
                    ),
                    expandList('State', DummyData.state, _myState,
                        expendCategory, DummyData),
                    Divider(
                      color: Colors.black,
                    ),
                    TextFormField(
                      // initialValue: _myDescription,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 7,
                      keyboardType: TextInputType.multiline,
                      controller: _descriptionController,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 3) {
                          return 'Description cannot be empty!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        description = value.toString();
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Ad Type'),
                    SizedBox(
                      height: 5,
                    ),
                    Wrap(
                      children: DummyData.adType.map(
                        (adType) {
                          bool isSelected = false;
                          if (selectedAdType!.contains(adType)) {
                            isSelected = true;
                          }
                          return multiSelection(
                              adType, isSelected, selectedAdType);
                        },
                      ).toList(),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Text('Category'),
                    SizedBox(
                      height: 5,
                    ),
                    Wrap(
                      children: DummyData.propertyCategory.map(
                        (category) {
                          bool isSelected = false;
                          if (selectedCategory!.contains(category)) {
                            isSelected = true;
                          }
                          return multiSelection(
                              category, isSelected, selectedCategory);
                        },
                      ).toList(),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Text('Focus Area'),
                    SizedBox(
                      height: 5,
                    ),
                    Wrap(
                      children: DummyData.state.map(
                        (hobby) {
                          bool isSelected = false;
                          if (selectedHobby!.contains(hobby)) {
                            isSelected = true;
                          }
                          return multiSelection(
                              hobby, isSelected, selectedHobby);
                        },
                      ).toList(),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
