// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class AdminAction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============== EXISTING DEVICE MANAGEMENT METHODS ==============

  static Future<List<Map<String, dynamic>>> getAllTechnicians() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('technicians')
        .where('role', isEqualTo: 'tech') // Only fetch technicians with 'tech' role
        .get();

    List<Map<String, dynamic>> technicians = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Debug: Print all available fields
      print("Available fields for technician ${data['fullName'] ?? 'Unknown'}: ${data.keys.toList()}");

      // Try different possible field names for employee ID
      String? employeeId = data['employeeId'] ?? 
                          data['empId'] ?? 
                          data['employee_id'] ?? 
                          data['id'] ?? 
                          doc.id; // Use document ID as fallback

      // Check if we have a valid employee ID
      if (employeeId == null || employeeId.toString().trim().isEmpty) {
        print("⚠️ Skipping technician ${data['fullName'] ?? 'Unknown'} - no valid employee ID found");
        return null; // Filter out this entry
      }

      return {
        'name': data['fullName'] ?? data['name'] ?? 'Unknown Technician',
        'empId': employeeId.toString(),
        'profileImageUrl': data['profileImageUrl'] ?? data['profileImage'] ?? '',
        'role': data['role'] ?? 'tech', // Include role for debugging
      };
    }).whereType<Map<String, dynamic>>().toList(); // Removes nulls

    print("✅ Fetched ${technicians.length} technicians with 'tech' role.");
    
    // Debug: Print technician details
    for (var tech in technicians) {
      print("Technician: ${tech['name']} (ID: ${tech['empId']}) - Role: ${tech['role']} - Profile URL: ${tech['profileImageUrl']}");
    }
    
    return technicians;
  } catch (e) {
    print("🔥 Error fetching technicians: $e");
    return [];
  }
}

  /// Adds a new device to Firestore
  static Future addNewDevice(Map<String, dynamic> deviceData) async {
    try {
      String serialNumber = deviceData['deviceInfo']['awgSerialNumber'];
      await _firestore.collection('devices').doc(serialNumber).set(deviceData);
      
      // Create notification for admin when device is added
      await _createAdminDeviceNotification('Device Added', 'Device with serial number $serialNumber has been added successfully.');
      
      print("✅ Device added successfully: $serialNumber");
    } catch (e) {
      print("❌ Error adding device: $e");
    }
  }

  /// Updates an existing device in Firestore
  static Future editDevice(String serialNumber, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('devices').doc(serialNumber).update(updatedData);
      
      // Create notification for admin when device is updated
      await _createAdminDeviceNotification('Device Updated', 'Device with serial number $serialNumber has been updated successfully.');
      
      print("✅ Device updated successfully: $serialNumber");
    } catch (e) {
      print("❌ Error updating device: $e");
    }
  }

  /// Fetches all devices from Firestore
  static Future<List<Map<String, dynamic>>> getAllDevices() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      List<Map<String, dynamic>> devices = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("✅ Fetched ${devices.length} devices.");
      return devices;
    } catch (e) {
      print("❌ Error fetching devices: $e");
      return [];
    }
  }

  /// Fetch a single device by its serial number
  static Future<Map<String, dynamic>?> getDeviceBySerial(String serialNumber) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('devices').doc(serialNumber).get();
      if (doc.exists) {
        print("✅ Device found: $serialNumber");
        return doc.data() as Map<String, dynamic>;
      } else {
        print("⚠️ No device found with serial: $serialNumber");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching device: $e");
      return null;
    }
  }

  /// Fetch unique cities from all devices
  static Future<List<String>> getUniqueCities() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      Set<String> cities = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final locationDetails = data['locationDetails'] as Map<String, dynamic>?;
        final city = locationDetails?['city']?.toString().trim();
        
        if (city != null && city.isNotEmpty) {
          cities.add(city);
        }
      }
      
      List<String> sortedCities = cities.toList()..sort();
      print("✅ Fetched ${sortedCities.length} unique cities.");
      return sortedCities;
    } catch (e) {
      print("❌ Error fetching cities: $e");
      return [];
    }
  }

  /// Fetch unique states from all devices
  static Future<List<String>> getUniqueStates() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      Set<String> states = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final locationDetails = data['locationDetails'] as Map<String, dynamic>?;
        final state = locationDetails?['state']?.toString().trim();
        
        if (state != null && state.isNotEmpty) {
          states.add(state);
        }
      }
      
      List<String> sortedStates = states.toList()..sort();
      print("✅ Fetched ${sortedStates.length} unique states.");
      return sortedStates;
    } catch (e) {
      print("❌ Error fetching states: $e");
      return [];
    }
  }

  /// Fetch unique models from all devices
  static Future<List<String>> getUniqueModels() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      Set<String> models = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final deviceInfo = data['deviceInfo'] as Map<String, dynamic>?;
        final model = deviceInfo?['model']?.toString().trim();
        
        if (model != null && model.isNotEmpty) {
          models.add(model);
        }
      }
      
      List<String> sortedModels = models.toList()..sort();
      print("✅ Fetched ${sortedModels.length} unique models.");
      return sortedModels;
    } catch (e) {
      print("❌ Error fetching models: $e");
      return [];
    }
  }

  /// Fetch devices with multiple filters
  static Future<List<Map<String, dynamic>>> getFilteredDevices({
    List<String>? models,
    List<String>? cities,
    List<String>? states,
    String? searchTerm,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      List<Map<String, dynamic>> devices = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      
      // Apply filters
      List<Map<String, dynamic>> filteredDevices = devices.where((device) {
        final deviceInfo = device['deviceInfo'] as Map<String, dynamic>?;
        final locationDetails = device['locationDetails'] as Map<String, dynamic>?;
        final customerDetails = device['customerDetails'] as Map<String, dynamic>?;
        
        // Model filter
        if (models != null && models.isNotEmpty) {
          final deviceModel = deviceInfo?['model']?.toString();
          if (deviceModel == null || !models.contains(deviceModel)) {
            return false;
          }
        }
        
        // City filter
        if (cities != null && cities.isNotEmpty) {
          final deviceCity = locationDetails?['city']?.toString();
          if (deviceCity == null || !cities.contains(deviceCity)) {
            return false;
          }
        }
        
        // State filter
        if (states != null && states.isNotEmpty) {
          final deviceState = locationDetails?['state']?.toString();
          if (deviceState == null || !states.contains(deviceState)) {
            return false;
          }
        }
        
        // Search term filter
        if (searchTerm != null && searchTerm.isNotEmpty) {
          final searchLower = searchTerm.toLowerCase();
          final model = deviceInfo?['model']?.toString().toLowerCase() ?? '';
          final serialNumber = deviceInfo?['serialNumber']?.toString().toLowerCase() ?? '';
          final company = customerDetails?['company']?.toString().toLowerCase() ?? '';
          final city = locationDetails?['city']?.toString().toLowerCase() ?? '';
          
          if (!model.contains(searchLower) && 
              !serialNumber.contains(searchLower) && 
              !company.contains(searchLower) && 
              !city.contains(searchLower)) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      print("✅ Filtered ${filteredDevices.length} devices from ${devices.length} total devices.");
      return filteredDevices;
    } catch (e) {
      print("❌ Error fetching filtered devices: $e");
      return [];
    }
  }

  /// Get devices count by filter criteria
  static Future<Map<String, int>> getDevicesCountByFilters() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      List<Map<String, dynamic>> devices = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      
      Map<String, int> modelCounts = {};
      Map<String, int> cityCounts = {};
      Map<String, int> stateCounts = {};
      
      for (var device in devices) {
        final deviceInfo = device['deviceInfo'] as Map<String, dynamic>?;
        final locationDetails = device['locationDetails'] as Map<String, dynamic>?;
        
        // Count models
        final model = deviceInfo?['model']?.toString();
        if (model != null && model.isNotEmpty) {
          modelCounts[model] = (modelCounts[model] ?? 0) + 1;
        }
        
        // Count cities
        final city = locationDetails?['city']?.toString();
        if (city != null && city.isNotEmpty) {
          cityCounts[city] = (cityCounts[city] ?? 0) + 1;
        }
        
        // Count states
        final state = locationDetails?['state']?.toString();
        if (state != null && state.isNotEmpty) {
          stateCounts[state] = (stateCounts[state] ?? 0) + 1;
        }
      }
      
      return {
        'models': modelCounts.length,
        'cities': cityCounts.length,
        'states': stateCounts.length,
        'totalDevices': devices.length,
      };
    } catch (e) {
      print("❌ Error getting devices count: $e");
      return {};
    }
  }

  /// Delete a device from Firestore
  static Future<bool> deleteDevice(String serialNumber) async {
    try {
      await _firestore.collection('devices').doc(serialNumber).delete();
      
      // Create notification for admin when device is deleted
      await _createAdminDeviceNotification('Device Deleted', 'Device with serial number $serialNumber has been deleted successfully.');
      
      print("✅ Device deleted successfully: $serialNumber");
      return true;
    } catch (e) {
      print("❌ Error deleting device: $e");
      return false;
    }
  }

  /// Check if device exists before deletion
  static Future<bool> deviceExists(String serialNumber) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('devices').doc(serialNumber).get();
      return doc.exists;
    } catch (e) {
      print("❌ Error checking device existence: $e");
      return false;
    }
  }

  // ============== NEW SERVICE REQUEST MANAGEMENT METHODS ==============

  /// Generate unique Service Request ID
  static String _generateServiceRequestId() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String random = Random().nextInt(999).toString().padLeft(3, '0');
    return 'SR_${timestamp.substring(8)}_$random';
  }

  /// Create a new service request
  static Future<String> createServiceRequest({
    required Map<String, dynamic> equipmentDetails,
    required Map<String, dynamic> customerDetails,
    required Map<String, dynamic> serviceDetails,
    String? deviceId,
  }) async {
    try {
      // Generate unique SR ID
      String srId = _generateServiceRequestId();
      
      // Prepare service request data
      Map<String, dynamic> serviceRequestData = {
        'srId': srId,
        'deviceId': deviceId,
        'equipmentDetails': equipmentDetails,
        'customerDetails': customerDetails,
        'serviceDetails': {
          ...serviceDetails,
          'createdDate': FieldValue.serverTimestamp(),
        },
        'status': 'pending',
        'isActioned': false, // Default field to track if any action has been taken
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('serviceRequests').doc(srId).set(serviceRequestData);
      
      print("🔔 Service request saved, creating notifications...");
      
      // Create notification for the assigned technician
      if (serviceDetails['assignedTo'] != null) {
        print("🔔 Creating technician assignment notification...");
        await _createAssignmentNotification(srId, serviceDetails['assignedTo'], isReassignment: false);
      }
      
      // Create notification for admin (service request creator)
      print("🔔 Creating admin notification...");
      await _createAdminNotification(srId, serviceDetails);
      
      print("✅ Service request created successfully: $srId");
      return srId;
    } catch (e) {
      print("❌ Error creating service request: $e");
      throw Exception('Failed to create service request: $e');
    }
  }

  /// Get all service requests
  static Future<List<Map<String, dynamic>>> getAllServiceRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('serviceRequests')
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> serviceRequests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${serviceRequests.length} service requests.");
      return serviceRequests;
    } catch (e) {
      print("❌ Error fetching service requests: $e");
      return [];
    }
  }

  /// Get service requests by status
  static Future<List<Map<String, dynamic>>> getServiceRequestsByStatus(String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('serviceRequests')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> serviceRequests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${serviceRequests.length} service requests with status: $status");
      return serviceRequests;
    } catch (e) {
      print("❌ Error fetching service requests by status: $e");
      return [];
    }
  }

  /// Get service requests by action status
  static Future<List<Map<String, dynamic>>> getServiceRequestsByActionStatus(bool isAction) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('serviceRequests')
          .where('isAction', isEqualTo: isAction)
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> serviceRequests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${serviceRequests.length} service requests with isAction: $isAction");
      return serviceRequests;
    } catch (e) {
      print("❌ Error fetching service requests by action status: $e");
      return [];
    }
  }

  /// Get available technicians for assignment
  static Future<List<Map<String, dynamic>>> getAvailableTechnicians() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('technicians')
          .get();
      
      List<Map<String, dynamic>> technicians = snapshot.docs.map((doc) => {
        'empId': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${technicians.length} available technicians.");
      return technicians;
    } catch (e) {
      print("❌ Error fetching available technicians: $e");
      return [];
    }
  }

  /// Get service request by ID
  static Future<Map<String, dynamic>?> getServiceRequestById(String serviceRequestId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('serviceRequests')
          .doc(serviceRequestId)
          .get();
      
      if (doc.exists) {
        print("✅ Service request found: $serviceRequestId");
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      } else {
        print("❌ Service request not found: $serviceRequestId");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching service request by ID: $e");
      return null;
    }
  }

  /// Delete service request by ID
  static Future<bool> deleteServiceRequest(String serviceRequestId) async {
    try {
      // Get the service request data first for notification
      DocumentSnapshot doc = await _firestore
          .collection('serviceRequests')
          .doc(serviceRequestId)
          .get();
      
      if (!doc.exists) {
        print("❌ Service request not found for deletion: $serviceRequestId");
        return false;
      }

      final serviceRequestData = doc.data() as Map<String, dynamic>;
      final srId = serviceRequestData['serviceDetails']?['srId'] ?? serviceRequestData['srId'] ?? 'Unknown';
      final customerName = serviceRequestData['customerDetails']?['name'] ?? 'Unknown Customer';

      // Delete the service request
      await _firestore
          .collection('serviceRequests')
          .doc(serviceRequestId)
          .delete();
      
      // Create notification for admin when service request is deleted
      await _createAdminDeviceNotification(
        'Service Request Deleted', 
        'Service request $srId for customer $customerName has been deleted successfully.'
      );
      
      print("✅ Service request deleted successfully: $serviceRequestId");
      return true;
    } catch (e) {
      print("❌ Error deleting service request: $e");
      return false;
    }
  }

  /// Update service request
  static Future<bool> updateServiceRequest({
    required String srId,
    String? newAssignedTo,
    String? status,
    String? comments,
    DateTime? newAddressByDate,
    String? requestType,
    String? assignedTechnician,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update service details if provided
      if (newAssignedTo != null) {
        // Get the current assigned technician before updating
        final currentDoc = await _firestore.collection('serviceRequests').doc(srId).get();
        if (currentDoc.exists) {
          final currentData = currentDoc.data() as Map<String, dynamic>;
          final serviceDetails = currentData['serviceDetails'] as Map<String, dynamic>?;
          final currentAssignedTo = serviceDetails?['assignedTo'];
          
          // Store the original assigned technician if this is a reassignment
          if (currentAssignedTo != null && currentAssignedTo != newAssignedTo) {
            updateData['serviceDetails.originalAssignedTo'] = currentAssignedTo;
          }
        }
        
        updateData['serviceDetails.assignedTo'] = newAssignedTo;
        updateData['serviceDetails.reassignedAt'] = FieldValue.serverTimestamp();
      }
      
      if (status != null) {
        updateData['status'] = status;
        // If status is being reset to pending (reassignment), set isAction to false
        if (status == 'pending') {
          updateData['isAction'] = false;
        }
      }

      if (comments != null) {
        updateData['serviceDetails.comments'] = comments;
      }

      if (newAddressByDate != null) {
        updateData['serviceDetails.addressByDate'] = Timestamp.fromDate(newAddressByDate);
      }

      if (requestType != null) {
        updateData['serviceDetails.requestType'] = requestType;
      }
      
      if (assignedTechnician != null) {
        updateData['serviceDetails.assignedTechnician'] = assignedTechnician;
      }

      // Update the document
      await _firestore.collection('serviceRequests').doc(srId).update(updateData);
      
      // Create notification for the newly assigned technician
      if (newAssignedTo != null) {
        await _createAssignmentNotification(srId, newAssignedTo, isReassignment: true);
      }
      
      // Create notification for admin when service request is updated
      await _createAdminUpdateNotification(srId, status, newAssignedTo, assignedTechnician);

      print("✅ Service request updated successfully: $srId");
      return true;
    } catch (e) {
      print("❌ Error updating service request: $e");
      throw Exception('Failed to update service request: $e');
    }
  }

  /// Create notification for technician assignment
  static Future<void> _createAssignmentNotification(
    String srId, 
    String technicianEmpId, 
    {bool isReassignment = false}
  ) async {
    try {
      // Get technician details
      QuerySnapshot techQuery = await _firestore
          .collection('technicians')
          .where('employeeId', isEqualTo: technicianEmpId)
          .limit(1)
          .get();

      if (techQuery.docs.isNotEmpty) {
        String technicianUid = techQuery.docs.first.id;
        
        // Create notification document
        await _firestore.collection('notifications').add({
          'recipientId': technicianUid,
          'userType': 'technician',
          'title': isReassignment 
              ? 'Service Request Reassigned'
              : 'New Service Request Assigned',
          'message': isReassignment 
              ? 'You have been reassigned to service request: $srId'
              : 'You have been assigned a new service request: $srId',
          'type': 'service_assignment',
          'serviceRequestId': srId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("✅ Notification created for technician: $technicianEmpId");
      }
    } catch (e) {
      print("❌ Error creating notification: $e");
    }
  }

  /// Create notification for admin when service request is created
  static Future<void> _createAdminNotification(
    String srId, 
    Map<String, dynamic> serviceDetails
  ) async {
    try {
      print("🔔 Creating admin notification for SR: $srId");
      
      // Get current admin user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No current user found for admin notification");
        return;
      }

      // Get admin details
      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        // Create notification document for admin with nested data structure
        DocumentReference notificationRef = await _firestore.collection('notifications').add({
          'createdAt': FieldValue.serverTimestamp(),
          'data': {
              'srId': srId,
          },
            'title': 'Service Request Created',
            'message': 'Service request $srId has been created successfully. ${serviceDetails['assignedTechnician'] != null ? 'Assigned to: ${serviceDetails['assignedTechnician']}' : 'No technician assigned yet.'}',
            'type': 'service_request_created',
            'isRead': false,
            'isActioned': false,
            'recipientRole': 'admin',
            'senderId': user.uid,
            'senderName': 'System',
          
        });

        print("✅ Notification created for admin: ${user.uid} with ID: ${notificationRef.id}");
      } else {
        print("❌ Admin document not found for user: ${user.uid}");
      }
    } catch (e) {
      print("❌ Error creating admin notification: $e");
    }
  }

  /// Create notification for admin when technician accepts/rejects service request
  static Future<void> createTechnicianActionNotification({
    required String srId,
    required String technicianId,
    required String technicianName,
    required String action, // 'accepted', 'rejected', or 'completed'
    Map<String, dynamic>? serviceRequestData, // Optional: full service request data for details
  }) async {
    try {
      String title, message, type;
      
      // Get service request details for enhanced messages
      String customerName = 'Customer';
      String equipmentModel = 'Equipment';
      String location = '';
      
      if (serviceRequestData != null) {
        final customerDetails = serviceRequestData['customerDetails'] as Map<String, dynamic>?;
        final equipmentDetails = serviceRequestData['equipmentDetails'] as Map<String, dynamic>?;
        
        if (customerDetails != null) {
          customerName = customerDetails['name'] ?? customerDetails['customerName'] ?? 'Customer';
          location = customerDetails['city'] ?? '';
        }
        
        if (equipmentDetails != null) {
          equipmentModel = equipmentDetails['model'] ?? 'Equipment';
        }
        
        print("🔍 Service request data found: Customer=$customerName, Equipment=$equipmentModel, Location=$location");
      } else {
        print("⚠️ No service request data provided for notification");
      }
      
      switch (action) {
        case 'accepted':
          title = 'Service Request $srId Accepted';
          message = 'Technician $technicianName has accepted service request $srId for $customerName ($equipmentModel${location.isNotEmpty ? ' - $location' : ''}).';
          type = 'service_accepted';
          break;
        case 'rejected':
          title = 'Service Request $srId Rejected';
          message = 'Technician $technicianName has rejected service request $srId for $customerName ($equipmentModel${location.isNotEmpty ? ' - $location' : ''}). Please assign to another technician.';
          type = 'service_rejected';
          break;
        case 'completed':
          title = 'Service Request $srId Completed';
          message = 'Technician $technicianName has completed service request $srId for $customerName ($equipmentModel${location.isNotEmpty ? ' - $location' : ''}) successfully.';
          type = 'service_completed';
          break;
        default:
          title = 'Service Request $srId Updated';
          message = 'Service request $srId for $customerName ($equipmentModel${location.isNotEmpty ? ' - $location' : ''}) has been updated by $technicianName.';
          type = 'service_updated';
      }

      // Create notification document for admin with nested data structure
      DocumentReference notificationRef = await _firestore.collection('notifications').add({
        'createdAt': FieldValue.serverTimestamp(),
        'data': {
          'title': title,
          'message': message,
          'type': type,
          'srId': srId,
          'isRead': false,
          'recipientRole': 'admin',
          'senderId': technicianId,
          'senderName': technicianName,
          'technicianId': technicianId,
          'technicianName': technicianName,
          'pushNotificationSent': false, // Track if push notification was sent
          // Add service request details if available
          if (serviceRequestData != null) ...{
            'customerName': customerName,
            'equipmentModel': equipmentModel,
            'location': location,
            'serviceRequestDetails': serviceRequestData,
          },
        },
      });

      print("✅ ${action.toUpperCase()} notification created for admin: SR $srId by $technicianName");
      print("📱 Push notification will be triggered by Cloud Function for notification ID: ${notificationRef.id}");
      print("📋 Notification data: title='$title', type='$type', srId='$srId'");
      
    } catch (e) {
      print("❌ Error creating ${action} notification: $e");
    }
  }

  /// Create notification for admin access request
  static Future<void> createAdminAccessRequestNotification({
    required String technicianId,
    required String technicianName,
  }) async {
    try {
      // Create notification document for admin with correct structure
      await _firestore.collection('notifications').add({
        'createdAt': FieldValue.serverTimestamp(),
        'title': 'Admin Access Request',
        'message': 'Technician $technicianName is requesting admin access.',
        'type': 'admin_access_request',
        'recipientRole': 'admin',
        'senderId': technicianId,
        'senderName': technicianName,
        'isRead': false,
        'isActioned': false,
        'status': 'pending',
        'data': {
          'technicianId': technicianId,
          'technicianName': technicianName,
        },
      });

      print("✅ Admin access request notification created for: $technicianName");
    } catch (e) {
      print("❌ Error creating admin access request notification: $e");
    }
  }

  /// Test method to create a sample admin access request (for testing purposes)
  static Future<void> createTestAdminAccessRequest() async {
    try {
      await createAdminAccessRequestNotification(
        technicianId: 'test_technician_123',
        technicianName: 'Test Technician',
      );
      print("✅ Test admin access request created successfully");
    } catch (e) {
      print("❌ Error creating test admin access request: $e");
    }
  }

  /// Handle technician accept/reject/complete service request
  static Future<bool> handleTechnicianAction({
    required String srId,
    required String technicianId,
    required String technicianName,
    required String action, // 'accepted', 'rejected', or 'completed'
    String? comments,
  }) async {
    try {
      // Update service request status
      String status;
      switch (action) {
        case 'accepted':
          status = 'accepted';
          break;
        case 'rejected':
          status = 'rejected';
          break;
        case 'completed':
          status = 'completed';
          break;
        default:
          status = 'pending';
      }

      Map<String, dynamic> updateData = {
        'status': status,
        'isAction': true, // Set to true when technician takes action
        'updatedAt': FieldValue.serverTimestamp(),
        'serviceDetails.technicianAction': action,
        'serviceDetails.technicianActionAt': FieldValue.serverTimestamp(),
        'serviceDetails.technicianId': technicianId,
        'serviceDetails.technicianName': technicianName,
      };

      if (comments != null && comments.isNotEmpty) {
        updateData['serviceDetails.technicianComments'] = comments;
      }

      // Update the service request
      await _firestore.collection('serviceRequests').doc(srId).update(updateData);

      // Get service request data for enhanced notification
      Map<String, dynamic>? serviceRequestData = await getServiceRequestById(srId);
      
      // Create notification for admin
      await createTechnicianActionNotification(
        srId: srId,
        technicianId: technicianId,
        technicianName: technicianName,
        action: action,
        serviceRequestData: serviceRequestData,
      );

      print("✅ Service request $srId ${action} by technician $technicianName");
      return true;
    } catch (e) {
      print("❌ Error handling technician action: $e");
      return false;
    }
  }

  /// Update service request status and create notification
  static Future<bool> updateServiceRequestStatus({
    required String srId,
    required String status, // 'pending', 'accepted', 'rejected', 'completed'
    required String technicianId,
    required String technicianName,
    String? comments,
  }) async {
    try {
      // Update service request status
      Map<String, dynamic> updateData = {
        'status': status,
        'isAction': true, // Set to true when technician takes action
        'updatedAt': FieldValue.serverTimestamp(),
        'serviceDetails.technicianAction': status,
        'serviceDetails.technicianActionAt': FieldValue.serverTimestamp(),
        'serviceDetails.technicianId': technicianId,
        'serviceDetails.technicianName': technicianName,
      };

      if (comments != null && comments.isNotEmpty) {
        updateData['serviceDetails.technicianComments'] = comments;
      }

      // Update the service request
      await _firestore.collection('serviceRequests').doc(srId).update(updateData);

      // Create notification for admin based on status
      String action;
      switch (status) {
        case 'accepted':
          action = 'accepted';
          break;
        case 'rejected':
          action = 'rejected';
          break;
        case 'completed':
          action = 'completed';
          break;
        default:
          action = 'updated';
      }

      // Get service request data for enhanced notification
      Map<String, dynamic>? serviceRequestData = await getServiceRequestById(srId);
      
      await createTechnicianActionNotification(
        srId: srId,
        technicianId: technicianId,
        technicianName: technicianName,
        action: action,
        serviceRequestData: serviceRequestData,
      );

      print("✅ Service request $srId status updated to $status by $technicianName");
      return true;
    } catch (e) {
      print("❌ Error updating service request status: $e");
      return false;
    }
  }

  /// Get technician action details from service request
  static Map<String, dynamic>? getTechnicianAction(Map<String, dynamic> serviceRequest) {
    try {
      final serviceDetails = serviceRequest['serviceDetails'] as Map<String, dynamic>?;
      if (serviceDetails == null) return null;

      final technicianAction = serviceDetails['technicianAction'];
      if (technicianAction == null) return null;

      return {
        'action': technicianAction,
        'technicianId': serviceDetails['technicianId'],
        'technicianName': serviceDetails['technicianName'],
        'actionAt': serviceDetails['technicianActionAt'],
        'comments': serviceDetails['technicianComments'],
      };
    } catch (e) {
      print("❌ Error getting technician action: $e");
      return null;
    }
  }

  /// Create notification for admin when service request is updated
  static Future<void> _createAdminUpdateNotification(
    String srId, 
    String? status, 
    String? newAssignedTo, 
    String? assignedTechnician
  ) async {
    try {
      // Get current admin user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No current user found for admin update notification");
        return;
      }

      // Get admin details
      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        String message = 'Service request $srId has been updated.';
        
        if (status != null) {
          message += ' Status changed to: ${status.replaceAll('_', ' ').toUpperCase()}.';
        }
        
        if (newAssignedTo != null && assignedTechnician != null) {
          message += ' Reassigned to: $assignedTechnician.';
        }

        // Create notification document for admin with nested data structure
        await _firestore.collection('notifications').add({
          'createdAt': FieldValue.serverTimestamp(),
          
            'title': 'Service Request Updated',
            'message': message,
            'type': 'service_request_updated',
            'data':{
            'srId': srId,
            },
            'isRead': false,
            'recipientRole': 'admin',
            'senderId': user.uid,
            'senderName': 'System',
          
        });

        print("✅ Update notification created for admin: ${user.uid}");
      } else {
        print("❌ Admin document not found for user: ${user.uid}");
      }
    } catch (e) {
      print("❌ Error creating admin update notification: $e");
    }
  }

  /// Create notification for admin for device operations
  static Future<void> _createAdminDeviceNotification(
    String title, 
    String message
  ) async {
    try {
      // Get current admin user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No current user found for admin device notification");
        return;
      }

      // Get admin details
      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        // Create notification document for admin
        await _firestore.collection('notifications').add({
          'userId': user.uid,
          'userType': 'admin',
          'title': title,
          'message': message,
          'type': 'device_operation',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("✅ Device notification created for admin: ${user.uid}");
      } else {
        print("❌ Admin document not found for user: ${user.uid}");
      }
    } catch (e) {
      print("❌ Error creating admin device notification: $e");
    }
  }

  /// Get notifications for a user
  static Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("❌ Error getting notifications: $e");
      return [];
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Error marking notification as read: $e");
    }
  }

  /// Create a test notification for debugging
  static Future<void> createTestNotification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No current user found for test notification");
        return;
      }

      await _firestore.collection('notifications').add({
        'userId': user.uid,
        'userType': 'admin',
        'title': 'Test Notification',
        'message': 'This is a test notification to verify the notification system is working.',
        'type': 'test',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Test notification created for admin: ${user.uid}");
    } catch (e) {
      print("❌ Error creating test notification: $e");
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("❌ Error getting unread notification count: $e");
      return 0;
    }
  }

  /// Update the existing createServiceRequest method to include notification
  /// 
  /// 
  /// 
   static Future<Map<String, dynamic>?> getServiceHistoryBySrId(String srId) async {
    try {
      // Query the serviceHistory collection using srId as document ID
      DocumentSnapshot doc = await _firestore
          .collection('serviceHistory')
          .doc(srId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Add document ID to the data for reference
        data['id'] = doc.id;
        
        return data;
      } else {
        // Document doesn't exist
        return null;
      }
    } catch (e) {
      print('Error fetching service history for SR ID $srId: $e');
      throw Exception('Failed to fetch service history: $e');
    }
  }

  /// Alternative method if you're using srNumber field instead of document ID
  /// Get service history by SR Number field
  static Future<Map<String, dynamic>?> getServiceHistoryBySrNumber(String srNumber) async {
    try {
      // Query the serviceHistory collection using srNumber field
      QuerySnapshot querySnapshot = await _firestore
          .collection('serviceHistory')
          .where('srNumber', isEqualTo: srNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Add document ID to the data for reference
        data['id'] = doc.id;
        
        return data;
      } else {
        // No document found with this srNumber
        return null;
      }
    } catch (e) {
      print('Error fetching service history for SR Number $srNumber: $e');
      throw Exception('Failed to fetch service history: $e');
    }
  }

  /// Get all service history records for a specific AWG serial number
  /// Useful for viewing complete service history of a device
  static Future<List<Map<String, dynamic>>> getServiceHistoryByAwgSerial(String awgSerialNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('serviceHistory')
          .where('awgSerialNumber', isEqualTo: awgSerialNumber)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> serviceHistoryList = [];
      
      for (DocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        serviceHistoryList.add(data);
      }

      return serviceHistoryList;
    } catch (e) {
      print('Error fetching service history for AWG Serial $awgSerialNumber: $e');
      throw Exception('Failed to fetch service history: $e');
    }
  }

  /// Get service history with pagination
  /// Useful for loading large datasets efficiently
  static Future<List<Map<String, dynamic>>> getServiceHistoryPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? status,
    String? technician,
  }) async {
    try {
      Query query = _firestore
          .collection('serviceHistory')
          .orderBy('timestamp', descending: true);

      // Add filters if provided
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }
      
      if (technician != null && technician.isNotEmpty) {
        query = query.where('technician', isEqualTo: technician);
      }

      // Add pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      query = query.limit(limit);

      QuerySnapshot querySnapshot = await query.get();
      
      List<Map<String, dynamic>> serviceHistoryList = [];
      
      for (DocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        serviceHistoryList.add(data);
      }

      return serviceHistoryList;
    } catch (e) {
      print('Error fetching paginated service history: $e');
      throw Exception('Failed to fetch service history: $e');
    }
  }

  /// Get service statistics
  /// Returns counts and analytics for service history
  static Future<Map<String, dynamic>> getServiceHistoryStats() async {
    try {
      // Get all service history records
      QuerySnapshot allDocs = await _firestore
          .collection('serviceHistory')
          .get();

      Map<String, int> statusCounts = {};
      Map<String, int> technicianCounts = {};
      Map<String, int> issueTypeCounts = {};
      int totalServices = allDocs.docs.length;

      for (DocumentSnapshot doc in allDocs.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Count by status
        String status = data['status'] ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        
        // Count by technician
        String technician = data['technician'] ?? 'unknown';
        technicianCounts[technician] = (technicianCounts[technician] ?? 0) + 1;
        
        // Count by issue type
        String issueType = data['issueType'] ?? 'unknown';
        issueTypeCounts[issueType] = (issueTypeCounts[issueType] ?? 0) + 1;
      }

      return {
        'totalServices': totalServices,
        'statusCounts': statusCounts,
        'technicianCounts': technicianCounts,
        'issueTypeCounts': issueTypeCounts,
      };
    } catch (e) {
      print('Error fetching service history stats: $e');
      throw Exception('Failed to fetch service history statistics: $e');
    }
  }

  /// Update service history record
  /// Used for updating existing service records
  static Future<bool> updateServiceHistory(String srId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('serviceHistory')
          .doc(srId)
          .update(updates);
      
      return true;
    } catch (e) {
      print('Error updating service history for SR ID $srId: $e');
      throw Exception('Failed to update service history: $e');
    }
  }

  /// Delete service history record
  /// Used for removing service records (use with caution)
  static Future<bool> deleteServiceHistory(String srId) async {
    try {
      await _firestore
          .collection('serviceHistory')
          .doc(srId)
          .delete();
      
      return true;
    } catch (e) {
      print('Error deleting service history for SR ID $srId: $e');
      throw Exception('Failed to delete service history: $e');
    }
  }

  /// Create new service history record
  /// Used when a service is completed
  static Future<bool> createServiceHistory(String srId, Map<String, dynamic> serviceData) async {
    try {
      await _firestore
          .collection('serviceHistory')
          .doc(srId)
          .set(serviceData);
      
      return true;
    } catch (e) {
      print('Error creating service history for SR ID $srId: $e');
      throw Exception('Failed to create service history: $e');
    }
  }

  // ============== ADMIN ACCESS REQUEST MANAGEMENT METHODS ==============

  /// Create an admin access request notification
  static Future<void> createAdminAccessRequest({
    required String technicianId,
    required String technicianName,
    String? srId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'senderId': technicianId,
        'senderName': technicianName,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'recipientRole': 'admin',
        'type': 'admin_access_request',
        'title': 'Admin Access Request',
        'message': 'Technician $technicianName is requesting admin access.',
        'status': 'pending',
        'isRead': false,
        'isActioned': false,
        'srId': srId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print("✅ Admin access request created for technician: $technicianName");
    } catch (e) {
      print("❌ Error creating admin access request: $e");
      throw Exception('Failed to create admin access request: $e');
    }
  }

  /// Get all admin access requests
  static Future<List<Map<String, dynamic>>> getAllAdminAccessRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .where('type', isEqualTo: 'admin_access_request')
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> requests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${requests.length} admin access requests.");
      return requests;
    } catch (e) {
      print("❌ Error fetching admin access requests: $e");
      return [];
    }
  }

  /// Get pending admin access requests
  static Future<List<Map<String, dynamic>>> getPendingAdminAccessRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .where('type', isEqualTo: 'admin_access_request')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> requests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${requests.length} pending admin access requests.");
      return requests;
    } catch (e) {
      print("❌ Error fetching pending admin access requests: $e");
      return [];
    }
  }

  /// Get unread admin access requests
  static Future<List<Map<String, dynamic>>> getUnreadAdminAccessRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .where('type', isEqualTo: 'admin_access_request')
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> requests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      
      print("✅ Fetched ${requests.length} unread admin access requests.");
      return requests;
    } catch (e) {
      print("❌ Error fetching unread admin access requests: $e");
      return [];
    }
  }

  /// Approve admin access request
  static Future<bool> approveAdminAccessRequest({
    required String notificationId,
    required String technicianId,
    required String technicianName,
    required String adminUid,
    required String adminName,
  }) async {
    try {
      // Update notification status at root level
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': 'approved',
        'isRead': true,
        'isActioned': true,
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminUid,
        'processedByName': adminName,
      });

      // Create promotion request notification for technician
      await _firestore.collection('notifications').add({
        'senderId': adminUid,
        'senderName': adminName,
        'recipientRole': 'technician',
        'type': 'admin_promotion_request',
        'title': 'Admin Promotion Offered',
        'message': 'You have been offered admin access by $adminName. Accept to become an admin or reject to remain as technician.',
        'status': 'pending',
        'isRead': false,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'adminUid': adminUid,
        'adminName': adminName,
        'originalRequestId': notificationId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send push notification to technician
      await _sendPromotionPushNotification(
        technicianId: technicianId,
        technicianName: technicianName,
        adminName: adminName,
      );

      print("✅ Admin promotion request sent to technician: $technicianName");
      return true;
    } catch (e) {
      print("❌ Error approving admin access request: $e");
      return false;
    }
  }

  /// Reject admin access request
  static Future<bool> rejectAdminAccessRequest({
    required String notificationId,
    required String technicianId,
    required String technicianName,
    required String adminUid,
    required String adminName,
    String? reason,
  }) async {
    try {
      // Update notification status at root level
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': 'rejected',
        'isRead': true,
        'isActioned': true,
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminUid,
        'processedByName': adminName,
        'rejectionReason': reason,
      });

      // Update technician document to deny admin access
      await _firestore.collection('technicians').doc(technicianId).update({
        'hasAdminAccess': false,
        'adminAccessDeniedAt': FieldValue.serverTimestamp(),
        'adminAccessDeniedBy': adminUid,
        'adminAccessDeniedByName': adminName,
        'adminAccessStatus': 'rejected',
        'adminAccessRejectionReason': reason,
      });

      // Create notification for technician about rejection
      await _firestore.collection('notifications').add({
        'senderId': adminUid,
        'senderName': adminName,
        'recipientRole': 'technician',
        'type': 'admin_access_response',
        'title': 'Admin Access Rejected',
        'message': reason != null 
            ? 'Your admin access request has been rejected by $adminName. Reason: $reason'
            : 'Your admin access request has been rejected by $adminName.',
        'status': 'rejected',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Admin access rejected for technician: $technicianName");
      return true;
    } catch (e) {
      print("❌ Error rejecting admin access request: $e");
      return false;
    }
  }

  /// Mark admin access request as read
  static Future<bool> markAdminAccessRequestAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      
      print("✅ Admin access request marked as read: $notificationId");
      return true;
    } catch (e) {
      print("❌ Error marking admin access request as read: $e");
      return false;
    }
  }

  /// Get admin access request by ID
  static Future<Map<String, dynamic>?> getAdminAccessRequestById(String notificationId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();
      
      if (doc.exists) {
        print("✅ Admin access request found: $notificationId");
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      } else {
        print("⚠️ No admin access request found with ID: $notificationId");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching admin access request: $e");
      return null;
    }
  }



  /// Get admin access request count
  static Future<Map<String, int>> getAdminAccessRequestCounts() async {
    try {
      QuerySnapshot allSnapshot = await _firestore
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .where('type', isEqualTo: 'admin_access_request')
          .get();

      QuerySnapshot pendingSnapshot = await _firestore
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .where('type', isEqualTo: 'admin_access_request')
          .where('status', isEqualTo: 'pending')
          .get();

      QuerySnapshot unreadSnapshot = await _firestore
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .where('type', isEqualTo: 'admin_access_request')
          .where('isRead', isEqualTo: false)
          .get();

      return {
        'total': allSnapshot.docs.length,
        'pending': pendingSnapshot.docs.length,
        'unread': unreadSnapshot.docs.length,
      };
    } catch (e) {
      print("❌ Error getting admin access request counts: $e");
      return {
        'total': 0,
        'pending': 0,
        'unread': 0,
      };
    }
  }

  /// Send push notification for admin promotion
  static Future<void> _sendPromotionPushNotification({
    required String technicianId,
    required String technicianName,
    required String adminName,
  }) async {
    try {
      // Get technician's FCM token
      final technicianDoc = await _firestore.collection('technicians').doc(technicianId).get();
      if (technicianDoc.exists) {
        final data = technicianDoc.data() as Map<String, dynamic>;
        final fcmToken = data['fcmToken'];
        
        if (fcmToken != null) {
          // Send push notification
          await _firestore.collection('pushNotifications').add({
            'token': fcmToken,
            'title': 'Admin Promotion Offered',
            'body': 'You have been offered admin access by $adminName. Tap to view details.',
            'data': {
              'type': 'admin_promotion_request',
              'technicianId': technicianId,
              'adminName': adminName,
            },
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          print("✅ Push notification sent to technician: $technicianName");
        }
      }
    } catch (e) {
      print("❌ Error sending push notification: $e");
    }
  }

  /// Technician accepts admin promotion
  static Future<bool> acceptAdminPromotion({
    required String notificationId,
    required String technicianId,
    required String technicianName,
    required String adminUid,
    required String adminName,
  }) async {
    try {
      // Get technician data
      final technicianDoc = await _firestore.collection('technicians').doc(technicianId).get();
      if (!technicianDoc.exists) {
        throw Exception('Technician not found');
      }
      
      final technicianData = technicianDoc.data() as Map<String, dynamic>;
      
      // Create admin account with technician data
      await _firestore.collection('admins').doc(technicianId).set({
        'fullName': technicianData['fullName'] ?? technicianName,
        'email': technicianData['email'] ?? '',
        'mobileNumber': technicianData['mobileNumber'] ?? '',
        'employeeId': technicianData['employeeId'] ?? '',
        'designation': technicianData['designation'] ?? 'Admin',
        'department': technicianData['department'] ?? '',
        'profileImageUrl': technicianData['profileImageUrl'] ?? '',
        'uid': technicianId,
        'isProfileComplete': true,
        'hasAdminAccess': true,
        'adminAccessGrantedAt': FieldValue.serverTimestamp(),
        'adminAccessGrantedBy': adminUid,
        'adminAccessGrantedByName': adminName,
        'adminAccessStatus': 'accepted',
        'promotedFromTechnician': true,
        'originalTechnicianData': technicianData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update technician document
      await _firestore.collection('technicians').doc(technicianId).update({
        'hasAdminAccess': true,
        'adminAccessGrantedAt': FieldValue.serverTimestamp(),
        'adminAccessGrantedBy': adminUid,
        'adminAccessGrantedByName': adminName,
        'adminAccessStatus': 'accepted',
        'isPromotedToAdmin': true,
        'promotedAt': FieldValue.serverTimestamp(),
      });

      // Update promotion notification
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': 'accepted',
        'isRead': true,
        'isActioned': true,
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': technicianId,
        'processedByName': technicianName,
      });

      // Create acceptance notification for admin
      await _firestore.collection('notifications').add({
        'senderId': technicianId,
        'senderName': technicianName,
        'recipientRole': 'admin',
        'type': 'admin_promotion_response',
        'title': 'Admin Promotion Accepted',
        'message': '$technicianName has accepted the admin promotion offer.',
        'status': 'accepted',
        'isRead': false,
        'adminUid': adminUid,
        'adminName': adminName,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send push notification to admin
      await _sendPromotionAcceptancePushNotification(
        adminUid: adminUid,
        technicianName: technicianName,
      );

      print("✅ Admin promotion accepted by technician: $technicianName");
      return true;
    } catch (e) {
      print("❌ Error accepting admin promotion: $e");
      return false;
    }
  }

  /// Technician rejects admin promotion
  static Future<bool> rejectAdminPromotion({
    required String notificationId,
    required String technicianId,
    required String technicianName,
    required String adminUid,
    required String adminName,
    String? reason,
  }) async {
    try {
      // Update technician document
      await _firestore.collection('technicians').doc(technicianId).update({
        'hasAdminAccess': false,
        'adminAccessDeniedAt': FieldValue.serverTimestamp(),
        'adminAccessDeniedBy': technicianId,
        'adminAccessDeniedByName': technicianName,
        'adminAccessStatus': 'rejected_by_technician',
        'adminAccessRejectionReason': reason,
      });

      // Update promotion notification
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': 'rejected',
        'isRead': true,
        'isActioned': true,
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': technicianId,
        'processedByName': technicianName,
        'rejectionReason': reason,
      });

      // Create rejection notification for admin
      await _firestore.collection('notifications').add({
        'senderId': technicianId,
        'senderName': technicianName,
        'recipientRole': 'admin',
        'type': 'admin_promotion_response',
        'title': 'Admin Promotion Rejected',
        'message': reason != null 
            ? '$technicianName has rejected the admin promotion offer. Reason: $reason'
            : '$technicianName has rejected the admin promotion offer.',
        'status': 'rejected',
        'isRead': false,
        'adminUid': adminUid,
        'adminName': adminName,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'rejectionReason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send push notification to admin
      await _sendPromotionRejectionPushNotification(
        adminUid: adminUid,
        technicianName: technicianName,
      );

      print("✅ Admin promotion rejected by technician: $technicianName");
      return true;
    } catch (e) {
      print("❌ Error rejecting admin promotion: $e");
      return false;
    }
  }

  /// Send push notification for promotion acceptance
  static Future<void> _sendPromotionAcceptancePushNotification({
    required String adminUid,
    required String technicianName,
  }) async {
    try {
      // Get admin's FCM token
      final adminDoc = await _firestore.collection('admins').doc(adminUid).get();
      if (adminDoc.exists) {
        final data = adminDoc.data() as Map<String, dynamic>;
        final fcmToken = data['fcmToken'];
        
        if (fcmToken != null) {
          await _firestore.collection('pushNotifications').add({
            'token': fcmToken,
            'title': 'Promotion Accepted',
            'body': '$technicianName has accepted the admin promotion offer.',
            'data': {
              'type': 'admin_promotion_response',
              'status': 'accepted',
              'technicianName': technicianName,
            },
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print("❌ Error sending acceptance push notification: $e");
    }
  }

  /// Send push notification for promotion rejection
  static Future<void> _sendPromotionRejectionPushNotification({
    required String adminUid,
    required String technicianName,
  }) async {
    try {
      // Get admin's FCM token
      final adminDoc = await _firestore.collection('admins').doc(adminUid).get();
      if (adminDoc.exists) {
        final data = adminDoc.data() as Map<String, dynamic>;
        final fcmToken = data['fcmToken'];
        
        if (fcmToken != null) {
          await _firestore.collection('pushNotifications').add({
            'token': fcmToken,
            'title': 'Promotion Rejected',
            'body': '$technicianName has rejected the admin promotion offer.',
            'data': {
              'type': 'admin_promotion_response',
              'status': 'rejected',
              'technicianName': technicianName,
            },
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print("❌ Error sending rejection push notification: $e");
    }
  }


} 