import 'package:flutter/material.dart';
import 'custom_dropdown.dart';
import 'custom_text_field.dart';
import 'date_picker_field.dart';
import '../../services/dropdown_service.dart';

class DeviceInformationSection extends StatefulWidget {
  final String? selectedModel;
  final TextEditingController serialNumberController;
  final TextEditingController awgSerialNumberController;
  final String? selectedDispenser;
  final String? selectedPowerSource;
  final TextEditingController installationDateController;
  final Function(String?) onModelChanged;
  final Function(String?) onDispenserChanged;
  final Function(String?) onPowerSourceChanged;

  const DeviceInformationSection({
    Key? key,
    required this.selectedModel,
    required this.serialNumberController,
    required this.awgSerialNumberController,
    required this.selectedDispenser,
    required this.selectedPowerSource,
    required this.installationDateController,
    required this.onModelChanged,
    required this.onDispenserChanged,
    required this.onPowerSourceChanged,
  }) : super(key: key);

  @override
  State<DeviceInformationSection> createState() => _DeviceInformationSectionState();
}

class _DeviceInformationSectionState extends State<DeviceInformationSection> {
  List<String> _modelValues = [];
  List<String> _dispenserValues = [];
  List<String> _powerSourceValues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDropdownValues();
  }

  Future<void> _loadDropdownValues() async {
    try {
      final modelValues = await DropdownService.getModelValues();
      final dispenserValues = await DropdownService.getDispenserValues();
      final powerSourceValues = await DropdownService.getPowerSourceValues();

      if (mounted) {
        setState(() {
          _modelValues = modelValues;
          _dispenserValues = dispenserValues;
          _powerSourceValues = powerSourceValues;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dropdown values: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Model Dropdown with validation
          CustomDropdown(
            label: 'Model',
            value: widget.selectedModel,
            items: _modelValues,
            onChanged: widget.onModelChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a model';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'AWG Serial Number',
            controller: widget.awgSerialNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter AWG serial number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Serial Number
          CustomTextField(
            label: 'Compressor Serial Number',
            controller: widget.serialNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter compressor serial number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Dispenser Details with validation
          CustomDropdown(
            label: 'Dispenser Details',
            value: widget.selectedDispenser,
            items: _dispenserValues,
            onChanged: widget.onDispenserChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select dispenser details';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Power Source with validation
          CustomDropdown(
            label: 'Power source',
            value: widget.selectedPowerSource,
            items: _powerSourceValues,
            onChanged: widget.onPowerSourceChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a power source';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Installation Date
          DatePickerField(
            label: 'Installation Date',
            controller: widget.installationDateController,
            hintText: 'dd-mm-yyyy',
          ),
        ],
      ),
    );
  }
}