import 'package:flutter/material.dart';
import 'package:vayujal/services/super_admin_service.dart';
import 'package:vayujal/widgets/navigations/NormalAppBar.dart';

class SuperAdminDashboard extends StatefulWidget {
  final String username;
  
  const SuperAdminDashboard({
    super.key,
    required this.username,
  });

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  List<Map<String, dynamic>> _admins = [];
  bool _isLoading = true;
  String? _currentSuperKey;
  final TextEditingController _newSuperKeyController = TextEditingController();
  final TextEditingController _newUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  Map<String, dynamic>? _superAdminProfile;
  bool _obscureSuperKey = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _showCurrentSuperKey = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final admins = await SuperAdminService.getAllAdmins();
      final superKey = await SuperAdminService.getSuperKey();
      final profile = await SuperAdminService.getSuperAdminProfile(widget.username);

      if (mounted) {
        setState(() {
          _admins = admins;
          _currentSuperKey = superKey;
          _superAdminProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeAdmin(String adminId, String adminName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Admin'),
        content: Text('Are you sure you want to remove "$adminName" from admin access?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await SuperAdminService.removeAdmin(adminId);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Admin "$adminName" removed successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadData(); // Refresh the list
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to remove admin'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing admin: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateSuperKey() async {
    if (_newSuperKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new super key'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final success = await SuperAdminService.updateSuperKey(_newSuperKeyController.text.trim());
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Super key updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _newSuperKeyController.clear();
          _loadData(); // Refresh to show new key
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update super key'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating super key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUpdateSuperKeyDialog() {
    // Reset visibility states when dialog opens
    _obscureSuperKey = true;
    _showCurrentSuperKey = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Super Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Super Key: ${_currentSuperKey ?? 'Not set'}'),
              const SizedBox(height: 16),
              TextField(
                controller: _newSuperKeyController,
                decoration: InputDecoration(
                  labelText: 'New Super Key',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureSuperKey ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        _obscureSuperKey = !_obscureSuperKey;
                      });
                    },
                  ),
                ),
                obscureText: _obscureSuperKey,
                style: const TextStyle(
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset visibility when dialog closes
                setState(() {
                  _obscureSuperKey = true;
                  _showCurrentSuperKey = false;
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateSuperKey();
                // Reset visibility when dialog closes
                setState(() {
                  _obscureSuperKey = true;
                  _showCurrentSuperKey = false;
                });
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_newUsernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newUsernameController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username must be at least 3 characters'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final success = await SuperAdminService.updateSuperAdminProfile(
        widget.username,
        _newUsernameController.text.trim(),
        _newPasswordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _newUsernameController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _loadData(); // Refresh to show updated profile
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

    void _showUpdateProfileDialog() {
    // Reset visibility states when dialog opens
    _obscureNewPassword = true;
    _obscureConfirmPassword = true;
    
    // Pre-fill current values
    _newUsernameController.text = widget.username;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newUsernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureNewPassword,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset visibility when dialog closes
                setState(() {
                  _obscureNewPassword = true;
                  _obscureConfirmPassword = true;
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateProfile();
                // Reset visibility when dialog closes
                setState(() {
                  _obscureNewPassword = true;
                  _obscureConfirmPassword = true;
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newSuperKeyController.dispose();
    _newUsernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  size: 32,
                                  color: Colors.purple.shade700,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Super Admin Dashboard',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade700,
                                        ),
                                      ),
                                      Text(
                                        'Welcome, ${widget.username}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Super Key Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Super Key Management',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showUpdateSuperKeyDialog,
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Update'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                                                         Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.grey.shade100,
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.grey.shade300),
                               ),
                               child: Row(
                                 children: [
                                   Icon(Icons.key, color: Colors.grey.shade600),
                                   const SizedBox(width: 8),
                                   Expanded(
                                     child: Text(
                                       _showCurrentSuperKey 
                                           ? (_currentSuperKey ?? 'Not set')
                                           : '••••••••••••••••',
                                       style: TextStyle(
                                         fontSize: 16,
                                         fontFamily: 'monospace',
                                         color: Colors.grey.shade700,
                                       ),
                                     ),
                                   ),
                                   IconButton(
                                     icon: Icon(
                                       _showCurrentSuperKey ? Icons.visibility_off : Icons.visibility,
                                       color: Colors.grey.shade600,
                                       size: 20,
                                     ),
                                     onPressed: () {
                                       setState(() {
                                         _showCurrentSuperKey = !_showCurrentSuperKey;
                                       });
                                     },
                                   ),
                                 ],
                               ),
                             ),
                          ],
                        ),
                      ),
                    ),
                                         const SizedBox(height: 16),

                     // Profile Management Section
                     Card(
                       elevation: 2,
                       child: Padding(
                         padding: const EdgeInsets.all(16),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text(
                                   'Account Settings',
                                   style: TextStyle(
                                     fontSize: 18,
                                     fontWeight: FontWeight.bold,
                                     color: Colors.grey.shade800,
                                   ),
                                 ),
                                 ElevatedButton.icon(
                                   onPressed: _showUpdateProfileDialog,
                                   icon: const Icon(Icons.edit, size: 18),
                                   label: const Text('Edit'),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: Colors.green.shade600,
                                     foregroundColor: Colors.white,
                                   ),
                                 ),
                               ],
                             ),
                             const SizedBox(height: 8),
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.green.shade50,
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.green.shade200),
                               ),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(
                                     children: [
                                       Icon(Icons.person, color: Colors.green.shade700),
                                       const SizedBox(width: 8),
                                       Text(
                                         'Username: ${widget.username}',
                                         style: TextStyle(
                                           fontWeight: FontWeight.bold,
                                           color: Colors.green.shade700,
                                         ),
                                       ),
                                     ],
                                   ),
                                   const SizedBox(height: 4),
                                   Row(
                                     children: [
                                       Icon(Icons.admin_panel_settings, color: Colors.green.shade600),
                                       const SizedBox(width: 8),
                                       Text(
                                         'Role: Super Admin',
                                         style: TextStyle(
                                           color: Colors.green.shade600,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                     const SizedBox(height: 16),

                     // Admins Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.grey.shade800,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Admin Management',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_admins.length} Admin${_admins.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_admins.isEmpty)
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No admins found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _admins.length,
                                itemBuilder: (context, index) {
                                  final admin = _admins[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue.shade100,
                                        child: Text(
                                          (admin['fullName'] ?? 'A')[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        admin['fullName'] ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(admin['email'] ?? 'No email'),
                                          Text(
                                            'Employee ID: ${admin['employeeId'] ?? 'N/A'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'remove') {
                                            _removeAdmin(
                                              admin['id'],
                                              admin['fullName'] ?? 'Unknown',
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'remove',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Remove Admin'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 