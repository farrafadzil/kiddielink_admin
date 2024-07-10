// firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<void> addTeacher(String firstName, String lastName, String email, String role) async {
    try {
      await FirebaseFirestore.instance.collection('teachers').add({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        // Add more fields as needed
      });
      print('Data added to Firestore');
    } catch (error) {
      print('Failed to add data to Firestore: $error');
      throw error; // Rethrow the error to handle it in the UI
    }
  }
}
