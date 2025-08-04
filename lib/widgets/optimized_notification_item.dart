import 'package:flutter/material.dart';
import 'package:vayujal/utils/performance_utils.dart';

class OptimizedNotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String notificationType;
  final bool isUnread;
  final String? srId;
  final String? technicianName;
  final String? technicianId;
  final String? customerName;
  final String? equipmentModel;
  final String? location;
  final dynamic createdAt;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onReassign;

  const OptimizedNotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isUnread,
    this.srId,
    this.technicianName,
    this.technicianId,
    this.customerName,
    this.equipmentModel,
    this.location,
    this.createdAt,
    this.onTap,
    this.onLongPress,
    this.onReassign,
  }) : super(key: key);

  Color _getNotificationColor(String type) {
    final normalizedType = type.toLowerCase().replaceAll(' ', '_');
    
    switch (normalizedType) {
      case 'service_assignment':
        return Colors.blue;
      case 'service_reassignment':
        return Colors.orange;
      case 'service_request_created':
        return Colors.green;
      case 'service_request_updated':
        return Colors.purple;
      case 'service_accepted':
        return Colors.green;
      case 'service_rejected':
        return Colors.red;
      case 'service_completed':
        return Colors.teal;
      case 'service_acknowledgment_completed':
        return Colors.indigo;
      case 'device_operation':
        return Colors.indigo;
      case 'admin_request':
      case 'admin_access_request':
        return Colors.orange;
      case 'test':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getNotificationBorderColor(String type) {
    final normalizedType = type.toLowerCase().replaceAll(' ', '_');
    
    switch (normalizedType) {
      case 'service_accepted':
        return Colors.green.shade200;
      case 'service_rejected':
        return Colors.red.shade200;
      case 'service_completed':
        return Colors.teal.shade200;
      case 'service_acknowledgment_completed':
        return Colors.indigo.shade200;
      case 'service_assignment':
        return Colors.blue.shade200;
      case 'service_reassignment':
        return Colors.orange.shade200;
      default:
        return Colors.blue.shade200;
    }
  }

  IconData _getNotificationIcon(String type) {
    final normalizedType = type.toLowerCase().replaceAll(' ', '_');
    
    switch (normalizedType) {
      case 'service_assignment':
        return Icons.assignment;
      case 'service_reassignment':
        return Icons.swap_horiz;
      case 'service_request_created':
        return Icons.add_task;
      case 'service_request_updated':
        return Icons.edit;
      case 'service_accepted':
        return Icons.check_circle;
      case 'service_rejected':
        return Icons.cancel;
      case 'service_completed':
        return Icons.task_alt;
      case 'service_acknowledgment_completed':
        return Icons.verified;
      case 'device_operation':
        return Icons.devices;
      case 'admin_request':
      case 'admin_access_request':
        return Icons.admin_panel_settings;
      case 'test':
        return Icons.bug_report;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceUtils.optimizedListItem(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isUnread 
            ? Border.all(color: _getNotificationBorderColor(notificationType), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getNotificationColor(notificationType),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getNotificationIcon(notificationType),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: PerformanceUtils.optimizedText(
          title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: isUnread ? Colors.black : Colors.grey.shade700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            PerformanceUtils.optimizedText(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            // Show detailed information for service-related notifications
            if ([
              'service_accepted',
              'service_rejected',
              'service_completed',
              'service_assignment',
              'service_reassignment',
              'service_request_created',
              'service_request_updated',
            ].contains(notificationType.toLowerCase().replaceAll(' ', '_'))) ...[
              const SizedBox(height: 8),
              // Technician information
              if (technicianName != null && technicianName!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: PerformanceUtils.optimizedText(
                        'Technician: $technicianName',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (technicianId != null && technicianId!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: PerformanceUtils.optimizedText(
                          'ID: $technicianId',
                          style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
              ],
              // Service Request ID
              if (srId != null && srId!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.confirmation_number, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: PerformanceUtils.optimizedText(
                        'SR ID: $srId',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              // Customer and Equipment details
              if ((customerName != null && customerName!.isNotEmpty) || 
                  (equipmentModel != null && equipmentModel!.isNotEmpty)) ...[
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: PerformanceUtils.optimizedText(
                        '${customerName?.isNotEmpty == true ? customerName : 'Customer'} - ${equipmentModel?.isNotEmpty == true ? equipmentModel : 'Equipment'}${location?.isNotEmpty == true ? ' ($location)' : ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              // Reassign button for rejected notifications
              if (notificationType.toLowerCase().replaceAll(' ', '_') == 'service_rejected' && 
                  srId != null && srId!.isNotEmpty && onReassign != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onReassign,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Reassign to Another Technician'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
               
                if (isUnread) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notificationType),
                      borderRadius: BorderRadius.circular(10),
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
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
} 