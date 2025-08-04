import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'custom_dropdown.dart';

class CustomerDetailsSection extends StatefulWidget {
  const CustomerDetailsSection({Key? key}) : super(key: key);

  @override
  State<CustomerDetailsSection> createState() => CustomerDetailsSectionState();
}

class CustomerDetailsSectionState extends State<CustomerDetailsSection> {
  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final fullAddressController = TextEditingController();
  final amcStartDateController = TextEditingController();
  final amcEndDateController = TextEditingController();
  
  bool enableMaintenanceContract = false;
  String? selectedAmcType;
  
  // AMC Type options
  final List<String> amcTypes = [
    'Basic AMC',
    'Comprehensive AMC',
    'Premium AMC',
    'Extended AMC',
  ];
  
  Map<String, dynamic> get customerData => {
    'name': nameController.text,
    'company': companyController.text,
    'phone': phoneController.text,
    'email': emailController.text,
    'city': cityController.text,
    'state': stateController.text,
    'address': fullAddressController.text,
    'maintenanceContract': enableMaintenanceContract,
    'amcType': selectedAmcType,
    'amcStartDate': amcStartDateController.text,
    'amcEndDate': amcEndDateController.text,
  };

  bool validate() {
    if (nameController.text.isEmpty) return false;
    if (phoneController.text.isEmpty) return false;
    if (emailController.text.isEmpty || 
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      return false;
    }
    
    // Validate AMC fields if maintenance contract is enabled
    if (enableMaintenanceContract) {
      if (selectedAmcType == null) return false;
      if (amcStartDateController.text.isEmpty) return false;
      if (amcEndDateController.text.isEmpty) return false;
    }
    
    return true;
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    stateController.dispose();
    fullAddressController.dispose();
    amcStartDateController.dispose();
    amcEndDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Customer Details Section
        Container(
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
                'Customer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              CustomTextField(
                label: 'Name',
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Company Field
              CustomTextField(
                label: 'Company',
                controller: companyController,
              ),
              const SizedBox(height: 16),
              
              // Phone Field
              CustomTextField(
                label: 'Phone',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email Field
              CustomTextField(
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Location Details Section
        Container(
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
                'Location Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // City Field
              CustomTextField(
                label: 'City',
                controller: cityController,
              ),
              const SizedBox(height: 16),
              
              // State Field
              CustomTextField(
                label: 'State',
                controller: stateController,
              ),
              const SizedBox(height: 16),
              
              // Full Address Field
              CustomTextField(
                label: 'Full Address',
                controller: fullAddressController,
                maxLines: 3,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Maintenance Contract Section
        Container(
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
                'Maintenance Contract',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Maintenance Contract Checkbox
              Row(
                children: [
                  Checkbox(
                    value: enableMaintenanceContract,
                    onChanged: (value) {
                      setState(() {
                        enableMaintenanceContract = value ?? false;
                        // Clear AMC fields when disabled
                        if (!enableMaintenanceContract) {
                          selectedAmcType = null;
                          amcStartDateController.clear();
                          amcEndDateController.clear();
                        }
                      });
                    },
                  ),
                  const Text(
                    'Enable Annual Maintenance Contract',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              
              // AMC Details - Show only when checkbox is enabled
              if (enableMaintenanceContract) ...[
                const SizedBox(height: 20),
                
                // AMC Type Dropdown
                CustomDropdown(
                  label: 'AMC Type',
                  value: selectedAmcType,
                  items: amcTypes,
                  onChanged: (value) {
                    setState(() {
                      selectedAmcType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // AMC Start Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AMC Start Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: amcStartDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                        hintText: 'Select start date',
                      ),
                      onTap: () => _selectDate(context, amcStartDateController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // AMC End Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AMC End Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: amcEndDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                        hintText: 'Select end date',
                      ),
                      onTap: () => _selectDate(context, amcEndDateController),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}