class Patient {
  final String patientId;
  final String email;
  final String? name; // Optional additional field

  Patient({
    required this.patientId,
    required this.email,
    this.name,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientId: map['patientId'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'email': email,
      'name': name,
    };
  }
}
