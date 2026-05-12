import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Handles both Google Sign-In and Firebase Authentication
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors
      throw Exception('Firebase auth error: ${e.message}');
    } catch (e) {
      // Handle generic errors
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Registers a user manually using Email and Password
  Future<UserCredential?> registerWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send the verification link to the newly registered email
      if (credential.user != null && !credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Registration error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Logs in a user manually using Email and Password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Login error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  /// Signs out from both Google and Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
