import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches current admin data from database and returns formatted name
  /// Format: "Designation - Full Name (Employee ID)"
  static Future<String> getFormattedAdminName([String? adminUid]) async {
    try {
      // Use provided UID or current user's UID
      String uid = adminUid ?? _auth.currentUser?.uid ?? '';
      
      if (uid.isEmpty) {
        return 'Unknown Admin';
      }

      // Fetch admin document from Firestore
      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(uid)
          .get();

      if (!adminDoc.exists) {
        return 'Admin Not Found';
      }

      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

      // Extract required fields
      String designation = adminData['designation'] ?? 'Unknown';
      String fullName = adminData['fullName'] ?? adminData['name'] ?? 'Unknown';
      String employeeId = adminData['employeeId'] ?? 'Unknown';

      // Return formatted string
      return '$designation - $fullName ($employeeId)';
      
    } catch (e) {
      print('Error fetching admin data: $e');
      return 'Error Loading Admin';
    }
  }

  /// Alternative method that returns just the name and employee ID
  static Future<String> getAdminNameAndId([String? adminUid]) async {
    try {
      String uid = adminUid ?? _auth.currentUser?.uid ?? '';
      
      if (uid.isEmpty) {
        return 'Unknown';
      }

      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(uid)
          .get();

      if (!adminDoc.exists) {
        return 'Admin Not Found';
      }

      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
      String fullName = adminData['fullName'] ?? adminData['name'] ?? 'Unknown';
      String employeeId = adminData['employeeId'] ?? 'Unknown';

      return '$fullName ($employeeId)';
      
    } catch (e) {
      print('Error fetching admin data: $e');
      return 'Error Loading';
    }
  }

  /// Get admin name only
  static Future<String> getAdminName([String? adminUid]) async {
    try {
      String uid = adminUid ?? _auth.currentUser?.uid ?? '';
      
      if (uid.isEmpty) {
        return 'Unknown Admin';
      }

      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(uid)
          .get();

      if (!adminDoc.exists) {
        return 'Admin Not Found';
      }

      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
      return adminData['fullName'] ?? adminData['name'] ?? 'Unknown Admin';
      
    } catch (e) {
      print('Error fetching admin name: $e');
      return 'Error Loading Admin';
    }
  }
}