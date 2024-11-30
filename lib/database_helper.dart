import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseHelper._init();

  Future<String?> registerUser(
      String email, String password, String name) async {
    try {
      DocumentReference newUserRef = await _firestore.collection('users').add({
        'email': email,
        'password': password,
        'name': name,
        'imageBase64': ''
      });

      print("User registered successfully with ID: ${newUserRef.id}");
      return newUserRef.id;
    } catch (e) {
      print("Error registering user: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<void> updateUserProfile(String userId, String name, String email,
      String password, String imageBase64) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'email': email,
        'password': password,
        'profileImage': imageBase64,
      });
      print("Profile updated successfully.");
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}
