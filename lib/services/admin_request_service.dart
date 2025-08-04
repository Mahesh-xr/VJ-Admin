import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';

class AdminRequestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of admin access requests for real-time updates
  static Stream<QuerySnapshot> getAdminAccessRequestsStream() {
    return _firestore
        .collection('notifications')
        .where('recipientRole', isEqualTo: 'admin')
        .where('type', isEqualTo: 'admin_access_request')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream of pending admin access requests
  static Stream<QuerySnapshot> getPendingAdminAccessRequestsStream() {
    return _firestore
        .collection('notifications')
        .where('recipientRole', isEqualTo: 'admin')
        .where('type', isEqualTo: 'admin_access_request')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream of unread admin access requests
  static Stream<QuerySnapshot> getUnreadAdminAccessRequestsStream() {
    return _firestore
        .collection('notifications')
        .where('recipientRole', isEqualTo: 'admin')
        .where('type', isEqualTo: 'admin_access_request')
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get admin access request counts for dashboard
  static Future<Map<String, int>> getAdminRequestCounts() async {
    try {
      return await AdminAction.getAdminAccessRequestCounts();
    } catch (e) {
      print('Error getting admin request counts: $e');
      return {
        'total': 0,
        'pending': 0,
        'unread': 0,
      };
    }
  }

  /// Mark all admin access requests as read
  static Future<void> markAllAdminRequestsAsRead() async {
    try {
      final unreadRequests = await AdminAction.getUnreadAdminAccessRequests();
      
      for (final request in unreadRequests) {
        await AdminAction.markAdminAccessRequestAsRead(request['id']);
      }
      
      print('✅ Marked ${unreadRequests.length} admin requests as read');
    } catch (e) {
      print('❌ Error marking admin requests as read: $e');
    }
  }

  /// Check if user has admin access
  static Future<bool> checkUserAdminAccess(String userId) async {
    try {
      final doc = await _firestore.collection('technicians').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['hasAdminAccess'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error checking admin access: $e');
      return false;
    }
  }

  /// Get technician admin access status
  static Future<Map<String, dynamic>?> getTechnicianAdminStatus(String technicianId) async {
    try {
      final doc = await _firestore.collection('technicians').doc(technicianId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'hasAdminAccess': data['hasAdminAccess'] ?? false,
          'adminAccessStatus': data['adminAccessStatus'],
          'adminAccessGrantedAt': data['adminAccessGrantedAt'],
          'adminAccessGrantedBy': data['adminAccessGrantedBy'],
          'adminAccessGrantedByName': data['adminAccessGrantedByName'],
          'adminAccessDeniedAt': data['adminAccessDeniedAt'],
          'adminAccessDeniedBy': data['adminAccessDeniedBy'],
          'adminAccessDeniedByName': data['adminAccessDeniedByName'],
          'adminAccessRejectionReason': data['adminAccessRejectionReason'],
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting technician admin status: $e');
      return null;
    }
  }

  /// Create admin access request from technician
  static Future<void> requestAdminAccess({
    required String technicianId,
    required String technicianName,
    String? srId,
  }) async {
    try {
      await AdminAction.createAdminAccessRequest(
        technicianId: technicianId,
        technicianName: technicianName,
        srId: srId,
      );
    } catch (e) {
      print('Error creating admin access request: $e');
      rethrow;
    }
  }

  /// Approve admin access request
  static Future<bool> approveAdminAccess({
    required String notificationId,
    required String technicianId,
    required String technicianName,
    required String adminUid,
    required String adminName,
  }) async {
    try {
      return await AdminAction.approveAdminAccessRequest(
        notificationId: notificationId,
        technicianId: technicianId,
        technicianName: technicianName,
        adminUid: adminUid,
        adminName: adminName,
      );
    } catch (e) {
      print('Error approving admin access: $e');
      return false;
    }
  }

  /// Reject admin access request
  static Future<bool> rejectAdminAccess({
    required String notificationId,
    required String technicianId,
    required String technicianName,
    required String adminUid,
    required String adminName,
    String? reason,
  }) async {
    try {
      return await AdminAction.rejectAdminAccessRequest(
        notificationId: notificationId,
        technicianId: technicianId,
        technicianName: technicianName,
        adminUid: adminUid,
        adminName: adminName,
        reason: reason,
      );
    } catch (e) {
      print('Error rejecting admin access: $e');
      return false;
    }
  }

  /// Get admin access request by ID
  static Future<Map<String, dynamic>?> getAdminAccessRequestById(String notificationId) async {
    try {
      return await AdminAction.getAdminAccessRequestById(notificationId);
    } catch (e) {
      print('Error getting admin access request: $e');
      return null;
    }
  }

  /// Listen for admin access request changes
  static Stream<DocumentSnapshot> listenToAdminRequest(String notificationId) {
    return _firestore
        .collection('notifications')
        .doc(notificationId)
        .snapshots();
  }

  /// Get admin access request history for a technician
  static Future<List<Map<String, dynamic>>> getTechnicianAdminRequestHistory(String technicianId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('data.technicianId', isEqualTo: technicianId)
          .where('data.type', isEqualTo: 'admin_access_request')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Error getting technician admin request history: $e');
      return [];
    }
  }

  /// Get admin access response history for a technician
  static Future<List<Map<String, dynamic>>> getTechnicianAdminResponseHistory(String technicianId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('data.senderId', isEqualTo: technicianId)
          .where('data.type', isEqualTo: 'admin_access_response')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Error getting technician admin response history: $e');
      return [];
    }
  }

  // ============== ADMIN PROMOTION METHODS ==============

  /// Stream of admin promotion requests for technicians
  static Stream<QuerySnapshot> getAdminPromotionRequestsStream(String technicianId) {
    return _firestore
        .collection('notifications')
        .where('data.recipientRole', isEqualTo: 'technician')
        .where('data.type', isEqualTo: 'admin_promotion_request')
        .where('data.technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream of admin promotion responses for admins
  static Stream<QuerySnapshot> getAdminPromotionResponsesStream(String adminUid) {
    return _firestore
        .collection('notifications')
        .where('data.recipientRole', isEqualTo: 'admin')
        .where('data.type', isEqualTo: 'admin_promotion_response')
        .where('data.adminUid', isEqualTo: adminUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get pending admin promotion requests for a technician
  static Future<List<Map<String, dynamic>>> getPendingAdminPromotionRequests(String technicianId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('data.recipientRole', isEqualTo: 'technician')
          .where('data.type', isEqualTo: 'admin_promotion_request')
          .where('data.technicianId', isEqualTo: technicianId)
          .where('data.status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Error getting pending admin promotion requests: $e');
      return [];
    }
  }

  /// Accept admin promotion
  static Future<bool> acceptAdminPromotion({
    required String notificationId,
    required String technicianId,
    required String technicianName,
    required String adminUid,
    required String adminName,
  }) async {
    try {
      return await AdminAction.acceptAdminPromotion(
        notificationId: notificationId,
        technicianId: technicianId,
        technicianName: technicianName,
        adminUid: adminUid,
        adminName: adminName,
      );
    } catch (e) {
      print('Error accepting admin promotion: $e');
      return false;
    }
  }

  /// Reject admin promotion
  static Future<bool> rejectAdminPromotion({
    required String notificationId,
    required String technicianId,
    required String technicianName,
    required String adminUid,
    required String adminName,
    String? reason,
  }) async {
    try {
      return await AdminAction.rejectAdminPromotion(
        notificationId: notificationId,
        technicianId: technicianId,
        technicianName: technicianName,
        adminUid: adminUid,
        adminName: adminName,
        reason: reason,
      );
    } catch (e) {
      print('Error rejecting admin promotion: $e');
      return false;
    }
  }

  /// Check if user is promoted from technician
  static Future<bool> isPromotedFromTechnician(String userId) async {
    try {
      final doc = await _firestore.collection('admins').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['promotedFromTechnician'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error checking if promoted from technician: $e');
      return false;
    }
  }

  /// Get promotion history for a user
  static Future<Map<String, dynamic>?> getPromotionHistory(String userId) async {
    try {
      // Check if user exists in admins collection (promoted)
      final adminDoc = await _firestore.collection('admins').doc(userId).get();
      if (adminDoc.exists) {
        final adminData = adminDoc.data() as Map<String, dynamic>;
        if (adminData['promotedFromTechnician'] == true) {
          return {
            'isPromoted': true,
            'promotedAt': adminData['adminAccessGrantedAt'],
            'promotedBy': adminData['adminAccessGrantedByName'],
            'originalTechnicianData': adminData['originalTechnicianData'],
          };
        }
      }

      // Check technician collection for promotion status
      final techDoc = await _firestore.collection('technicians').doc(userId).get();
      if (techDoc.exists) {
        final techData = techDoc.data() as Map<String, dynamic>;
        return {
          'isPromoted': techData['isPromotedToAdmin'] == true,
          'promotedAt': techData['promotedAt'],
          'promotedBy': techData['adminAccessGrantedByName'],
          'adminAccessStatus': techData['adminAccessStatus'],
        };
      }

      return null;
    } catch (e) {
      print('Error getting promotion history: $e');
      return null;
    }
  }

  /// Handle push notification for admin promotion
  static Future<void> handlePromotionPushNotification(Map<String, dynamic> data) async {
    try {
      final type = data['type'];
      final technicianId = data['technicianId'];
      final adminName = data['adminName'];

      if (type == 'admin_promotion_request') {
        // Navigate to promotion notification screen
        // This would be handled in your main app navigation
        print('Received admin promotion request from $adminName');
      } else if (type == 'admin_promotion_response') {
        final status = data['status'];
        final technicianName = data['technicianName'];
        
        if (status == 'accepted') {
          print('Technician $technicianName accepted admin promotion');
        } else if (status == 'rejected') {
          print('Technician $technicianName rejected admin promotion');
        }
      }
    } catch (e) {
      print('Error handling promotion push notification: $e');
    }
  }
} 