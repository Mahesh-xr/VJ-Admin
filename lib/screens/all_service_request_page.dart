import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/screens/editSR.dart';
import 'package:vayujal/widgets/navigations/NormalAppBar.dart';
import 'package:vayujal/widgets/navigations/bottom_navigation.dart';
import 'package:vayujal/pages/service_details_page.dart';

class AllServiceRequestsPage extends StatefulWidget {
  const AllServiceRequestsPage({super.key});

  @override
  State<AllServiceRequestsPage> createState() => _AllServiceRequestsPageState();
}

class _AllServiceRequestsPageState extends State<AllServiceRequestsPage> {
  List<Map<String, dynamic>> _allServiceRequests = [];
  List<Map<String, dynamic>> _filteredServiceRequests = [];
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['All', 'Pending','In Progress', 'Delayed', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadServiceRequests();
    _loadTechnicians();
  }

  Future<void> _loadServiceRequests() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> serviceRequests = await AdminAction.getAllServiceRequests();
      if (mounted) {
      setState(() {
        _allServiceRequests = serviceRequests;
        _filteredServiceRequests = serviceRequests;
        _isLoading = false;
      });
      }
    } catch (e) {
      if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading service requests: $e'),
          backgroundColor: Colors.red,
        ),
      );
      }
    }
  }

  Future<void> _loadTechnicians() async {
    try {
      List<Map<String, dynamic>> techs = await AdminAction.getAllTechnicians();
      if (mounted) {
      setState(() {
        _technicians = techs;
      });
      }
    } catch (e) {
      print("Error loading technicians: $e");
    }
  }

  Map<String, dynamic>? _getTechnicianByEmpId(String? empId) {
    if (empId == null) return null;
    
    try {
      return _technicians.firstWhere(
        (tech) => tech['empId'] == empId,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  void _filterServiceRequests(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      if (filter == 'All') {
        _filteredServiceRequests = _allServiceRequests;
      } else {
        String statusFilter = _getStatusFromFilter(filter);
        _filteredServiceRequests = _allServiceRequests.where((sr) {
          String status = sr['serviceDetails']?['status'] ?? sr['status'] ?? 'pending';
          return status.toLowerCase() == statusFilter.toLowerCase();
        }).toList();
      }
      
      // Apply search filter if there's a search query
      if (_searchController.text.isNotEmpty) {
        _searchServiceRequests(_searchController.text);
      }
    });
  }

  String _getStatusFromFilter(String filter) {
    switch (filter) {
      case 'In Progress':
        return 'in_progress';
      case 'Pending':
        return 'pending';
      case 'Delayed':
        return 'delayed';
      case 'Completed':
        return 'completed';
      default:
        return 'pending';
    }
  }

  void _searchServiceRequests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterServiceRequests(_selectedFilter);
      } else {
        _filteredServiceRequests = _filteredServiceRequests.where((sr) {
          String srId = sr['serviceDetails']?['srId'] ?? sr['srId'] ?? '';
          String customerName = sr['customerDetails']?['name'] ?? '';
          String model = sr['equipmentDetails']?['model'] ?? '';
          
          return srId.toLowerCase().contains(query.toLowerCase()) ||
                 customerName.toLowerCase().contains(query.toLowerCase()) ||
                 model.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getDisplayStatus(Map<String, dynamic> serviceRequest) {
    String status = serviceRequest['status'] ?? 'pending';
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'delayed':
        return 'Delayed';
      case 'pending':
        return 'Pending';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    print('DEBUG: Getting color for status: $status');
    switch (status.toLowerCase()) {
      
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'delayed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime date;
      if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        date = timestamp.toDate();
      }
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Check if service request can be edited - FIXED VERSION
  bool _canEditServiceRequest(Map<String, dynamic> serviceRequest) {
    // Get status from both possible locations
    String status = serviceRequest['serviceDetails']?['status'] ?? serviceRequest['status'] ?? 'pending';
    
    // Debug print to see what status values we're getting
    print('DEBUG: Service Request Status: $status');
    
    // Allow editing for pending, in_progress, and delayed requests
    List<String> editableStatuses = ['pending', 'in_progress', 'delayed'];
    return editableStatuses.contains(status.toLowerCase());
  }

  // Show edit dialog
  void _showEditDialog(Map<String, dynamic> serviceRequest) {
    showDialog(
      context: context,
      builder: (context) => EditServiceRequestDialog(
        serviceRequest: serviceRequest,
        onUpdated: _loadServiceRequests, // Refresh the list after update
      ),
    );
  }

  // Show delete dialog
  void _showDeleteDialog(Map<String, dynamic> serviceRequest) {
    String srId = serviceRequest['serviceDetails']?['srId'] ?? serviceRequest['srId'] ?? 'Unknown';
    String customerName = serviceRequest['customerDetails']?['name'] ?? 'Unknown Customer';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Service Request'),
          content: Text('Are you sure you want to delete service request $srId for customer $customerName?\n\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteServiceRequest(serviceRequest);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteServiceRequest(Map<String, dynamic> serviceRequest) async {
    try {
      String serviceRequestId = serviceRequest['id'] ?? '';
      String srId = serviceRequest['serviceDetails']?['srId'] ?? serviceRequest['srId'] ?? 'Unknown';

      if (serviceRequestId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Service request ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting service request...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(serviceRequestId)
          .delete();

      // Remove from local list
      setState(() {
        _allServiceRequests.removeWhere((sr) => sr['id'] == serviceRequestId);
        _filteredServiceRequests.removeWhere((sr) => sr['id'] == serviceRequestId);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service request $srId deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting service request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: Normalappbar(
        title: 'Services',
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                String option = _filterOptions[index];
                bool isSelected = _selectedFilter == option;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _filterServiceRequests(option);
                      }
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey[200],
                  ),
                );
              },
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search service requests...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _searchServiceRequests,
            ),
          ),
          
          // Service Requests List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServiceRequests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No service requests found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filter criteria',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadServiceRequests,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredServiceRequests.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> serviceRequest = _filteredServiceRequests[index];
                            
                            String srId = serviceRequest['serviceDetails']?['srId'] ?? serviceRequest['srId'] ?? 'N/A';
                            String customerName = serviceRequest['customerDetails']?['name'] ?? 'Unknown Customer';
                            String model = serviceRequest['equipmentDetails']?['model'] ?? 'Unknown Model';
                            String requestType = serviceRequest['serviceDetails']?['requestType'] ?? 'General Service';
                            String assignedDate = _formatDate(serviceRequest['serviceDetails']?['assignedDate'] ?? serviceRequest['createdAt']);
                            String status = _getDisplayStatus(serviceRequest);  
                            String serviceStatus =  serviceRequest['status'];
                            String assignedTo = serviceRequest['serviceDetails']?['assignedTechnician'] ?? 'Unassigned';
                            String assignedToEmpId = serviceRequest['serviceDetails']?['assignedTo'];
                            Map<String, dynamic>? technicianData = _getTechnicianByEmpId(assignedToEmpId);
                            String addressByDate = _formatDate(serviceRequest['serviceDetails']?['addressByDate'] ?? 'N/A');
                            bool canEdit = _canEditServiceRequest(serviceRequest);
                            
                            // Debug print to see the edit status
                            print('DEBUG: SR $srId - canEdit: $canEdit, status: ${serviceRequest['status']}, serviceDetails status: ${serviceRequest['serviceDetails']?['status']}');
                            
                         return Card(
  color: Colors.grey.shade100,
  margin: const EdgeInsets.only(bottom: 12),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceDetailsPage(
            serviceRequestId: srId,
          ),
        ),
      );
    },
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Request ID, Status, and Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  srId,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(serviceStatus),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(serviceStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showEditDialog(serviceRequest),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: canEdit 
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: canEdit ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showDeleteDialog(serviceRequest),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Customer and Model
          Text(
            '$customerName - $model',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Request Type and Acceptance Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                requestType.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              // Acceptance Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getAcceptanceStatusColor(_getAcceptanceStatus(serviceRequest)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getAcceptanceStatusColor(_getAcceptanceStatus(serviceRequest)),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getAcceptanceStatus(serviceRequest),
                  style: TextStyle(
                    color: _getAcceptanceStatusColor(_getAcceptanceStatus(serviceRequest)),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          // Technician with Profile Icon
          if (assignedTo != 'Unassigned') ...[
            Row(
              children: [
                // Technician Profile Icon
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: technicianData != null && 
                    technicianData['profileImageUrl'] != null && 
                    technicianData['profileImageUrl'] != 'sample' && 
                    technicianData['profileImageUrl'].isNotEmpty
                      ? NetworkImage(technicianData['profileImageUrl'])
                      : null,
                  child: technicianData == null || 
                    technicianData['profileImageUrl'] == null || 
                    technicianData['profileImageUrl'] == 'sample' || 
                    technicianData['profileImageUrl'].isEmpty
                      ? Icon(Icons.person, color: Colors.grey[600], size: 12)
                      : null,
                ),
                const SizedBox(width: 8),
                // Technician Name
                Expanded(
                  child: Text(
                    'Technician: $assignedTo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Technician: Unassigned',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],

          const SizedBox(height: 4),
          
          // Assigned Date
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Assigned: $assignedDate',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
               
            ],
          ),
       Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Address By: $addressByDate',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
               
            ],
          ),
        ],
      ),
    ),
  ),
);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation( 
        currentIndex: 3, // 'Services' tab index
        onTap: (currentIndex) => BottomNavigation.navigateTo(currentIndex, context),
      ),
    );

  
  }
  Color _getAcceptanceStatusColor(String acceptanceStatus) {
  switch (acceptanceStatus.toLowerCase()) {
    case 'accepted':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    case 'no response':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

String _getAcceptanceStatus(Map<String, dynamic> serviceRequest) {
  // Check if isAccepted field exists and its value
  if (serviceRequest.containsKey('isAccepted')) {
    bool isAccepted = serviceRequest['isAccepted'] ?? false;
    return isAccepted ? 'Accepted' : 'Rejected';
  }
  return 'No Response';
}
}


// Add this method to get acceptance status display text


// Add this method to get acceptance status color


// Updated Card widget in your ListView.builder itemBuilder
