import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRepository {
  final FirebaseFirestore _firestore;

  PatientRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Retrieves the email for a given Patient ID.
  Future<String?> getEmailForPatientId(String patientId) async {
    final querySnapshot = await _firestore
        .collection('patients')
        .where('patientId', isEqualTo: patientId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    final data = querySnapshot.docs.first.data();
    return data['email'] as String?;
  }
}
