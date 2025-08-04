
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/DatabaseAction/AdminHelper.dart';

class AdminRequestWidget extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback? onRequestProcessed;

  const AdminRequestWidget({
    Key? key,
    required this.request,
    this.onRequestProcessed,
  }) : super(key: key);

  @override
  State<AdminRequestWidget> createState() => _AdminRequestWidgetState();
}

class _AdminRequestWidgetState extends State<AdminRequestWidget> {
  bool _isProcessing = false;
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  // Optimized data extraction method
  Map<String, dynamic> get _requestData {
    final request = widget.request;
    // Most fields are at root level, only technicianId and technicianName are in data
    return request;
  }

  // Helper method to get technician data from nested data object
  Map<String, dynamic> get _technicianData {
    final request = widget.request;
    if (request.containsKey('data')) {
      return request['data'] as Map<String, dynamic>;
    }
    return {};
  }

  // Optimized status color mapping
  static const Map<String, Color> _statusColors = {
    'pending': Color(0xFFFFA500), // Orange
    'approved': Color(0xFF4CAF50), // Green
    'rejected': Color(0xFFF44336), // Red
  };

  static const Map<String, String> _statusTexts = {
    'pending': 'Pending',
    'approved': 'Approved',
    'rejected': 'Rejected',
  };

  Color _getStatusColor(String status) {
    return _statusColors[status.toLowerCase()] ?? const Color(0xFF9E9E9E);
  }

  String _getStatusText(String status) {
    return _statusTexts[status.toLowerCase()] ?? 'Unknown';
  }

  // Optimized approval method
  Future<void> _approveRequest() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final adminName = await AdminHelper.getFormattedAdminName();
      final data = _requestData;
      final techData = _technicianData;
      
      final success = await AdminAction.approveAdminAccessRequest(
        notificationId: widget.request['id'],
        technicianId: techData['technicianId'] ?? '',
        technicianName: techData['technicianName'] ?? '',
        adminUid: FirebaseAuth.instance.currentUser?.uid ?? '',
        adminName: adminName,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Admin access approved for ${data['technicianName']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          widget.onRequestProcessed?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to approve admin access. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Optimized rejection method
  Future<void> _rejectRequest() async {
    if (_isProcessing) return;

    // Clear previous rejection reason
    _rejectionReasonController.clear();

    // Show rejection reason dialog
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RejectionReasonDialog(
        controller: _rejectionReasonController,
      ),
    );

    if (reason == null) return; // User cancelled

    setState(() => _isProcessing = true);

    try {
      final adminName = await AdminHelper.getFormattedAdminName();
      final data = _requestData;
      final techData = _technicianData;
      
      final success = await AdminAction.rejectAdminAccessRequest(
        notificationId: widget.request['id'],
        technicianId: techData['technicianId'] ?? '',
        technicianName: techData['technicianName'] ?? '',
        adminUid: FirebaseAuth.instance.currentUser?.uid ?? '',
        adminName: adminName,
        reason: reason.isEmpty ? null : reason,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Admin access rejected for ${data['technicianName']}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          widget.onRequestProcessed?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject admin access. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _requestData;
    final techData = _technicianData;
    
    // Extract all required fields with proper fallbacks based on your Firestore structure
    final status = data['status'] ?? 'pending';
    final isPending = status == 'pending';
    final isRead = data['isRead'] ?? false;
    final isActioned = data['isActioned'] ?? false;
    
    // Handle timestamps at root level
    final createdAt = data['createdAt'] as Timestamp?;
    final processedAt = data['processedAt'] as Timestamp?;
    final processedBy = data['processedByName'] ?? data['processedBy'] ?? '';
    
    // Extract other fields from root level
    final title = data['title'] ?? 'Admin Access Request';
    final message = data['message'] ?? 'No message provided';
    final senderName = data['senderName'] ?? '';
    final rejectionReason = data['rejectionReason'];
    
    // Extract technician data from nested data object
    final technicianName = techData['technicianName'] ?? 'Unknown Technician';
    final technicianId = techData['technicianId'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: _getStatusColor(status),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and read indicator
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              technicianName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (senderName.isNotEmpty && senderName != technicianName) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.send,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'From: $senderName',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor(status).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Actioned indicator
                      if (isActioned) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ACTIONED',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      // Unread indicator
                      if (!isRead) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.message,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Technician ID if available
              if (technicianId.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Tech ID: $technicianId',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Timestamps
              Row(
                children: [
                  Expanded(
                    child: _buildTimestampRow(
                      icon: Icons.schedule,
                      label: 'Requested',
                      timestamp: createdAt,
                    ),
                  ),
                  if (processedAt != null)
                    _buildTimestampRow(
                      icon: Icons.check_circle,
                      label: 'Processed',
                      timestamp: processedAt,
                    ),
                ],
              ),
              
              // Processed by info
              if (processedBy.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Processed by: $processedBy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              // Rejection reason if available
              if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Rejection Reason:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rejectionReason,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action buttons for pending requests
              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _approveRequest,
                        icon: _isProcessing 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: Text(_isProcessing ? 'Processing...' : 'Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _rejectRequest,
                        icon: _isProcessing 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.close, size: 18),
                        label: Text(_isProcessing ? 'Processing...' : 'Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for timestamp rows
  Widget _buildTimestampRow({
    required IconData icon,
    required String label,
    required Timestamp? timestamp,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ${timestamp != null ? _formatTimestamp(timestamp) : 'Unknown'}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _RejectionReasonDialog extends StatelessWidget {
  final TextEditingController controller;

  const _RejectionReasonDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rejection Reason'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Please provide a reason for rejecting this admin access request (optional):',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }
} 