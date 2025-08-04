import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/screens/all_devices.dart';
import 'device_information_section.dart';
import 'customer_details_section.dart';
import 'photo_upload_widget.dart';

class DeviceForm extends StatefulWidget {
  const DeviceForm({super.key, this.deviceToEdit});

  final Map<String, dynamic>? deviceToEdit;

  @override
  State<DeviceForm> createState() => _DeviceFormState();
}

class _DeviceFormState extends State<DeviceForm> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();
  final _awgSerialNumberController = TextEditingController();
  final _installationDateController = TextEditingController();
  final _customerDetailsKey = GlobalKey<CustomerDetailsSectionState>();

  String? _selectedModel;
  String? _selectedDispenser;
  String? _selectedPowerSource;
  List<String> _uploadedPhotos = []; // Add this for photo storage

  @override
  void initState() {
    super.initState();

    if (widget.deviceToEdit != null) {
      final device = widget.deviceToEdit!;
      final deviceInfo = device['deviceInfo'];
      final customer = device['customerDetails'];
      final location = device['locationDetails'];
      final maintenance = device['maintenanceContract'];

      _selectedModel = deviceInfo['model'];
      _awgSerialNumberController.text = deviceInfo['awgSerialNumber'];
      _serialNumberController.text = deviceInfo['serialNumber'];
      _installationDateController.text = deviceInfo['installationDate'];
      _selectedDispenser = deviceInfo['dispenserDetails'];
      _selectedPowerSource = deviceInfo['powerSource'];
      
      // Load existing photos if any
      if (deviceInfo['photos'] != null) {
        _uploadedPhotos = List<String>.from(deviceInfo['photos']);
      }

      // Populate customer details after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final customerState = _customerDetailsKey.currentState;
        if (customerState != null) {
          // Basic customer info
          customerState.nameController.text = customer['name'] ?? '';
          customerState.companyController.text = customer['company'] ?? '';
          customerState.phoneController.text = customer['phone'] ?? '';
          customerState.emailController.text = customer['email'] ?? '';
          
          // Location details
          customerState.cityController.text = location['city'] ?? '';
          customerState.stateController.text = location['state'] ?? '';
          customerState.fullAddressController.text = location['fullAddress'] ?? '';
          
          // Maintenance contract details
          customerState.enableMaintenanceContract = maintenance['annualContract'] ?? false;
          
          // AMC details if maintenance contract is enabled
          if (maintenance['annualContract'] == true) {
            customerState.selectedAmcType = maintenance['amcType'];
            customerState.amcStartDateController.text = maintenance['amcStartDate'] ?? '';
            customerState.amcEndDateController.text = maintenance['amcEndDate'] ?? '';
          }
          
          // Trigger setState to refresh the UI
          customerState.setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _installationDateController.dispose();
    _awgSerialNumberController.dispose();
    super.dispose();
  }

  void _handleModelSelection(String? model) {
    setState(() {
      _selectedModel = model;
    });
  }

  void _handleDispenserSelection(String? dispenser) {
    setState(() {
      _selectedDispenser = dispenser;
    });
  }

  void _handlePowerSourceSelection(String? powerSource) {
    setState(() {
      _selectedPowerSource = powerSource;
    });
  }

  void _handlePhotosUploaded(List<String> photos) {
    setState(() {
      _uploadedPhotos = photos;
    });
  }

  void _printAllFormData() async {
    if (_formKey.currentState!.validate()) {
      final customerState = _customerDetailsKey.currentState!;

      // Validate customer details including AMC fields
      if (!customerState.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields correctly'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final formData = {
        'deviceId': _awgSerialNumberController.text,
        'deviceInfo': {
          'model': _selectedModel,
          'awgSerialNumber': _awgSerialNumberController.text,
          'serialNumber': _serialNumberController.text,
          'dispenserDetails': _selectedDispenser ?? '',
          'powerSource': _selectedPowerSource ?? '',
          'installationDate': _installationDateController.text,
          'photos': _uploadedPhotos, // Include photos in the data
        },
        'customerDetails': {
          'name': customerState.nameController.text,
          'company': customerState.companyController.text,
          'phone': customerState.phoneController.text,
          'email': customerState.emailController.text,
        },
        'locationDetails': {
          'city': customerState.cityController.text,
          'state': customerState.stateController.text,
          'fullAddress': customerState.fullAddressController.text,
        },
        'maintenanceContract': {
          'annualContract': customerState.enableMaintenanceContract,
          'amcType': customerState.selectedAmcType,
          'amcStartDate': customerState.amcStartDateController.text,
          'amcEndDate': customerState.amcEndDateController.text,
        }
      };

      // Debug print to see all form data
      print('Complete Form Data: $formData');

      try {
        if (widget.deviceToEdit != null) {
          await AdminAction.editDevice(_awgSerialNumberController.text, formData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await AdminAction.addNewDevice(formData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device registered successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DevicesScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeviceInformationSection(
            selectedModel: _selectedModel,
            awgSerialNumberController: _awgSerialNumberController,
            serialNumberController: _serialNumberController,
            selectedDispenser: _selectedDispenser,
            selectedPowerSource: _selectedPowerSource,
            installationDateController: _installationDateController,
            onModelChanged: _handleModelSelection,
            onDispenserChanged: _handleDispenserSelection,
            onPowerSourceChanged: _handlePowerSourceSelection, 
          ),
          const SizedBox(height: 24),
          
          // Add Photo Upload Widget
         PhotoUploadWidget(
  uploadedPhotos: _uploadedPhotos,
  onPhotosUploaded: _handlePhotosUploaded,
  maxPhotos: 5,
  deviceId: _awgSerialNumberController.text.isNotEmpty 
      ? _awgSerialNumberController.text 
      : 'temp_${DateTime.now().millisecondsSinceEpoch}', // Fallback for new devices
),
          const SizedBox(height: 24),
          
          CustomerDetailsSection(key: _customerDetailsKey),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: _printAllFormData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 14, 15, 15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Text(
                widget.deviceToEdit != null ? 'Save Changes' : 'Register Device',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}