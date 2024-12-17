import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seventhapp/Models/message.dart';
import 'package:seventhapp/widgets/Messagetile.dart';

class Messagesview extends StatelessWidget {
  final String userId;
  final String sessionId;

  Messagesview({required this.userId, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    // Debugging: Print the sessionId to verify it's correct
    print('Session ID: $sessionId');

    // Check if sessionId is empty or null
    if (sessionId.isEmpty) {
      return const Center(child: Text('Invalid session ID'));
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(userId)
          .collection('sessions')
          .doc(sessionId)  // Using sessionId
          .collection('messages')
          .orderBy('createdAT', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // No data or empty collection state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found'));
        }

        // Data exists
        List<QueryDocumentSnapshot> doc = snapshot.data!.docs;
        print('Number of messages: ${doc.length}');  // Debug print

        return ListView.builder(
          reverse: true, // Reverses the list to show the newest message at the bottom
          itemCount: doc.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> data = doc[index].data() as Map<String, dynamic>;
            print(data);  // Debug print to show message data

            // Create Message object from Firestore data
            Message message = Message.fromMap(data);

            return MessageTile(
              message: message,
              isOutgoing: message.isMine,
            );
          },
        );
      },
    );
  }
}
