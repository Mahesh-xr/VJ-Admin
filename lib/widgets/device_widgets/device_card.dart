import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String deviceModel;
  final String awgSerialNumber;

  final String customer;
  final String location;
  final String lastService;
  final VoidCallback onEdit;
  final VoidCallback onService;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const DeviceCard({
    super.key,
    required this.awgSerialNumber,
    required this.deviceModel,
    required this.customer,
    required this.location,
    required this.lastService,
    required this.onEdit,
    required this.onService,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with model name, view button, and delete icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    deviceModel,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // View Button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: InkWell(
                    onTap: onView,
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         
                          Text(
                            'View',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                InkWell(
                  onTap: () => _showDeleteConfirmation(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    
                    child: Icon(
                      Icons.delete,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Device details
            _buildDetailRow('AWG Serial Number', awgSerialNumber),
            const SizedBox(height: 8),
            _buildDetailRow('Customer', customer),
            const SizedBox(height: 8),
            _buildDetailRow('Location', location),
            const SizedBox(height: 8),
            _buildDetailRow('Last Service', lastService),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    label: const Text('Edit',
                    style: TextStyle(
                      fontSize: 18
                    ),),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:  Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onService,
          
                    label: const Text('Service',
                    style: TextStyle(
                      fontSize: 18
                    ),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            '$label',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(":",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),),
        SizedBox(width:10,),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(221, 70, 69, 69),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.black),
              SizedBox(width: 8),
              Text('Delete Device'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this device?'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model: $deviceModel', style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('Serial: $awgSerialNumber'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}