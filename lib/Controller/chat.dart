import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seventhapp/Models/message.dart';
import 'package:uuid/uuid.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'storage.dart';
import 'package:seventhapp/Auth/auth.dart';
import 'package:extension/extension.dart';
import 'package:mime/mime.dart';
import 'package:seventhapp/utils/extensions.dart';

@immutable
class Chat {
 final auth = FirebaseAuth.instance;
 final firestore = FirebaseFirestore.instance;

 Future<void> sendMessage({
  required String apiKey,
  required XFile? image,
  required String promptText,
  required String sessionId, // New parameter for session ID
 }) async {
  final textModel = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final imageModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final userId = auth.currentUser!.uid;
  final sentMessageId = const Uuid().v4();

  // Create the message
  Message message = Message(
   id: sentMessageId,
   message: promptText,
   createdAT: DateTime.now(),
   isMine: true,
  );

  // If there's an image, upload it and get the download URL
  if (image != null) {
   final downloadUrl = await Storage().saveImagetoStorage(
    image: image,
    messageId: sentMessageId,
   );
   message = message.copyWith(imageUrl: downloadUrl);
  }

  // Store the message in Firestore under the specified session
  await firestore
      .collection('conversations')
      .doc(userId)
      .collection('sessions')
      .doc(sessionId)
      .collection('messages')
      .doc(sentMessageId)
      .set(message.toMap());

  GenerateContentResponse response;
  try {
   if (image == null) {
    response = await textModel.generateContent([Content.text(promptText)]);
   } else {
    final imageBytes = await image.readAsBytes();
    final prompt = TextPart(promptText);
    final mimeType = image.getMimeTypeFromExtension();
    final imagePart = DataPart(mimeType, imageBytes);

    response = await imageModel.generateContent([
     Content.multi([prompt, imagePart])
    ]);
   }

   final responseText = response.text;
   final receiveMessageId = const Uuid().v4();
   final responseMessage = Message(
    id: receiveMessageId,
    message: responseText!,
    createdAT: DateTime.now(),
    isMine: false,
   );

   // Store the AI's response message in Firestore under the same session
   await firestore
       .collection('conversations')
       .doc(userId)
       .collection('sessions')
       .doc(sessionId)
       .collection('messages')
       .doc(receiveMessageId)
       .set(responseMessage.toMap());
  } catch (e) {
   throw Exception(e.toString());
  }
 }

 Future<void> sendonlyMessage({
  required String apiKey,
  required String promptText,
  required String sessionId, // New parameter for session ID
 }) async {
  final textModel = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final userId = auth.currentUser!.uid;
  final sentMessageId = const Uuid().v4();

  // Create the user's message
  Message message = Message(
   id: sentMessageId,
   message: promptText,
   createdAT: DateTime.now(),
   isMine: true,
  );

  // Store the user's message in Firestore under the specified session
  await firestore
      .collection('conversations')
      .doc(userId)
      .collection('sessions')
      .doc(sessionId)
      .collection('messages')
      .doc(sentMessageId)
      .set(message.toMap());

  try {
   // Generate response using the text model
   final response = await textModel.generateContent([Content.text(promptText)]);
   final responseText = response.text;
   final receiveMessageId = const Uuid().v4();

   // Create and store the AI's response message in Firestore under the same session
   final responseMessage = Message(
    id: receiveMessageId,
    message: responseText!,
    createdAT: DateTime.now(),
    isMine: false,
   );

   await firestore
       .collection('conversations')
       .doc(userId)
       .collection('sessions')
       .doc(sessionId)
       .collection('messages')
       .doc(receiveMessageId)
       .set(responseMessage.toMap());
  } catch (e) {
   throw Exception(e.toString());
  }
 }
}
