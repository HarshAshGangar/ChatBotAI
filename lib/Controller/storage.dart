import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

@immutable
class Storage {
  final _storage = FirebaseStorage.instance;

  Future<String> saveImagetoStorage({
    required XFile image,
    required String messageId,
  }) async {
    try {
      Reference ref = _storage.ref('images').child(messageId);
      TaskSnapshot snapshot = await ref.putFile(File(image.path));
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
