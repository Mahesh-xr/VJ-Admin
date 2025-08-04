import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/AdminHelper.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/screens/all_service_request_page.dart';
import 'package:vayujal/widgets/navigations/NormalAppBar.dart';
import 'package:vayujal/widgets/new_service_request_widgets/customer_detials_form.dart';
import 'package:vayujal/widgets/new_service_request_widgets/equipment_details_form.dart.dart';
import 'package:vayujal/widgets/new_service_request_widgets/service_request_detials_widget.dart';
import 'package:vayujal/widgets/new_service_request_widgets/submit_botton.dart';
import 'package:vayujal/services/local_notification_service.dart';

class NewServiceRequestPage extends StatefulWidget {
  final Map<String, dynamic>? deviceToService;
  
  const NewServiceRequestPage({super.key, this.deviceToService});

  @override
  State<NewServiceRequestPage> createState() => _NewServiceRequestPageState();
}

class _NewServiceRequestPageState extends State<NewServiceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Equipment Details Controllers
  final _modelController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _ownerController = TextEditingController();
  final _awgSerialNumberController = TextEditingController();

  // Customer Details Controllers
  final _customerIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // SR Details Controllers
  final _commentController = TextEditingController();
  bool _generalMaintenance = false;
  bool _customerComplaint = false;
  String? _assignedTo;
  String? _assignedTechnician; // This will store "name - empId"
  DateTime? _addressByDate = DateTime.now().add(const Duration(days: 2));

  // Technician dropdown data
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoadingTechnicians = true;
  

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTechnicians();
  }

  void _loadData() {
    if (widget.deviceToService != null) {
      _loadDeviceData(widget.deviceToService!);
    }
  }

  Future<void> _loadTechnicians() async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingTechnicians = true;
        });
      }
      
      List<Map<String, dynamic>> techs = await AdminAction.getAllTechnicians();
      
      if (mounted) {
        setState(() {
          _technicians = techs;
          _isLoadingTechnicians = false;
          
          // Set default assignment if technicians are available
          if (techs.isNotEmpty && _assignedTo == null) {
            _assignedTo = techs.first['empId'];
            _assignedTechnician = '${techs.first['name']} - ${techs.first['empId']}';
          }
        });
        
        // Debug print
        techs.forEach((tech) {
          print("Technician: ${tech['name']} (Emp ID: ${tech['empId']})");
          print("Profile URL in UI: ${tech['profileImageUrl']}");
          print("Profile URL type: ${tech['profileImageUrl'].runtimeType}");
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTechnicians = false;
        });
      }
      print("Error loading technicians: $e");
    }
  }

  void _loadDeviceData(Map<String, dynamic> device) {
    final deviceInfo = device['deviceInfo'] ?? {};
    final customerDetails = device['customerDetails'] ?? {};
    final locationDetails = device['locationDetails'] ?? {};
    // final maintainanceDetails = device['maintenanceContract'] ??{};
    // Equipment data from device
    _modelController.text = deviceInfo['model'] ?? '';
    _awgSerialNumberController.text = deviceInfo['awgSerialNumber'] ?? '';
    _cityController.text = locationDetails['city'] ?? '';
    _stateController.text = locationDetails['state'] ?? '';
    _ownerController.text = customerDetails['name'] ?? '';

    // Customer data from device
    _nameController.text = customerDetails['name'] ?? '';
    _companyController.text = customerDetails['company'] ?? '';
    _phoneController.text = customerDetails['phone'] ?? '';
    _emailController.text = customerDetails['email'] ?? '';
    
    // Generate customer ID based on serial number or timestamp
   

    // SR Details - pre-fill with device context
   
  }

  // Helper method to get technician name by empId
  String? _getTechnicianNameById(String? empId) {
    if (empId == null) return null;
    
    final technician = _technicians.firstWhere(
      (tech) => tech['empId'] == empId,
      orElse: () => {},
    );
    
    if (technician.isNotEmpty) {
      return '${technician['name']} - ${technician['empId']}';
    }
    return null;
  }

Widget _buildTechnicianDropdown() {
  return Card(
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16), // Increased padding back to 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assign Technician',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingTechnicians)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_technicians.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No technicians available. Please add technicians first.',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadTechnicians,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            // Wrap the dropdown in a Container to control width
            SizedBox(
              width: double.infinity, // Take full available width
              child: DropdownButtonFormField<String>(
                value: _assignedTo,
                isExpanded: true, // This prevents overflow by allowing text to expand
                decoration: const InputDecoration(
                  labelText: 'Select Technician',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: [
                  // Option for unassigned
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Unassigned',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Technician options
                  ..._technicians.map((technician) {
                    String displayText = '${technician['name']} (${technician['empId']})';
                    return DropdownMenuItem<String>(
                      value: technician['empId'],
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            // Technician Profile Icon
                           
                            const SizedBox(width: 12),
                            // Technician Name and ID
                            Expanded(
                              child: Text(
                                displayText,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _assignedTo = value;
                    _assignedTechnician = _getTechnicianNameById(value);
                  });
                },
                validator: (value) {
                  return null;
                },
                hint: const Text(
                  'Choose a technician',
                  overflow: TextOverflow.ellipsis,
                ),
                // Additional properties to prevent overflow
                menuMaxHeight: 300, // Limit dropdown menu height
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    ),
  );
}


  @override
  void dispose() {
    _modelController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _ownerController.dispose();
    _customerIdController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Prepare equipment details
        Map<String, dynamic> equipmentDetails = {
          'model': _modelController.text,
          'awgSerialNumber': _awgSerialNumberController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'owner': _ownerController.text,
          'amcDetails': widget.deviceToService!['maintenanceContract']
        };

        // Prepare customer details
        Map<String, dynamic> customerDetails = {
          'name': _nameController.text,
          'company': _companyController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': widget.deviceToService!['locationDetails']
        };

        // Prepare service details
        String specificAdminName = await AdminHelper.getFormattedAdminName(
              FirebaseAuth.instance.currentUser?.uid,
            );
        Map<String, dynamic> serviceDetails = {
          'requestType': _customerComplaint ? 'customer_complaint' : 'general_maintenance',          
          'comments': _commentController.text,
          'assignedTo': _assignedTo, // This is the empId
          'assignedTechnician': _assignedTechnician, // This is "name - empId"
          'assignedBy': specificAdminName,
          'addressByDate': _addressByDate != null ? Timestamp.fromDate(_addressByDate!) : null,
        };

        // Create service request
        String srId = await AdminAction.createServiceRequest(
          equipmentDetails: equipmentDetails,
          customerDetails: customerDetails,
          serviceDetails: serviceDetails,
          deviceId: widget.deviceToService?['deviceInfo']?['awgSerialNumber'],
        );

        // Hide loading indicator
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service request created successfully!\nSR ID: $srId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Show local notification for technician assignment
        if (_assignedTo != null && _assignedTechnician != null) {
          // Extract technician name and employee ID from the assignedTechnician string
          String technicianName = _assignedTechnician!.split(' - ').first;
          String employeeId = _assignedTo!;
          
          await LocalNotificationService.showServiceRequestCreatedNotification(
            srId: srId,
            technicianName: technicianName,
            employeeId: employeeId,
          );
        }

      
        
        // Navigate to all SR request screen
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AllServiceRequestsPage(),
        ),
      );
        
      } catch (e) {
        // Hide loading indicator if showing
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating service request: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        
        debugPrint('❌ Error creating service request: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
     appBar: Normalappbar(title: 'New Service Request'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EquipmentDetailsForm(
                modelController: _modelController,
                cityController: _cityController,
                stateController: _stateController,
                ownerController: _ownerController,
                awgSerialNumberController: _awgSerialNumberController,
              ),
              const SizedBox(height: 24),
              CustomerDetailsForm(
                nameController: _nameController,
                companyController: _companyController,
                phoneController: _phoneController,
                emailController: _emailController,
              ),
              const SizedBox(height: 24),
              ServiceRequestDetailsWidget(
                commentController: _commentController,
                generalMaintenance: _generalMaintenance,
                customerComplaint: _customerComplaint,
                
                addressByDate: _addressByDate,
                onGeneralMaintenanceChanged: (value) {
                  setState(() => _generalMaintenance = value);
                },
                onCustomerComplaintChanged: (value) {
                  setState(() => _customerComplaint = value);
                },
              
                onAddressByDateChanged: (date) {
                  setState(() => _addressByDate = date);
                },
              ),
              const SizedBox(height: 24),
              // Add the technician dropdown here
              _buildTechnicianDropdown(),
              const SizedBox(height: 24),
              SubmitButton(
                onPressed: _onSubmit,
                text: 'Create Service Request',
              ),
              const SizedBox(height: 44),

            ],
          ),
        ),
      ),
    );
  }
}