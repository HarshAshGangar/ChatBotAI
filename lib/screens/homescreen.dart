import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seventhapp/providers/providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:seventhapp/screens/AboutUs.dart';
import 'package:seventhapp/screens/Disclaimer.dart';
import 'package:seventhapp/screens/sendimagescreen.dart';
import 'package:seventhapp/widgets/Messagelist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  late final TextEditingController _messageController;
  final apiKey = dotenv.env['API_KEY'] ?? '';
  String sessionId = '';
  late final String userId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    userId = FirebaseAuth.instance.currentUser!.uid; // Get current user ID
    sessionId = const Uuid().v4(); // Generate a unique session ID on init
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Method to retrieve sessions from Firestore
  Stream<QuerySnapshot> getSessions() {
    return FirebaseFirestore.instance
        .collection('conversations')
        .doc(userId)
        .collection('sessions')
        .snapshots();
  }

  // Method to create a new session and store it in Firebase
  Future<void> createNewSession() async {
    final newSessionId = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(userId)
        .collection('sessions')
        .doc(newSessionId)
        .set({
      'createdAt': DateTime.now(),
    });
    setState(() {
      sessionId = newSessionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Center(
          child: Container(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              'ChatSphere',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xfff6b092),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('History', style: TextStyle(color: Colors.white, fontSize: 50)),
                  SizedBox(height: 10),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create New Session'),
              onTap: () async {
                await createNewSession();
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            Divider(),
            StreamBuilder<QuerySnapshot>(
              stream: getSessions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading sessions'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListTile(
                    title: Text('No sessions available'),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final sessionId = doc.id;
                    return ListTile(
                      title: Text('Session ID: $sessionId'),
                      onTap: () {
                        // Handle session selection, for example, navigate to a detailed session view
                        Navigator.of(context).pop();
                        setState(() {
                          this.sessionId = sessionId; // Update current session ID
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_2_sharp),
              title: Text('About Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUs()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_alert_outlined),
              title: Text('Disclaimer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Disclaimer()),
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final user = FirebaseAuth.instance.currentUser;
                final emailInitial = user != null && user.email != null && user.email!.isNotEmpty
                    ? user.email![0].toUpperCase()
                    : 'U';
                return ListTile(
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(
                          emailInitial,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          user?.displayName ?? user?.email ?? 'Guest',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: () {
                          ref.read(authProvider).signout();
                        },
                      ),
                    ],
                  ),
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Expanded(
              child: Messagesview(
                userId: FirebaseAuth.instance.currentUser!.uid,
                sessionId: sessionId,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ask any question',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SendImageScreen(sessionId: sessionId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.image),
                  ),
                  IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    await ref.read(chatProvider).sendonlyMessage(
      apiKey: apiKey,
      promptText: _messageController.text,
      sessionId: sessionId,
    );
    _messageController.clear();
  }
}
