import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';

class TechnicianActionScreen extends StatefulWidget {
  final String serviceRequestId;
  
  const TechnicianActionScreen({
    Key? key,
    required this.serviceRequestId,
  }) : super(key: key);

  @override
  State<TechnicianActionScreen> createState() => _TechnicianActionScreenState();
}

class _TechnicianActionScreenState extends State<TechnicianActionScreen> {
  final TextEditingController _technicianIdController = TextEditingController();
  final TextEditingController _technicianNameController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String _selectedAction = 'accepted';
  bool _isLoading = false;
  Map<String, dynamic>? _serviceRequest;

  @override
  void initState() {
    super.initState();
    _loadServiceRequest();
    // Set default technician details
    _technicianIdController.text = 'TECH001';
    _technicianNameController.text = 'John Doe';
  }

  @override
  void dispose() {
    _technicianIdController.dispose();
    _technicianNameController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceRequest() async {
    try {
      Map<String, dynamic>? serviceRequest = await AdminAction.getServiceRequestById(widget.serviceRequestId);
      setState(() {
        _serviceRequest = serviceRequest;
      });
    } catch (e) {
      print('Error loading service request: $e');
    }
  }

  Future<void> _handleTechnicianAction() async {
    if (_technicianIdController.text.isEmpty || _technicianNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in technician details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await AdminAction.handleTechnicianAction(
        srId: widget.serviceRequestId,
        technicianId: _technicianIdController.text.trim(),
        technicianName: _technicianNameController.text.trim(),
        action: _selectedAction,
        comments: _commentsController.text.trim().isNotEmpty ? _commentsController.text.trim() : null,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service request ${_selectedAction} successfully! Admin will be notified.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Navigate back after successful action
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process action. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Technician Action - ${widget.serviceRequestId}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Request Info Card
            if (_serviceRequest != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Request Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('SR ID: ${widget.serviceRequestId}'),
                      Text('Status: ${_serviceRequest!['status'] ?? 'Unknown'}'),
                      if (_serviceRequest!['customerDetails'] != null) ...[
                        Text('Customer: ${_serviceRequest!['customerDetails']['name'] ?? 'N/A'}'),
                        Text('Company: ${_serviceRequest!['customerDetails']['company'] ?? 'N/A'}'),
                      ],
                      if (_serviceRequest!['equipmentDetails'] != null) ...[
                        Text('Model: ${_serviceRequest!['equipmentDetails']['model'] ?? 'N/A'}'),
                        Text('Location: ${_serviceRequest!['equipmentDetails']['city'] ?? 'N/A'}, ${_serviceRequest!['equipmentDetails']['state'] ?? 'N/A'}'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Technician Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technician Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _technicianIdController,
                      decoration: const InputDecoration(
                        labelText: 'Technician ID *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., TECH001',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _technicianNameController,
                      decoration: const InputDecoration(
                        labelText: 'Technician Name *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., John Doe',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedAction,
                      decoration: const InputDecoration(
                        labelText: 'Select Action *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'accepted',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Accept Service Request'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Reject Service Request'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAction = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comments
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comments (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Add comments...',
                        border: const OutlineInputBorder(),
                        hintText: _selectedAction == 'accepted' 
                            ? 'e.g., Equipment available, will start work tomorrow'
                            : 'e.g., Equipment not available, please reassign',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleTechnicianAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedAction == 'accepted' ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      '${_selectedAction == 'accepted' ? 'Accept' : 'Reject'} Service Request',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'What happens next?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Service request status will be updated to "${_selectedAction}"',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '2. Admin will receive a notification about this action',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '3. If rejected, admin can reassign to another technician',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💡 Check the admin notification page to see the created notification!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 