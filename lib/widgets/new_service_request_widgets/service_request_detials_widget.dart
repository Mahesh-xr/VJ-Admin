import 'package:flutter/material.dart';
import 'form_card.dart';
import 'custom_checkbox_widget.dart';
import 'comment_text_area.dart';
import 'date_picker_field.dart';

class ServiceRequestDetailsWidget extends StatelessWidget {
  final TextEditingController commentController;
  final bool generalMaintenance;
  final bool customerComplaint;
  final DateTime? addressByDate;
  final Function(bool) onGeneralMaintenanceChanged;
  final Function(bool) onCustomerComplaintChanged;
  final Function(DateTime) onAddressByDateChanged;
  final String? Function(String?)? commentValidator;

  const ServiceRequestDetailsWidget({
    super.key,
    required this.commentController,
    required this.generalMaintenance,
    required this.customerComplaint,
    required this.addressByDate,
    required this.onGeneralMaintenanceChanged,
    required this.onCustomerComplaintChanged,
    required this.onAddressByDateChanged,
    this.commentValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SR Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select related components',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        FormCard(
          title: '',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complaint Related to',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              CustomCheckboxWidget(
                label: 'General Maintenance',
                value: generalMaintenance,
                onChanged: (value) {
                  if (value) {
                    // If general maintenance is selected, uncheck customer complaint
                    onGeneralMaintenanceChanged(true);
                    if (customerComplaint) {
                      onCustomerComplaintChanged(false);
                    }
                  } else {
                    onGeneralMaintenanceChanged(false);
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomCheckboxWidget(
                label: 'Customer Complaint',
                value: customerComplaint,
                onChanged: (value) {
                  if (value) {
                    // If customer complaint is selected, uncheck general maintenance
                    onCustomerComplaintChanged(true);
                    if (generalMaintenance) {
                      onGeneralMaintenanceChanged(false);
                    }
                  } else {
                    onCustomerComplaintChanged(false);
                  }
                },
              ),
              
              const SizedBox(height: 20),
              
              CommentTextArea(
                hintText: 'Type your message...',
                controller: commentController,
                validator: commentValidator,
              ),
              
              // Address By Section
              const SizedBox(height: 8),
              DatePickerField(
                selectedDate: addressByDate,
                onDateSelected: onAddressByDateChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}