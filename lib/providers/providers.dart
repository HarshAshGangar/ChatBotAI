import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seventhapp/Auth/auth.dart';
import 'package:seventhapp/Controller/chat.dart';

// Provide an instance of Chat using Riverpod
final chatProvider = Provider((ref) => Chat());

final authProvider = Provider((ref) => Auth());