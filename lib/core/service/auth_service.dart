import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../errors/failures.dart';
import '../database/local_db_helper.dart';

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
  Future<UserCredential?> registerWithEmailPassword(String email, String password, {String? username}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name in Firebase if username is provided
      if (username != null && credential.user != null) {
        await credential.user!.updateDisplayName(username);
      }
      
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
      await LocalDBHelper.instance.clearCurrentUser();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Sends a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Reset password error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  /// Updates user email address in FirebaseAuth after sending verification code
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthFailure('Pengguna tidak terautentikasi.');
      }
      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('requires-recent-login')) {
        throw RequiresRecentLoginFailure();
      }
      if (e is FirebaseAuthException) {
        throw AuthFailure(e.message ?? 'Gagal memperbarui email.');
      }
      throw AuthFailure('Terjadi kesalahan saat memperbarui email: $e');
    }
  }

  /// Updates user password in FirebaseAuth
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthFailure('Pengguna tidak terautentikasi.');
      }
      await user.updatePassword(newPassword);
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('requires-recent-login')) {
        throw RequiresRecentLoginFailure();
      }
      if (e is FirebaseAuthException) {
        throw AuthFailure(e.message ?? 'Gagal memperbarui kata sandi.');
      }
      throw AuthFailure('Terjadi kesalahan saat memperbarui kata sandi: $e');
    }
  }

  /// Gets the email of the currently authenticated user
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Gets the sign-in provider ID for the current authenticated user
  String get signInProvider {
    final user = _auth.currentUser;
    if (user == null) return 'none';
    final providers = user.providerData.map((info) => info.providerId).toList();
    if (providers.contains('google.com')) return 'google.com';
    return 'password';
  }

  /// Re-authenticates the current user using email/password or Google
  Future<void> reauthenticate(String? currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthFailure('Pengguna tidak terautentikasi.');
      }
      final provider = signInProvider;
      if (provider == 'google.com') {
        // Re-authenticate Google user
        final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
        if (googleUser == null) {
          throw AuthFailure('Verifikasi ulang Google dibatalkan.');
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        // Re-authenticate Email/Password user
        if (currentPassword == null || currentPassword.isEmpty) {
          throw AuthFailure('Kata sandi saat ini diperlukan untuk verifikasi.');
        }
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Verifikasi ulang gagal.');
    } catch (e) {
      throw AuthFailure('Terjadi kesalahan saat verifikasi ulang: $e');
    }
  }
}
