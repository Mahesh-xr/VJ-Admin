import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static StreamSubscription<QuerySnapshot>? _serviceRequestListener;
  static StreamSubscription<QuerySnapshot>? _notificationListener;
  
  // Callbacks for real-time updates
  static Function(String)? onNotificationReceived;
  static Function(String)? onServiceRequestStatusChanged;

  /// Start listening for service request changes
  static void startServiceRequestListener() {
    _serviceRequestListener = _firestore
        .collection('serviceRequests')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          _handleServiceRequestChange(change.doc);
        }
      }
    }, onError: (error) {
      print('❌ Error in service request listener: $error');
    });
    
    print('🔄 Service request listener started');
  }

  /// Start listening for notification changes
  static void startNotificationListener(String userRole, String userId) {
    _notificationListener = _firestore
        .collection('notifications')
        .snapshots()
        .listen((snapshot) {
      print('📱 Notification stream update: ${snapshot.docChanges.length} changes');
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          print('📱 New notification added: ${change.doc.id}');
          _handleNewNotification(change.doc, userRole, userId);
        }
      }
    }, onError: (error) {
      print('❌ Error in notification listener: $error');
    });
    
    print('🔄 Notification listener started for $userRole:$userId');
  }

  /// Handle service request status changes
  static Future<void> _handleServiceRequestChange(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final status = data['status'] as String?;
      final srId = data['srId'] as String?;
      
      print('🔄 Service request change detected: $srId -> $status');
      
      if (status == null || srId == null) return;

      // Get technician info from multiple possible fields based on your Firebase structure
      String? technicianName;
      String? technicianId;
      
      // Check serviceDetails first for technician info
      final serviceDetails = data['serviceDetails'] as Map<String, dynamic>?;
      if (serviceDetails != null) {
        technicianName = serviceDetails['assignedTechnician'] as String? ??
                        serviceDetails['technicianName'] as String?;
        technicianId = serviceDetails['assignedTo'] as String? ??
                      serviceDetails['technicianId'] as String?;
      }
      
      // Fallback to direct fields
      if (technicianName == null) {
        technicianName = data['acceptedBy'] as String? ?? 
                       data['assignedTechnician'] as String?;
      }
      
      if (technicianId == null) {
        technicianId = data['acceptedById'] as String? ?? 
                     data['assignedTo'] as String? ??
                     data['resolvedBy'] as String?;
      }
      
      print('🔍 Found technician: $technicianId - $technicianName');

      if (technicianName != null && technicianId != null) {
        // Clean technician name
        if (technicianName.contains(' - ')) {
          technicianName = technicianName.split(' - ').first;
        }

        // Create notification for status changes
        if (status == 'completed' || status == 'accepted' || status == 'rejected') {
          print('📱 Creating notification for $srId status: $status by $technicianName');
          await _createStatusChangeNotification(srId, status, technicianId, technicianName);
          
          // Trigger callback
          onServiceRequestStatusChanged?.call('$srId:$status');
        }
      } else {
        print('⚠️ Could not find technician info for $srId');
        print('📋 Available fields: ${data.keys.toList()}');
        if (serviceDetails != null) {
          print('📋 ServiceDetails fields: ${serviceDetails.keys.toList()}');
        }
      }
    } catch (e) {
      print('❌ Error handling service request change: $e');
    }
  }

  /// Handle new notifications
  static void _handleNewNotification(DocumentSnapshot doc, String userRole, String userId) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      // Handle both old (flat) and new (nested) structures
      Map<String, dynamic> notificationData;
      if (data.containsKey('data')) {
        // New structure: nested under 'data' field
        notificationData = data['data'] as Map<String, dynamic>;
      } else {
        // Old structure: flat fields
        notificationData = data;
      }
      
      final recipientRole = notificationData['recipientRole'] as String?;
      final type = notificationData['type'] as String?;

      // Check if notification is for this user/role
      if (recipientRole == userRole) {
        onNotificationReceived?.call(type ?? 'unknown');
      }
    } catch (e) {
      print('❌ Error handling new notification: $e');
    }
  }

  /// Create status change notification
  static Future<void> _createStatusChangeNotification(
    String srId, 
    String status, 
    String technicianId, 
    String technicianName
  ) async {
    try {
      // Check if notification already exists for this status change (within last 5 minutes)
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      final existingNotifications = await _firestore
          .collection('notifications')
          .where('data.srId', isEqualTo: srId)
          .where('data.type', isEqualTo: 'service_$status')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(fiveMinutesAgo))
          .get();

      if (existingNotifications.docs.isEmpty) {
        // Get service request details for enhanced notification
        DocumentSnapshot serviceRequestDoc = await _firestore
            .collection('serviceRequests')
            .doc(srId)
            .get();
        
        Map<String, dynamic>? serviceRequestData;
        if (serviceRequestDoc.exists) {
          serviceRequestData = serviceRequestDoc.data() as Map<String, dynamic>?;
        }
        
        // Create notification with service request details
        await AdminAction.createTechnicianActionNotification(
          srId: srId,
          technicianId: technicianId,
          technicianName: technicianName,
          action: status,
          serviceRequestData: serviceRequestData,
        );
      }
    } catch (e) {
      print('❌ Error creating status change notification: $e');
    }
  }

  /// Create notification for technician assignment
  static Future<void> createTechnicianAssignmentNotification({
    required String srId,
    required String technicianId,
    required String technicianName,
    required String serviceRequestTitle,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'createdAt': FieldValue.serverTimestamp(),
        'data': {
          'title': 'New Service Request Assigned',
          'message': 'You have been assigned service request: $srId - $serviceRequestTitle',
          'type': 'service_assignment',
          'srId': srId,
   
          'isRead': false,
          'recipientRole': 'technician',
          'senderId': 'system',
          'senderName': 'System',
          'technicianId': technicianId,
          'technicianName': technicianName,
        },
      });
    } catch (e) {
      print('❌ Error creating technician assignment notification: $e');
    }
  }

  /// Create notification for admin access request
  static Future<void> createAdminAccessRequestNotification({
    required String technicianId,
    required String technicianName,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'createdAt': FieldValue.serverTimestamp(),
        'data': {
          'title': 'Admin Access Request',
          'message': 'Technician $technicianName is requesting admin access.',
          'type': 'admin_access_request',
          'isRead': false,
          'recipientRole': 'admin',
          'senderId': technicianId,
          'senderName': technicianName,
          'technicianId': technicianId,
          'technicianName': technicianName,
          'status': 'pending',
        },
      });
    } catch (e) {
      print('❌ Error creating admin access request notification: $e');
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // First check the document structure
      final doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();
      
      final docData = doc.data() as Map<String, dynamic>?;
      if (docData == null) return;
      
      // Check if it's new structure (nested) or old structure (flat)
      if (docData.containsKey('data')) {
        // New structure: nested under 'data' field
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .update({
          'data.isRead': true,
          'data.readAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Old structure: flat fields
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .update({
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Stop all listeners
  static void stopAllListeners() {
    _serviceRequestListener?.cancel();
    _notificationListener?.cancel();
  }

  /// Get notifications for specific role
  static Stream<QuerySnapshot> getNotificationsForRole(String role) {
    return _firestore
        .collection('notifications')
        .where('data.recipientRole', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }
} 