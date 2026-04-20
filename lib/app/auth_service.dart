// import 'package:firebase_auth/firebase_auth.dart';
// // 1. Add this alias 'as gsign'
// import 'package:google_sign_in/google_sign_in.dart' as gsign;
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // 2. Use the alias to call the constructor
//   final gsign.GoogleSignIn _googleSignIn = gsign.GoogleSignIn();
//
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // 3. Use the alias for the Account class
//       final gsign.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null;
//
//       // 4. Use the alias for the Auth Details
//       final gsign.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       return await _auth.signInWithCredential(credential);
//     } catch (e) {
//       print("Google Auth Error: $e");
//       return null;
//     }
//   }
//
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }