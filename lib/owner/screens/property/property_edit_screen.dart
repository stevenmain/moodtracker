import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../agent/models/agent.dart';
import '../../../agent/models/property.dart';
import '../../models/images.dart';
import 'package:provider/provider.dart';
import '../../models/dummyData.dart';
import '../../models/notification.dart';

class PropertyEditScreen extends StatefulWidget {
  const PropertyEditScreen({super.key, required this.id});
  final String id;
  static const routeName = '/editPropertyScreen';
  @override
  State<PropertyEditScreen> createState() => _PropertyEditScreenState();
}

class _PropertyEditScreenState extends State<PropertyEditScreen> {
  var _me;
  var _titleController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _priceController = TextEditingController();
  var _imageUrlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  var title = '';
  var price = 0.00;
  var size = '';
  var description = '';
  bool expendLocation = false;
  bool expendCategory = false;
  bool expendDetails = false;

  void initState() {
    // print(widget.id.toString()+'aaaaaaaaaaaaaaaaaaa');
    var id = widget.id;
    _me = FirebaseAuth.instance.currentUser;
    Provider.of<AgentsProvider>(context, listen: false)
        .getFollowedAgentListByProperty(id);
    getOwnerData(widget.id);
    Future.delayed(Duration(milliseconds: 50), () {
      Provider.of<PropertyProvider>(context, listen: false)
          .getPropertyDetails(_me.uid, widget.id);
    });
    super.initState();
  }

  var _isLoading = false;
  File? image;
  Random random = new Random();

  double _myPrice = 0.00;
  String _myTitle = 'www';
  String _mySize = 'www';
  String _myDescription = 'www';
  List<Images> _submitData = [];
  Map<String, dynamic> imagesUrl = {};
  List<String> statesList = [];
  // ignore: avoid_init_to_null
  String? _myState = null;
  // ignore: avoid_init_to_null
  String? _myArea = null;
  String? _myCategory = null;
  String? _myTitleType = null;
  String? _myPropertytype = null;
  String? _myBedroom = null;
  String? _myBathroom = null;
  String? _myOtherInfo = null;
  String? _myAdType = null;

  Future _pickImage() async {
    final pickImageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImageFile == null) return;
    final imageTemporary = File(pickImageFile.path);
    String fileName = imageTemporary.path.split('/').last;

    setState(() {
      final PData = Provider.of<ImagesProvider>(context, listen: false);
      image = imageTemporary;
      PData.addImagesData(fileName, image);
      // print(PData.images.length.toString());
    });
  }

  Future<void> getOwnerData(id) async {
    FirebaseFirestore.instance
        .collection("property")
        .doc(id)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        imagesUrl = querySnapshot['image'] as Map<String, dynamic>;
        // print(imagesUrl);
        // statesList = [];
        _myState = querySnapshot['state'];
        _myArea = querySnapshot['area'];
        _myCategory = querySnapshot['category'];
        _myTitleType = querySnapshot['title Type'];
        _myPropertytype = querySnapshot['property Type'];
        _myBedroom = querySnapshot['bedrooms'];
        _myBathroom = querySnapshot['bathroom'];
        _myOtherInfo = querySnapshot['other info'];
        _myAdType = querySnapshot['ad type'];
        _titleController =
            TextEditingController(text: querySnapshot['title'].toString());
        _descriptionController = TextEditingController(
            text: querySnapshot['description'].toString());
        _priceController =
            TextEditingController(text: querySnapshot['price'].toString());
        _imageUrlController =
            TextEditingController(text: querySnapshot['size'].toString());

        final PData = Provider.of<ImagesProvider>(context, listen: false);
        PData.resetImageMap();
        imagesUrl.forEach((key, value) {
          PData.addImagesDataEdit(key, value);
          // PData.addImagesData(fileName, image);
          // print(PData.images.length.toString());
          // print(PData.images[0].image.toString());
        });
      });
    });
  }

  Future<void> _submit(RecommendData, peopertyDetails) async {
    final PData = Provider.of<ImagesProvider>(context, listen: false);
    final NotiData = Provider.of<NotificationProvider>(context, listen: false);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    // print(" tesing");
    try {
      for (int i = 0; i < PData.images.length; i++) {
        // print(PData.images[i].image.toString());
        if (PData.images[i].image != null) {
          // print(" tesing2.2");
          String fileName = 'property' +
              (random.nextInt(100) * random.nextInt(1000) + 1).toString();
          final ref = FirebaseStorage.instance
              .ref()
              .child('property_images')
              .child(fileName.toString());
          await ref.putFile(PData.images[i].image!);
          final url = await ref.getDownloadURL();
          String imagesCount = i.toString();
          // imagesUrl = {imagesCount : title};
          imagesUrl[imagesCount] = url.toString();
          PData.images[i].fileUrl = url;
        } else {
          String imagesCount = i.toString();
          imagesUrl[imagesCount] = PData.images[i].fileUrl.toString();
          // PData.images[i].fileUrl = url;
        }
      }
      // print(" tesing3");
      var firebaseUser = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance.collection("property").doc(widget.id).update({
        'title': title,
        'price': price,
        'size': size,
        'ad type': _myAdType,
        'image': imagesUrl,
        'description': description,
        'state': _myState,
        'area': _myArea,
        'category': _myCategory,
        'property Type': _myPropertytype,
        'title Type': _myTitleType,
        'bedrooms': _myBedroom,
        'bathroom': _myBathroom,
        'other info': _myOtherInfo,
        // 'timestamp': DateTime.now().toString(),
      });

      RecommendData.followedAgentData.forEach((element) {
        NotiData.addSubcribeAgentNotification(
            _me.uid,
            element.id,
            'Property Updates',
            widget.id,
            'property',
            'Owner has modified the property details!',
            peopertyDetails[0].image);
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

  Widget selectImageLimitation(pdata) {
    if (pdata.images.length >= 6) {
      return FlatButton.icon(
        textColor: Colors.black,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Max 6 images!'),
              duration: Duration(seconds: 3),
            ),
          );
        },
        icon: Icon(Icons.image),
        label: Text('Image (' + pdata.images.length.toString() + '/6)'),
      );
    } else {
      return FlatButton.icon(
        textColor: Colors.black,
        onPressed: _pickImage,
        icon: Icon(Icons.image),
        label: Text('Image (' + pdata.images.length.toString() + '/6)'),
      );
    }
  }

  Widget changeImageCallType(fileUrl, image) {
    if (fileUrl == '') {
      return Image.file(
        image!,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        fileUrl!,
        fit: BoxFit.cover,
      );
    }
  }

  Widget imagesShow(ctx, deviceSize) {
    final PData = Provider.of<ImagesProvider>(ctx, listen: false);
    if (PData.images == null) {
      return SizedBox();
    } else {
      return Container(
          child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        width: double.infinity,
        child: ListView(
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: PData.images.map((tx) {
            return Container(
              width: deviceSize.width * 0.3,
              height: deviceSize.height * 0.1,
              padding: const EdgeInsets.all(5),
              child: InkWell(
                  child: changeImageCallType(tx.fileUrl, tx.image),
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text("Warning"),
                        content: Text('Are you sure want to delete?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                PData.deleteImage(tx.id);
                              });

                              Navigator.pop(context, 'OK');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }),
            );
          }).toList(),
        ),
      ));
    }
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
                          _myArea = null;
                        }
                        if (title == 'Property Category') {
                          _myCategory = value.toString();
                          _myPropertytype = null;
                        }
                        if (title == 'Title Type') {
                          _myTitleType = value.toString();
                        }
                        if (title == 'Bedrooms') {
                          _myBedroom = value.toString();
                        }
                        if (title == 'Bathroom') {
                          _myBathroom = value.toString();
                        }
                        if (title == 'Other Info') {
                          _myOtherInfo = value.toString();
                        }
                        if (title == 'Ad type') {
                          _myAdType = value.toString();
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

  Widget dropDownItemMap(title, Map<String, List> mapData, valueData) {
    if (_myState != null && title == 'Area') {
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
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                      hint: Text(title),
                      onChanged: (value) {
                        setState(() {
                          if (title == 'Area') {
                            _myArea = value.toString();
                          }
                        });
                      },
                      items: mapData[_myState]?.toList().map((stateData) {
                        return new DropdownMenuItem(
                          child: new Text(stateData.toString()),
                          value: stateData.toString(),
                        );
                      }).toList()),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_myCategory != null && title == 'Property Type') {
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
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                      hint: Text(title),
                      onChanged: (value) {
                        setState(() {
                          if (title == 'Property Type') {
                            _myPropertytype = value.toString();
                          }
                        });
                      },
                      items: mapData[_myCategory]?.toList().map((stateData) {
                        return new DropdownMenuItem(
                          child: new Text(stateData.toString()),
                          value: stateData.toString(),
                        );
                      }).toList()),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget expandList(
      title1,
      title2,
      List<String> listData,
      Map<String, List> mapData,
      valueData1,
      valueData2,
      String mainTitle,
      expand) {
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
                          mainTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            // color: Colors.red,
                            // fontWeight: FontWeight.bold
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
                        if (mainTitle == 'Location') {
                          expendLocation = !expendLocation;
                        } else {
                          expendCategory = !expendCategory;
                        }
                      });
                    },
                  ),
                ),
              ]),
            ],
          ),
          if (expand)
            Container(
              height: min(2 * 60.0 + 10, 300),
              child: Card(
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dropDownItemList(title1, listData, valueData1),
                    dropDownItemMap(title2, mapData, valueData2),
                  ],
                ),
              ),
            )
        ]));
  }

  Widget expandListDetails(
      title1,
      title2,
      title3,
      title4,
      title5,
      List<String> listData1,
      List<String> listData2,
      List<String> listData3,
      List<String> listData4,
      List<String> listData5,
      valueData1,
      valueData2,
      valueData3,
      valueData4,
      valueData5,
      String mainTitle,
      expand) {
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
                          mainTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            // color: Colors.red,
                            // fontWeight: FontWeight.bold
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
                        expendDetails = !expendDetails;
                      });
                    },
                  ),
                ),
              ]),
            ],
          ),
          if (expand)
            Container(
              height: min(5 * 60.0 + 10, 300),
              child: Card(
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dropDownItemList(title5, listData5, valueData5),
                    dropDownItemList(title1, listData1, valueData1),
                    dropDownItemList(title2, listData2, valueData2),
                    dropDownItemList(title3, listData3, valueData3),
                    dropDownItemList(title4, listData4, valueData4),
                  ],
                ),
              ),
            )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final pdata = Provider.of<ImagesProvider>(context, listen: false);
    final DummyData = Provider.of<dummyDataProvider>(context, listen: false);
    final RecommendData = Provider.of<AgentsProvider>(context);
    final peopertyDetails =
        Provider.of<PropertyProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Property'),
        actions: [
          IconButton(
              onPressed: () {
                _submit(RecommendData, peopertyDetails.propertyList);
              },
              icon: Icon(Icons.save_as))
        ],
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: ListView(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: deviceSize.height * 0.9,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        // initialValue: _myTitle.toString(),
                        decoration: InputDecoration(labelText: 'Title'),
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 5) {
                            return 'Title cannot be empty!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          title = value.toString();
                        },
                      ),
                      TextFormField(
                        // initialValue: _myPrice.toString(),
                        decoration: InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        controller: _priceController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Price cannot be empty!';
                          }

                          if (double.tryParse(value) == null) {
                            return 'Invalid price input!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          price = double.parse(value.toString());
                        },
                      ),
                      TextFormField(
                        // initialValue: _mySize,
                        decoration: InputDecoration(labelText: 'Size (sq.ft.)'),
                        keyboardType: TextInputType.number,
                        controller: _imageUrlController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Size cannot be empty!';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid size input!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          size = value.toString();
                        },
                      ),
                      TextFormField(
                        // initialValue: _myDescription,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 6,
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
                      expandList(
                          'State',
                          'Area',
                          DummyData.state,
                          DummyData.area,
                          _myState,
                          _myArea,
                          'Location',
                          expendLocation),
                      expandList(
                          'Property Category',
                          'Property Type',
                          DummyData.propertyCategory,
                          DummyData.propertyType,
                          _myCategory,
                          _myPropertytype,
                          'Category',
                          expendCategory),
                      expandListDetails(
                          'Title Type',
                          'Bedrooms',
                          'Bathroom',
                          'Other Info',
                          'Ad type',
                          DummyData.titleType,
                          DummyData.bedrooms,
                          DummyData.bathroom,
                          DummyData.otherInfo,
                          DummyData.adType,
                          _myTitleType,
                          _myBedroom,
                          _myBathroom,
                          _myOtherInfo,
                          _myAdType,
                          'Details',
                          expendDetails),
                      const SizedBox(
                        height: 15,
                      ),
                      selectImageLimitation(pdata),
                      imagesShow(context, deviceSize),
                      // ElevatedButton(
                      //   child: Text('Submit'),
                      //   onPressed: () {
                      //     _submit();
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
