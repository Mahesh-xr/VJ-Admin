import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:vayujal/widgets/navigations/bottom_navigation.dart';
import 'package:vayujal/pages/service_details_page.dart';

import 'package:vayujal/services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTab);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => BottomNavigation.navigateTo(0, context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blue),
            onPressed: () => _markAllAsRead(),
            tooltip: 'Mark All as Read',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () => _showDeleteAllDialog(context),
            tooltip: 'Delete All Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔄 Notification list refreshed'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Refresh Notifications',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips - more compact
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text('All', style: TextStyle(fontSize: 12)),
                    selected: _selectedFilter == 'all',
                    onSelected: (selected) => setState(() => _selectedFilter = 'all'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Unread', style: TextStyle(fontSize: 12)),
                    selected: _selectedFilter == 'unread',
                    onSelected: (selected) => setState(() => _selectedFilter = 'unread'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Today', style: TextStyle(fontSize: 12)),
                    selected: _selectedFilter == 'today',
                    onSelected: (selected) => setState(() => _selectedFilter = 'today'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Yesterday', style: TextStyle(fontSize: 12)),
                    selected: _selectedFilter == 'yesterday',
                    onSelected: (selected) => setState(() => _selectedFilter = 'yesterday'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),
            // Enhanced Smooth Sliding Tab switcher
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Stack(
                children: [
                  // Smooth sliding background indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    left: _selectedTab == 0 ? 4 : MediaQuery.of(context).size.width * 0.5 - 16,
                    top: 4,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5 - 20,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _selectedTab == 0 
                              ? [Colors.blue.shade400, Colors.blue.shade600]
                              : [Colors.orange.shade400, Colors.orange.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: (_selectedTab == 0 ? Colors.blue : Colors.orange).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Notification Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onTabChanged(0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: _selectedTab == 0 ? 1.2 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 0 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.notifications,
                                      size: 20,
                                      color: _selectedTab == 0 ? Colors.white : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Stack(
                                  children: [
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      style: TextStyle(
                                        fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w500,
                                        color: _selectedTab == 0 ? Colors.white : Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      child: const Text('Notification'),
                                    ),
                                   
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Admin Request Tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onTabChanged(1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: _selectedTab == 1 ? 1.2 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 1 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.admin_panel_settings,
                                      size: 20,
                                      color: _selectedTab == 1 ? Colors.white : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Stack(
                                  children: [
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      style: TextStyle(
                                        fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.w500,
                                        color: _selectedTab == 1 ? Colors.white : Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      child: const Text('Admin Request'),
                                    ),
                                   
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // PageView for sections
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                physics: const BouncingScrollPhysics(),
                children: [
                  const NotificationListSection(),
                  const AdminRequestSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 4,
        onTap: (index) => BottomNavigation.navigateTo(index, context),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      final notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        await doc.reference.update({'isRead': true});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllNotifications();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllNotifications() async {
    try {
      final notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientRole', isEqualTo: 'admin')
          .get();

      for (var doc in notifications.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ All notifications deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class NotificationListSection extends StatefulWidget {
  const NotificationListSection({Key? key}) : super(key: key);

  @override
  State<NotificationListSection> createState() => _NotificationListSectionState();
}

class _NotificationListSectionState extends State<NotificationListSection> {
  bool _isDialogShowing = false; // Add flag to prevent multiple dialogs

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(200)
          .snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll see technician accept/reject notifications and service request updates here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        final allNotifications = snapshot.data!.docs.toList();
        
        // Filter notifications for admin (excluding admin access requests)
        final adminNotifications = allNotifications.where((doc) {
          final docData = doc.data() as Map<String, dynamic>;
          
          // Handle both flat and nested data structures
          Map<String, dynamic> data;
          if (docData.containsKey('data')) {
            data = docData['data'] as Map<String, dynamic>;
            print('🔍 Using nested data structure');
          } else {
            data = docData;
            print('🔍 Using flat data structure');
          }
          
          final recipientRole = docData['recipientRole']?.toString().toLowerCase() ?? '';
          final type = docData['type']?.toString().toLowerCase() ?? '';
          
          print('🔍 Filtering notification - RecipientRole: $recipientRole, Type: $type');
          
          // Check if this is an admin notification but exclude admin access requests
          final isAdminNotification = recipientRole == 'admin' && type != 'admin_access_request' && type != 'admin_request';
          print('🔍 Is admin notification (excluding admin requests): $isAdminNotification');
          
          if (isAdminNotification) {
            print('🔍 ✅ Including admin notification: ${data['title'] ?? 'No title'}');
          }
          
          return isAdminNotification;
        }).toList();
        
        print('🔍 Total notifications found: ${adminNotifications.length}');
        
        // Debug: Print all found notifications
        for (int i = 0; i < adminNotifications.length; i++) {
          final doc = adminNotifications[i];
          final docData = doc.data() as Map<String, dynamic>;
          print('🔍 Notification $i: ${docData['title']} - Type: ${docData['type']}');
        }
        
        // Show empty state if no notifications
        if (adminNotifications.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll see service request updates and technician notifications here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        final sortedDocs = adminNotifications
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aCreatedAt = aData['createdAt'] as Timestamp?;
            final bCreatedAt = bData['createdAt'] as Timestamp?;
            
            if (aCreatedAt == null && bCreatedAt == null) return 0;
            if (aCreatedAt == null) return 1;
            if (bCreatedAt == null) return -1;
            
            return bCreatedAt.compareTo(aCreatedAt);
          });

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'General Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            '${sortedDocs.length} notification${sortedDocs.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Notification items
              ...sortedDocs.map((doc) {
                final docData = doc.data() as Map<String, dynamic>;
                print('🔍 Processing notification: ${doc.id}');
                print('🔍 Doc data: $docData');
                
                // Handle both flat and nested data structures
                Map<String, dynamic> data;
                if (docData.containsKey('data')) {
                  data = docData['data'] as Map<String, dynamic>;
                  print('🔍 Using nested data structure');
                } else {
                  data = docData;
                  print('🔍 Using flat data structure');
                }
                
                
                // Extract all fields from both top-level and nested structures
                final isUnread = docData['isRead'] == false;
                final notificationType = docData['type'] ?? '';
                final title = docData['title'] ?? 'No Title';
                final message = docData['message'] ?? 'No Message';
                final srId = data['srId'] ?? '';
                final createdAt = docData['createdAt'];
                
                
               
                return Container(
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
                    title: Text(
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
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              createdAt != null
                                  ? _formatTimestamp(createdAt)
                                  : '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
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
                    onTap: () async {
                      if (isUnread) {
                        _markNotificationAsRead(doc.id);
                      }
                      await _handleNotificationTap(data, notificationType, doc.id,  srId);
                    },
                    onLongPress: () {
                      _showDeleteDialog(context, doc.id, docData['title'] ?? 'Notification');
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Color _getNotificationColor(String type) {
    // Normalize the type to handle both formats
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
    // Normalize the type to handle both formats
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
    // Normalize the type to handle both formats
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

  Future<void> _handleNotificationTap(Map<String, dynamic> data, String notificationType, String notificationId, String srId) async {
    // print('🔍 Handling notification tap - Type: $notificationType, ID: $notificationId');
    // print('🔍 Data: $data');
    
    // Normalize the type to handle both formats
    final normalizedType = notificationType.toLowerCase().replaceAll(' ', '_');
    print('🔍 Normalized type: $normalizedType');

    // Handle admin requests separately
    if (normalizedType == 'admin_request' || normalizedType == 'admin_access_request') {
      // print('🔍 This is an admin request, showing dialog');
      // print('🔍 Admin request data: $data');
      // For admin requests, show the admin request dialog
      _showAdminRequestDialog(context, data, notificationId);
      return;
    }

    // For nested data structure, get srId from the data field
    if (srId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No service request associated with this notification'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    switch (normalizedType) {
      case 'service_rejected':
      case '':
      case 'service_completed':
      case 'service_acknowledgment_completed':
      case 'service_assignment':
      case 'service_reassignment':
      case 'service_request_created':
      case 'service_request_updated':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsPage(
              serviceRequestId: srId,
            ),
          ),
        );
        break;
      default:
        if (srId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailsPage(
                serviceRequestId: srId,
              ),
            ),
          );
        }
    }
  }

  /// Fetch additional service request details to ensure complete information
  
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      // Update the notification directly in Firestore
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  void _showDeleteDialog(BuildContext context, String notificationId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Admin Request'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteNotification(notificationId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin request deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting admin request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getRequestStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getRequestStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.admin_panel_settings;
    }
  }

  void _showAdminRequestDialog(BuildContext context, Map<String, dynamic> data, String notificationId, [Map<String, dynamic>? docData]) {
    // Check both top-level and nested status
    // Check both top-level and nested status
    final requestStatus = data['status'] ?? 'pending';
    final technicianName = data['technicianName'] ?? data['senderName'] ?? 'Unknown';
    final technicianId = docData?['data']?['technicianId'] ?? '';
    final message = data['message'] ?? '';
    final createdAt = data['createdAt'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getRequestStatusIcon(requestStatus),
                color: _getRequestStatusColor(requestStatus),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Admin Access'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Technician Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            technicianName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'ID: $technicianId',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Request Details
              Text(
                'Request Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
             
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.message, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (createdAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Requested: ${_formatTimestamp(createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            // Check if request is already actioned
            Builder(
              builder: (context) {
                final isActioned = data['isActioned'] == true;
                
                if (requestStatus == 'pending' && !isActioned) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _handleAdminRequest(notificationId, 'approved', data);
                        },
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _handleAdminRequest(notificationId, 'rejected', data);
                        },
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Show status and close button
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isActioned) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: requestStatus == 'approved' ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: requestStatus == 'approved' ? Colors.green.shade300 : Colors.red.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                requestStatus == 'approved' ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: requestStatus == 'approved' ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                requestStatus == 'approved' ? 'Approved' : 'Rejected',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: requestStatus == 'approved' ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAdminRequest(String notificationId, String action, Map<String, dynamic> data) async {
    try {
      // Mark original notification as actioned
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isActioned': true,
        'status': action,
      });

      // Create new notification for the technician about the decision
      final technicianId = data['technicianId'] ?? data['senderId'];
      final technicianName = data['technicianName'] ?? data['senderName'] ?? 'Unknown';
      
      if (technicianId != null) {
        // Create new notification for the technician
        await FirebaseFirestore.instance
            .collection('notifications')
            .add({
          'recipientId': technicianId,
          'recipientRole': 'technician',
          'senderId': FirebaseAuth.instance.currentUser?.uid,
          'senderName': 'Admin',
          'senderRole': 'admin',
          'type': 'admin_request_response',
          'title': 'Admin Access Request ${action == 'approved' ? 'Approved' : 'Rejected'}',
          'message': action == 'approved' 
              ? 'Your admin access request has been approved. You can now log in as an admin.'
              : 'Your admin access request has been rejected.',
          'data': {
            'requestId': notificationId,
            'status': action,
            'processedAt': FieldValue.serverTimestamp(),
            'processedBy': FirebaseAuth.instance.currentUser?.uid,
            'technicianName': technicianName,
            'technicianId': technicianId,
          },
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Add technician to admin collection if approved
        if (action == 'approved') {
          // Get technician data first
          final technicianDoc = await FirebaseFirestore.instance
              .collection('technicians')
              .doc(technicianId)
              .get();
          
          if (technicianDoc.exists) {
            final technicianData = technicianDoc.data() as Map<String, dynamic>;
            
            // Create admin account with technician data
            await FirebaseFirestore.instance
                .collection('admin')
                .doc(technicianId)
                .set({
              'fullName': technicianData['fullName'] ?? data['technicianName'] ?? data['senderName'] ?? 'Unknown',
              'email': technicianData['email'] ?? '',
              'mobileNumber': technicianData['mobileNumber'] ?? '',
              'employeeId': technicianData['employeeId'] ?? data['employeeId'] ?? '',
              'designation': technicianData['designation'] ?? 'Admin',
              'profileImageUrl': technicianData['profileImageUrl'] ?? '',
              'uid': technicianId,
              'isProfileComplete': true,
              'hasAdminAccess': true,
              'adminAccessGrantedAt': FieldValue.serverTimestamp(),
              'adminAccessGrantedBy': FirebaseAuth.instance.currentUser?.uid,
              'adminAccessStatus': 'approved',
              'role': 'admin',
              'promotedFromTechnician': true, // Flag to identify promoted technicians
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            
            // Update technician document to mark as promoted
            await FirebaseFirestore.instance
                .collection('technicians')
                .doc(technicianId)
                .update({
              'hasAdminAccess': true,
              'adminAccessGrantedAt': FieldValue.serverTimestamp(),
              'adminAccessGrantedBy': FirebaseAuth.instance.currentUser?.uid,
              'adminAccessStatus': 'approved',
              'isPromotedToAdmin': true,
              'promotedAt': FieldValue.serverTimestamp(),
            });
          }
        } else if (action == 'rejected') {
          await FirebaseFirestore.instance
              .collection('technicians')
              .doc(technicianId)
              .update({
            'adminAccessStatus': 'rejected',
            'adminAccessRejectedAt': FieldValue.serverTimestamp(),
            'adminAccessRejectedBy': FirebaseAuth.instance.currentUser?.uid,
          });
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin request ${action == 'approved' ? 'approved' : 'rejected'} successfully'),
            backgroundColor: action == 'approved' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error handling admin request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error handling admin request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 

class AdminRequestSection extends StatefulWidget {
  const AdminRequestSection({Key? key}) : super(key: key);

  @override
  State<AdminRequestSection> createState() => _AdminRequestSectionState();
}

class _AdminRequestSectionState extends State<AdminRequestSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    
            return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .limit(200)
              .snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: Colors.orange.shade300,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No admin access requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll see technician admin access requests here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
          final allNotifications = snapshot.data!.docs.toList();
         
         // Filter admin access requests
         final adminRequests = allNotifications.where((doc) {
           final docData = doc.data() as Map<String, dynamic>;
           final recipientRole = docData['recipientRole']?.toString().toLowerCase() ?? '';
           final type = docData['type']?.toString().toLowerCase() ?? '';
           
           return recipientRole == 'admin' && type == 'admin_access_request';
         }).toList();
         
         // Show empty state if no admin requests
         if (adminRequests.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: Colors.orange.shade300,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No admin access requests found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Found ${allNotifications.length} total notifications, but none are admin access requests',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
         // Sort admin requests by creation date
         final sortedDocs = adminRequests
           ..sort((a, b) {
             final aData = a.data() as Map<String, dynamic>;
             final bData = b.data() as Map<String, dynamic>;
             
             final aCreatedAt = aData['createdAt'] as Timestamp?;
             final bCreatedAt = bData['createdAt'] as Timestamp?;
             
             if (aCreatedAt == null && bCreatedAt == null) return 0;
             if (aCreatedAt == null) return 1;
             if (bCreatedAt == null) return -1;
             
             return bCreatedAt.compareTo(aCreatedAt);
           });

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Access Requests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          Text(
                            '${sortedDocs.length} request${sortedDocs.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Admin request items
              ...sortedDocs.map((doc) {
                final docData = doc.data() as Map<String, dynamic>;
                
                // Handle both flat and nested data structures
                Map<String, dynamic> data;
                if (docData.containsKey('data')) {
                  data = docData['data'] as Map<String, dynamic>;
                } else {
                  data = docData;
                }
               
                final isUnread = docData['isRead'] == false;
                final requestStatus = data['status'] ?? 'pending';
                final createdAt = docData['createdAt'];
                
                return Container(
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
                        ? Border.all(color: Colors.orange.shade200, width: 1)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getRequestStatusColor(requestStatus),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getRequestStatusIcon(requestStatus),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      data['title'] ?? 'Admin Access Request',
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
                        Text(
                          docData['message'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                       
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              createdAt != null
                                  ? _formatTimestamp(createdAt)
                                  : '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            if (isUnread) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getRequestStatusColor(requestStatus),
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
                    onTap: () async {
                      if (isUnread) {
                        _markNotificationAsRead(doc.id);
                      }
                      _showAdminRequestDialog(context, docData, doc.id, docData);
                    },
                    onLongPress: () {
                      _showDeleteDialog(context, doc.id, docData['title'] ?? 'Admin Request');
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Color _getRequestStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getRequestStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.admin_panel_settings;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      // Update the notification directly in Firestore
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  void _showDeleteDialog(BuildContext context, String notificationId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Admin Request'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteNotification(notificationId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin request deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting admin request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAdminRequestDialog(BuildContext context, Map<String, dynamic> data, String notificationId, Map<String, dynamic> docData) {
    // Check both top-level and nested status
    final requestStatus = data['status'] ?? data['data']?['status'] ?? 'pending';
    final technicianName = data['technicianName'] ?? data['senderName'] ?? 'Unknown';
    final technicianId = data['technicianUID'];
    final createdAt = docData['createdAt'];
    final message = docData['message'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getRequestStatusIcon(requestStatus),
                color: _getRequestStatusColor(requestStatus),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Admin Access'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Technician Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            technicianName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'ID: ${docData['data']['technicianUID']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Request Details
              Text(
                'Request Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
             
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.message, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (createdAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Requested: ${_formatTimestamp(createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            // Check if request is already actioned
            Builder(
              builder: (context) {
                final isActioned = data['isActioned'] == true;
                
                if (requestStatus == 'pending' && !isActioned) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _handleAdminRequest(notificationId, 'approved', data);
                        },
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _handleAdminRequest(notificationId, 'rejected', data);
                        },
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Show status and close button
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isActioned) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: requestStatus == 'approved' ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: requestStatus == 'approved' ? Colors.green.shade300 : Colors.red.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                requestStatus == 'approved' ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: requestStatus == 'approved' ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                requestStatus == 'approved' ? 'Approved' : 'Rejected',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: requestStatus == 'approved' ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAdminRequest(String notificationId, String action, Map<String, dynamic> data) async {
    try {
      // Mark original notification as actioned and update status
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isActioned': true,
        'status': action,
      });

      // Create new notification for the technician about the decision
      final technicianId = data['technicianId'] ?? data['senderId'];
      final technicianName = data['technicianName'] ?? data['senderName'] ?? 'Unknown';
      
      if (technicianId != null) {
        // Create new notification for the technician
        await FirebaseFirestore.instance
            .collection('notifications')
            .add({
          'recipientId': technicianId,
          'recipientRole': 'technician',
          'senderId': FirebaseAuth.instance.currentUser?.uid,
          'senderName': 'Admin',
          'senderRole': 'admin',
          'type': 'admin_request_response',
          'title': 'Admin Access Request ${action == 'approved' ? 'Approved' : 'Rejected'}',
          'message': action == 'approved' 
              ? 'Your admin access request has been approved. You can now log in as an admin.'
              : 'Your admin access request has been rejected.',
          'data': {
            'requestId': notificationId,
            'status': action,
            'processedAt': FieldValue.serverTimestamp(),
            'processedBy': FirebaseAuth.instance.currentUser?.uid,
            'technicianName': technicianName,
            'technicianId': technicianId,
          },
          'isRead': false,
          'isActioned': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Add technician to admin collection if approved
        if (action == 'approved') {
          // Get technician data first
          final technicianDoc = await FirebaseFirestore.instance
              .collection('technicians')
              .doc(technicianId)
              .get();
          
          if (technicianDoc.exists) {
            final technicianData = technicianDoc.data() as Map<String, dynamic>;
            
            // Create admin account with technician data
            await FirebaseFirestore.instance
                .collection('admins')
                .doc(technicianId)
                .set({
              'fullName': technicianData['fullName'] ?? data['technicianName'] ?? data['senderName'] ?? 'Unknown',
              'email': technicianData['email'] ?? '',
              'mobileNumber': technicianData['mobileNumber'] ?? '',
              'employeeId': technicianData['employeeId'] ?? data['employeeId'] ?? '',
              'designation': technicianData['designation'] ?? 'Admin',
              'profileImageUrl': technicianData['profileImageUrl'] ?? '',
              'uid': technicianId,
              'isProfileComplete': true,
              'hasAdminAccess': true,
              'adminAccessGrantedAt': FieldValue.serverTimestamp(),
              'adminAccessGrantedBy': FirebaseAuth.instance.currentUser?.uid,
              'adminAccessStatus': 'approved',
              'role': 'admin',
              'promotedFromTechnician': true, // Flag to identify promoted technicians
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            
            // Update technician document to mark as promoted
            await FirebaseFirestore.instance
                .collection('technicians')
                .doc(technicianId)
                .update({
              'hasAdminAccess': true,
              'adminAccessGrantedAt': FieldValue.serverTimestamp(),
              'adminAccessGrantedBy': FirebaseAuth.instance.currentUser?.uid,
              'adminAccessStatus': 'approved',
              'isPromotedToAdmin': true,
              'promotedAt': FieldValue.serverTimestamp(),
            });
          }
        } else if (action == 'rejected') {
          await FirebaseFirestore.instance
              .collection('technicians')
              .doc(technicianId)
              .update({
            'adminAccessStatus': 'rejected',
            'adminAccessRejectedAt': FieldValue.serverTimestamp(),
            'adminAccessRejectedBy': FirebaseAuth.instance.currentUser?.uid,
          });
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin request ${action == 'approved' ? 'approved' : 'rejected'} successfully'),
            backgroundColor: action == 'approved' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error handling admin request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error handling admin request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

} 