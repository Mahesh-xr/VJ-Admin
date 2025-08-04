import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/services/local_notification_service.dart';

class EditServiceRequestDialog extends StatefulWidget {
  final Map<String, dynamic> serviceRequest;
  final VoidCallback onUpdated;

  const EditServiceRequestDialog({
    super.key,
    required this.serviceRequest,
    required this.onUpdated,
  });

  @override
  State<EditServiceRequestDialog> createState() => _EditServiceRequestDialogState();
}

class _EditServiceRequestDialogState extends State<EditServiceRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoadingTechnicians = true;
  bool _isUpdating = false;
  
  String? _selectedTechnician;
  String? _selectedStatus;
  DateTime? _selectedDate;
  String? _selectedRequestType;
  String? _selectedTechnicianName;

  final List<String> _statusOptions = ['pending', 'in_progress', 'completed', 'delayed'];
  final List<String> _requestTypeOptions = ['general_maintenance', 'customer_complaint'];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadTechnicians();
  }

  void _initializeData() {
    final serviceDetails = widget.serviceRequest['serviceDetails'] ?? {};
    
    // Initialize technician - will be validated when technicians are loaded
    _selectedTechnician = serviceDetails['assignedTo']?.toString();
    
    // Debug logging for initialization
    print('🔍 Initializing service request data:');
    print('🔍 Service details: $serviceDetails');
    print('🔍 Assigned to: $_selectedTechnician');
    print('🔍 Status: ${widget.serviceRequest['status']}');
    print('🔍 Request type: ${serviceDetails['requestType']}');
    
    // Fix status initialization - ensure it's in the options list
    String? status = widget.serviceRequest['status'];
    _selectedStatus = _statusOptions.contains(status) ? status : 'pending';
    
    _commentsController.text = serviceDetails['comments'] ?? '';
    
    // Fix request type initialization - ensure it's in the options list
    String? requestType = serviceDetails['requestType'];
    _selectedRequestType = _requestTypeOptions.contains(requestType) 
        ? requestType 
        : 'general_maintenance';
    
    _selectedTechnicianName = serviceDetails['assignedTechnician'] ?? 'Unassigned';
    
    // Parse address by date
    if (serviceDetails['addressByDate'] != null) {
      try {
        _selectedDate = serviceDetails['addressByDate'].toDate();
      } catch (e) {
        print('🔍 Error parsing address by date: $e');
        _selectedDate = DateTime.now().add(const Duration(days: 2));
      }
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 2));
    }
  }

  Future<void> _loadTechnicians() async {
    try {
      setState(() {
        _isLoadingTechnicians = true;
      });
      
      List<Map<String, dynamic>> techs = await AdminAction.getAllTechnicians();
      
      // Debug logging
      print('🔍 Loaded ${techs.length} technicians');
      for (int i = 0; i < techs.length; i++) {
        print('🔍 Technician $i: ${techs[i]['empId']} - ${techs[i]['name']}');
      }
      
      setState(() {
        _technicians = techs;
        _isLoadingTechnicians = false;
      });

      _updateTechnicianName();
      
      // Show warning if no technicians found
      if (techs.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ No technicians found. Please check technician data.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingTechnicians = false;
      });
      print("Error loading technicians: $e");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error loading technicians: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _getTechnicianNameById(String? empId) {
    if (empId == null) return 'Unassigned';
    
    final technician = _technicians.firstWhere(
      (tech) => tech['empId']?.toString() == empId?.toString(),
      orElse: () => {},
    );
    
    if (technician.isNotEmpty) {
      return '${technician['name']} - ${technician['empId']}';
    }
    return 'Unassigned';
  }

  String? _getValidTechnicianValue() {
    // If no technician is selected, return null
    if (_selectedTechnician == null) return null;
    
    // Debug logging
    print('🔍 Validating technician value: $_selectedTechnician');
    print('🔍 Available technicians: ${_technicians.map((t) => t['empId']?.toString()).toList()}');
    
    // Check if the selected technician exists in the technicians list
    final technicianExists = _technicians.any(
      (tech) => tech['empId']?.toString() == _selectedTechnician?.toString(),
    );
    
    print('🔍 Technician exists: $technicianExists');
    
    // If the technician doesn't exist in the list, return null (unassigned)
    if (!technicianExists) {
      print('🔍 Technician not found, resetting to null');
      // Reset the selected technician to null
      _selectedTechnician = null;
      _selectedTechnicianName = 'Unassigned';
      return null;
    }
    
    return _selectedTechnician;
  }

  void _updateTechnicianName() {
    // Validate the technician value first
    _getValidTechnicianValue();
    
    String? techName = _getTechnicianNameById(_selectedTechnician);
    setState(() {
      _selectedTechnicianName = techName;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateServiceRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      String srId = widget.serviceRequest['srId'] ?? widget.serviceRequest['serviceDetails']?['srId'] ?? '';
      
      bool success = await AdminAction.updateServiceRequest(
        srId: srId,
        newAssignedTo: _selectedTechnician,
        status: _selectedStatus,
        comments: _commentsController.text.trim(),
        newAddressByDate: _selectedDate,
        requestType: _selectedRequestType,
        assignedTechnician: _selectedTechnicianName,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onUpdated();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service request updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Show local notification for technician reassignment
        if (_selectedTechnician != null && _selectedTechnicianName != null) {
          // Extract technician name and employee ID
          String technicianName = _selectedTechnicianName!.split(' - ').first;
          String employeeId = _selectedTechnician!;
          
          await LocalNotificationService.showServiceRequestUpdatedNotification(
            srId: srId,
            technicianName: technicianName,
            employeeId: employeeId,
          );
        }

        debugPrint('=== Service Request Updated ===');
        debugPrint('SR ID: $srId');
        debugPrint('Assigned To (EmpId): $_selectedTechnician');
        debugPrint('Assigned Technician (Name - EmpId): $_selectedTechnicianName');
        debugPrint('Status: $_selectedStatus');
        debugPrint('Request Type: $_selectedRequestType');
        debugPrint('Address By Date: $_selectedDate');
        debugPrint('Comments: ${_commentsController.text.trim()}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating service request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final srId = widget.serviceRequest['srId'] ?? 
                 widget.serviceRequest['serviceDetails']?['srId'] ?? 'N/A';

    return RepaintBoundary(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Service Request',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'SR ID: $srId',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Body
              Flexible(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Assign Technician
                        const Text(
                          'Assign Technician',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingTechnicians)
                          const Center(child: CircularProgressIndicator())
                        else if (_technicians.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No technicians available',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _getValidTechnicianValue(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select technician',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Unassigned'),
                              ),
                              ..._technicians.map((tech) {
                                return DropdownMenuItem<String>(
                                  value: tech['empId']?.toString(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Technician Profile Icon
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: tech['profileImageUrl'] != null && 
                                          tech['profileImageUrl'] != 'sample' && 
                                          tech['profileImageUrl'].isNotEmpty
                                            ? NetworkImage(tech['profileImageUrl'])
                                            : null,
                                        child: tech['profileImageUrl'] == null || 
                                          tech['profileImageUrl'] == 'sample' || 
                                          tech['profileImageUrl'].isEmpty
                                            ? Icon(Icons.person, color: Colors.grey[600], size: 16)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      // Technician Name and ID
                                      Flexible(
                                        child: Text(
                                          '${tech['name']} (${tech['empId']})',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedTechnician = value;
                                _selectedTechnicianName = _getTechnicianNameById(value);
                              });
                            },
                          ),

                        const SizedBox(height: 12),

                        // Status
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _statusOptions.contains(_selectedStatus) ? _selectedStatus : 'pending',
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _statusOptions.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status.replaceAll('_', ' ').toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // Request Type
                        const Text(
                          'Request Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _requestTypeOptions.contains(_selectedRequestType) ? _selectedRequestType : 'general_maintenance',
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _requestTypeOptions.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type.replaceAll('_', ' ').toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRequestType = value;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // Address By Date
                        const Text(
                          'Address By Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDate != null 
                                      ? _formatDate(_selectedDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _selectedDate != null 
                                        ? Colors.black87 
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Comments
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _commentsController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Add comments...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _updateServiceRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Update'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}