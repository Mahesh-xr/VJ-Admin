import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vayujal/widgets/dashboard/status_card.dart';

class AdminStatusCardsGrid extends StatefulWidget {
  const AdminStatusCardsGrid({super.key});

  @override
  State<AdminStatusCardsGrid> createState() => _AdminStatusCardsGridState();
}

class _AdminStatusCardsGridState extends State<AdminStatusCardsGrid> {
  final FirestoreService _firestoreService = FirestoreService();
  
  int totalRequests = 0;
  int pendingRequests = 0;
  int inProgressRequests = 0;
  int completedRequests = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatusCounts();
  }

  Future<void> _loadStatusCounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, int> statusCounts = await _firestoreService.getAllServiceRequestCounts();
      
      setState(() {
        totalRequests = statusCounts['total'] ?? 0;
        pendingRequests = statusCounts['pending'] ?? 0;
        inProgressRequests = statusCounts['in_progress'] ?? 0;
        completedRequests = statusCounts['completed'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading status counts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatusCard(
          title: 'Total Requests',
          count: totalRequests.toString(),
          accentColor: Colors.blue,
        ),
        StatusCard(
          title: 'Pending',
          count: pendingRequests.toString(),
          accentColor: Colors.orange,
        ),
        StatusCard(
          title: 'In Progress',
          count: inProgressRequests.toString(),
          accentColor: Colors.green,
        ),
        StatusCard(
          title: 'Completed',
          count: completedRequests.toString(),
          accentColor: Colors.purple,
        ),
      ],
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all service request counts for admin dashboard
  /// Fetches all service requests and categorizes them by status
  Future<Map<String, int>> getAllServiceRequestCounts() async {
    try {
      // Get all service requests without any user-specific filtering
      final QuerySnapshot querySnapshot = await _firestore
          .collection('serviceRequests')
          .get();

      // Initialize counters
      Map<String, int> statusCounts = {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
      };

      // Count requests by status
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status']?.toString().toLowerCase() ?? 'unknown';

        statusCounts['total'] = statusCounts['total']! + 1;

        if (statusCounts.containsKey(status)) {
          statusCounts[status] = statusCounts[status]! + 1;
        }
      }

      return statusCounts;
    } catch (e) {
      print('Error getting all service request counts: $e');
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
      };
    }
  }

  /// Get all service requests by status for admin
  Future<List<QueryDocumentSnapshot>> getAllServiceRequestsByStatus(String status) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('serviceRequests')
          .where('status', isEqualTo: status)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error getting service requests by status: $e');
      return [];
    }
  }

  /// Get all service requests for admin
  Future<List<QueryDocumentSnapshot>> getAllServiceRequests() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('serviceRequests')
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error getting all service requests: $e');
      return [];
    }
  }

  /// Get service requests with additional filtering options for admin
  Future<List<QueryDocumentSnapshot>> getServiceRequestsWithFilters({
    String? status,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('serviceRequests');

      // Apply filters if provided
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      if (assignedTo != null && assignedTo.isNotEmpty) {
        query = query.where('serviceDetails.assignedTo', isEqualTo: assignedTo);
      }

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error getting filtered service requests: $e');
      return [];
    }
  }

  // Keep the original technician methods for backward compatibility
  /// Get employee ID from technician document using current user's UID
  Future<String?> getCurrentUserEmployeeId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await _firestore
          .collection('technicians')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['employeeId']?.toString();
      }

      return null;
    } catch (e) {
      print('Error getting current user employee ID: $e');
      return null;
    }
  }

  /// Get service request counts for currently logged-in user (technician view)
  Future<Map<String, int>> getCurrentUserServiceRequestCounts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in');
      }

      // Get employee ID from technicians collection using current user's UID
      final technicianDoc = await _firestore
          .collection('technicians')
          .doc(user.uid)
          .get();

      if (!technicianDoc.exists) {
        throw Exception('Technician document not found for user: ${user.uid}');
      }

      final technicianData = technicianDoc.data() as Map<String, dynamic>;
      final employeeId = technicianData['employeeId']?.toString();

      if (employeeId == null || employeeId.isEmpty) {
        throw Exception('Employee ID not found in technician document');
      }

      // Get service requests where serviceDetails.assignedTo equals employeeId
      final QuerySnapshot querySnapshot = await _firestore
          .collection('serviceRequests')
          .where('serviceDetails.assignedTo', isEqualTo: employeeId)
          .get();

      // Initialize counters
      Map<String, int> statusCounts = {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
      };

      // Count requests by status
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status']?.toString().toLowerCase() ?? 'unknown';

        statusCounts['total'] = statusCounts['total']! + 1;

        if (statusCounts.containsKey(status)) {
          statusCounts[status] = statusCounts[status]! + 1;
        }
      }

      return statusCounts;
    } catch (e) {
      print('Error getting current user service request counts: $e');
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
      };
    }
  }
}