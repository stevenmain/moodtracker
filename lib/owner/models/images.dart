import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class Images {
  final String id;
  String fileName;
  String fileUrl;
  File? image;

  Images(
      {required this.id,
      required this.fileName,
      this.image,
      this.fileUrl = ''});
}

class ImagesProvider with ChangeNotifier {
  List<Images> _images = [];

  List<Images> get images {
    return [..._images];
  }

  Random random = new Random();
  Future<void> addImagesData(var fileName, File? image) async {
    try {
      final List<Images> imagesData = [];

      _images.add(
        Images(
            id: (_images.length + random.nextInt(100)).toString(),
            fileName: fileName,
            image: image),
      );
      // _images = imagesData;

      print(_images.length);
      notifyListeners();
    } catch (error) {
      print(error);
      // throw error;
    }
  }

  // edit function
  Future<void> addImagesDataEdit(var fileName, String fileUrl) async {
    try {
      final List<Images> imagesData = [];

      _images.add(
        Images(
            id: (_images.length + random.nextInt(100)).toString(),
            fileName: fileName,
            fileUrl: fileUrl),
      );
      // _images = imagesData;

      print(_images.length);
      notifyListeners();
    } catch (error) {
      print(error);
      // throw error;
    }
  }

   void resetImageMap() {
    _images = [];
    // notifyListeners();
  }

  void deleteImage(String id) {
    _images.removeWhere((tx) {
      return tx.id == id;
    });
    notifyListeners();
  }
}
