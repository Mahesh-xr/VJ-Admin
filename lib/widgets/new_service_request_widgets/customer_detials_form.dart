import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'form_card.dart';
import 'custom_dropdown.dart';

class CustomerDetailsForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController companyController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool demoMode;

  const CustomerDetailsForm({
    super.key,
    required this.nameController,
    required this.companyController,
    required this.phoneController,
    required this.emailController,
    this.demoMode = false,
  });

  @override
  State<CustomerDetailsForm> createState() => _CustomerDetailsFormState();
}

class _CustomerDetailsFormState extends State<CustomerDetailsForm> {
  // Expanded sample customer data
  final List<Map<String, String>> _demoCustomers = [
    {
      'id': 'CUST1001',
      'name': 'John Smith',
      'company': 'Tech Solutions Inc.',
      'phone': '(555) 123-4567',
      'email': 'john.smith@techsolutions.com'
    },
    {
      'id': 'CUST1002',
      'name': 'Sarah Johnson',
      'company': 'Digital Innovations LLC',
      'phone': '(555) 987-6543',
      'email': 's.johnson@digitalinnov.com'
    },
    {
      'id': 'CUST1003',
      'name': 'Michael Chen',
      'company': 'Future Systems Corp',
      'phone': '(555) 456-7890',
      'email': 'michael.chen@futuresystems.com'
    },
    {
      'id': 'CUST1004',
      'name': 'Emily Wilson',
      'company': 'Cloud Technologies Ltd',
      'phone': '(555) 789-0123',
      'email': 'emily.w@cloudtech.com'
    },
  ];

  @override
  void initState() {
    super.initState();
    
  }

  void _fillCustomerData(Map<String, String> customer) {
    widget.nameController.text = customer['name'] ?? '';
    widget.companyController.text = customer['company'] ?? '';
    widget.phoneController.text = customer['phone'] ?? '';
    widget.emailController.text = customer['email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Customer Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FormCard(
          title: '',
          child: Column(
            children: [
              if (widget.demoMode)
                Column(
                  children: [
                    CustomDropdown(
                      label: 'Select Customer',
                      hint: 'Choose a sample customer',
                      items: _demoCustomers
                          .map((customer) => customer['company']!)
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          final selected = _demoCustomers.firstWhere(
                            (customer) => customer['company'] == value,
                          );
                          _fillCustomerData(selected);
                          setState(() {});
                        }
                      }, value: '',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Name',
                controller: widget.nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Company',
                controller: widget.companyController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Phone',
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^[0-9 ()+-]{10,}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Email',
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}