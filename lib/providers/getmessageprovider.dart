// Importing necessary Dart library for asynchronous programming
import 'dart:async';
// Importing the async package, which includes tools for asynchronous operations
import 'package:async/async.dart';
// Importing a custom Message model from the Models folder
import 'package:seventhapp/Models/message.dart';
// Importing Riverpod's provider package for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importing Firebase Firestore package to interact with the Firestore database
import 'package:cloud_firestore/cloud_firestore.dart';

// Declaring a provider that streams an iterable of Message objects for a specific user and session
final getmessageProvider = StreamProvider.autoDispose.family<Iterable<Message>, Map<String, String>>(
  // The provider takes a map containing userId and sessionId as parameters
        (ref, ids) {
      final userId = ids['userId']!;
      final sessionId = ids['sessionId']!;

      // Creating a StreamController to manage the stream of Message objects
      final controller = StreamController<Iterable<Message>>();

      // Setting up a Firestore listener that retrieves messages for the specified user and session
      final sub = FirebaseFirestore.instance
          .collection('conversations') // Accessing the 'conversations' collection
          .doc(userId)
          .collection('sessions')
          .doc(sessionId) // Specifying the session based on sessionId
          .collection('messages') // Accessing the 'messages' sub-collection
          .orderBy('createdAT', descending: true) // Ordering messages by 'createdAT' in descending order
          .snapshots() // Subscribing to real-time updates from Firestore
          .listen((snapshot) {
        // Mapping each document in the snapshot to a Message object
        final messages = snapshot.docs.map((messageData) =>
            Message.fromMap(messageData.data() as Map<String, dynamic>)
        );
        // Adding the list of Message objects to the stream
        controller.sink.add(messages);
      });

      // Ensuring resources are properly disposed when the provider is no longer needed
      ref.onDispose(() {
        sub.cancel(); // Cancelling the Firestore subscription
        controller.close(); // Closing the StreamController
      });

      // Returning the stream managed by the controller to the provider
      return controller.stream;
    }
);
