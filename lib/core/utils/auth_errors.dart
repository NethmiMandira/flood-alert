import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object e, {required bool si}) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'email-already-in-use':
        return si ? 'මෙම email එක දැනටමත් භාවිතා වේ' : 'Email already in use';
      case 'invalid-email':
        return si ? 'වලංගු email එකක් ඇතුළත් කරන්න' : 'Invalid email';
      case 'weak-password':
        return si
            ? 'මුරපදය අවම අකුරු 6ක් විය යුතුය'
            : 'Password must be at least 6 characters';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return si ? 'email හෝ මුරපදය වැරදියි' : 'Wrong email or password';
      case 'network-request-failed':
        return si ? 'අන්තර්ජාල සම්බන්ධතාවය පරීක්ෂා කරන්න' : 'Check your internet';
    }
  }
  return si ? 'දෝෂයක් සිදුවිය' : 'Something went wrong';
}