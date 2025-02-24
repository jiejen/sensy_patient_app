import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in using either an email or a Patient ID.
  Future<UserCredential> signIn({
    required String identifier,
    required String password,
  }) async {
    String email;

    // If the identifier contains '@', we assume it's an email.
    if (identifier.contains('@')) {
      email = identifier;
    } else {
      // Otherwise, treat it as a Patient ID and look up the associated email.
      final querySnapshot = await _firestore
          .collection('patients')
          .where('patientId', isEqualTo: identifier)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No account found for this email or Patient ID',
        );
      }

      final data = querySnapshot.docs.first.data();
      email = (data['email'] as String?) ?? '';
      if (email.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Invalid email or Patient ID',
        );
      }
    }

    // Authenticate with Firebase using the resolved email.
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out from Firebase.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
