class Teacher {
  final String staffId; // New property for staff ID
  final String name;
  final String email;
  final String role;
  String degree;
  String certificate;
  String education;

  Teacher({
    required this.staffId,
    required this.name,
    required this.email,
    required this.role,
    required this.degree,
    required this.certificate,
    required this.education,
  });
}
