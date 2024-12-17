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
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

import '../widgets/speechtotext.dart';

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

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid; // Initialize userId here
    } else {
      // Handle case where user is not authenticated
      userId = ''; // Or handle appropriately
    }

    // Delay the modification of the provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speechProvider.notifier).state =
          ref.read(speechProvider.notifier).state.copyWith(
            onSpeechUpdate: (recognizedText) {
              setState(() {
                _messageController.text = recognizedText;
              });
            },
          );
    });
    setState(() {

    });
  }




  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }


  Stream<QuerySnapshot> getSessions() {
    try {
      return FirebaseFirestore.instance
          .collection('conversations')
          .doc(userId)
          .collection('sessions')
          .snapshots();
    } catch (e) {
      print('Error: $e');
      return FirebaseFirestore.instance
          .collection('conversations').snapshots();
    }
  }


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
    final speechState = ref.watch(speechProvider);
    final speechNotifier = ref.read(speechProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF212121),
        flexibleSpace: Center(
          child: Container(
            padding: const EdgeInsets.only(top: 30),
            child: const Text(
              'ChatSphere',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xff212121),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xff212121)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('History', style: TextStyle(color: Colors.white, fontSize: 50)),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text(
                  'Create New Session',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  await createNewSession();
                  Navigator.of(context).pop();
                },
              ),
              const Divider(color: Colors.white),
              sessionId.isNotEmpty
                  ? StreamBuilder<QuerySnapshot>(
                stream: getSessions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error loading sessions',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const ListTile(
                      title: Text(
                        'No sessions available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      if (doc.id == null || doc.id.isEmpty) {
                        return const ListTile(
                          title: Text(
                            'Invalid session ID',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final sessionId = doc.id;

                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Session', style: TextStyle(color: Colors.white)),
                                content: const Text(
                                  'Are you sure you want to delete this session and all its messages?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: const Color(0xff212121),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('conversations')
                                          .doc(userId)
                                          .collection('sessions')
                                          .doc(sessionId)
                                          .delete();

                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Session deleted')),
                                      );
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: ListTile(
                          title: Text(
                            'Session ID: $sessionId',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              this.sessionId = sessionId;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  );

                },
              )
                  : const Center(
                child: Text(
                  'Session is empty. Please create or select a session.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(Icons.person_2_sharp, color: Colors.white),
                title: const Text(
                  'About Us',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUs()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_alert_outlined, color: Colors.white),
                title: const Text(
                  'Disclaimer',
                  style: TextStyle(color: Colors.white),
                ),
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
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            user?.displayName ?? user?.email ?? 'Guest',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
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
      ),
      body: Container(
        color: const Color(0xFF212121),
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
                color: const Color(0xff303030),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  if (speechState.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _messageController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ask any question',
                            hintStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: speechNotifier.startListening,
                        icon: const Icon(Icons.mic, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: speechNotifier.stopListening,
                        icon: const Icon(Icons.mic_off, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SendImageScreen(sessionId: sessionId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.image, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: sendMessage,
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
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
