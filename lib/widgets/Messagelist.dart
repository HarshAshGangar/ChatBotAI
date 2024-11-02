import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seventhapp/Models/message.dart';
import 'package:seventhapp/providers/getmessageprovider.dart';
import 'Messagetile.dart';

class Messagesview extends StatelessWidget {
  final String userId;
  final String sessionId;
  Messagesview({required this.userId, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    print('build called');
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(userId)
          .collection('sessions')
          .doc(sessionId)
          .collection('messages')
          .orderBy('createdAT',descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found'));
        }

        List<QueryDocumentSnapshot> doc = snapshot.data!.docs;
        print('Number of messages: ${doc.length}');

        return ListView.builder(
          reverse: true, // This reverses the order to show the newest message at the bottom
          itemCount: doc.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> data = doc[index].data() as Map<String, dynamic>;
            print(data);
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
