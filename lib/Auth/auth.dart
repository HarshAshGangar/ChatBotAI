import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add this import

@immutable
class Auth{
  final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signinwithGoogle() async{
    final googleuser = await _googleSignIn.signIn();
    if(googleuser == null) return null;
    final googleAuth = await googleuser.authentication;
    final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
    );
    return await firebaseauth.signInWithCredential(credential);
  }
  Future<void> signout() async{
    await _googleSignIn.signOut();
    await firebaseauth.signOut();
  }
}