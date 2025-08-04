import 'package:flutter/material.dart';
import 'package:vayujal/DatabaseAction/adminAction.dart';
import 'package:vayujal/screens/new_service_request_page.dart';
import 'package:vayujal/widgets/add_new_device_widgets/device_form.dart';
import 'package:vayujal/widgets/navigations/NormalAppBar.dart';
import 'package:vayujal/widgets/navigations/bottom_navigation.dart';
import 'package:vayujal/widgets/navigations/custom_app_bar.dart';
import 'package:vayujal/widgets/device_widgets/device_card.dart';
import 'package:vayujal/widgets/device_widgets/search_bar_widget.dart';
import 'dart:convert';

class DevicesScreen extends StatefulWidget {
  final Map<String, dynamic>? newDevice;

  const DevicesScreen({super.key, this.newDevice});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _devices = [];
  List<Map<String, dynamic>> _filteredDevices = [];
  
  // Filter options
  Map<String, List<String>> _selectedFilters = {
    'model': [],
    'city': [],
    'state': [],
  };
  
  // Available filter options
  final List<String> _modelOptions = ['VJ - Home', 'VJ - Plus', 'VJ - Grand', 'VJ - Ultra', 'VJ - Max'];
  List<String> _cityOptions = [];
  List<String> _stateOptions = [];

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    try {
      final fetchedDevices = await AdminAction.getAllDevices();

      if (widget.newDevice != null) {
        fetchedDevices.insert(0, widget.newDevice!);
      }

      if (mounted) {
        setState(() {
          _devices = fetchedDevices;
          _filteredDevices = List.from(_devices);
          _extractUniqueOptions();
        });
        
        // Debug the device structure
        _debugDeviceStructure();
      }
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  void _extractUniqueOptions() {
    Set<String> cities = {};
    Set<String> states = {};
    
    print('Extracting unique options from ${_devices.length} devices'); // Debug
    
    for (var device in _devices) {
      final locationDetails = device['locationDetails'];
      
      // Debug: Print the entire locationDetails structure
      print('Device locationDetails: $locationDetails');
      
      if (locationDetails != null) {
        final city = locationDetails['city'];
        final state = locationDetails['state'];
        
        // Debug: Print individual values
        print('City: $city, State: $state');
        
        // More robust null and empty checking
        if (city != null) {
          final cityStr = city.toString().trim();
          if (cityStr.isNotEmpty) {
            cities.add(cityStr);
            print('Added city: $cityStr'); // Debug
          }
        }
        
        if (state != null) {
          final stateStr = state.toString().trim();
          if (stateStr.isNotEmpty) {
            states.add(stateStr);
            print('Added state: $stateStr'); // Debug
          }
        }
      }
    }
    
    _cityOptions = cities.toList()..sort();
    _stateOptions = states.toList()..sort();
    
    print('Final city options: $_cityOptions'); // Debug
    print('Final state options: $_stateOptions'); // Debug
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_devices);
    
    print('Starting with ${filtered.length} devices'); // Debug
    print('Selected filters: $_selectedFilters'); // Debug
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((device) {
        final deviceInfo = device['deviceInfo'] ?? {};
        final customerDetails = device['customerDetails'] ?? {};
        final locationDetails = device['locationDetails'] ?? {};
        
        return (deviceInfo['model']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (deviceInfo['awgSerialNumber']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (customerDetails['company']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (locationDetails['city']?.toString().toLowerCase().contains(searchTerm) ?? false);
      }).toList();
      print('After search filter: ${filtered.length} devices'); // Debug
    }
    
    // Apply model filter
    if (_selectedFilters['model']!.isNotEmpty) {
      filtered = filtered.where((device) {
        final model = device['deviceInfo']?['model']?.toString();
        bool matches = model != null && _selectedFilters['model']!.contains(model);
        if (!matches) print('Device with model $model filtered out'); // Debug
        return matches;
      }).toList();
      print('After model filter: ${filtered.length} devices'); // Debug
    }
    
    // Apply city filter - FIXED VERSION
    if (_selectedFilters['city']!.isNotEmpty) {
      print('Applying city filter with: ${_selectedFilters['city']}'); // Debug
      filtered = filtered.where((device) {
        final locationDetails = device['locationDetails'];
        if (locationDetails == null) {
          print('Device has no locationDetails'); // Debug
          return false;
        }
        
        final city = locationDetails['city'];
        if (city == null) {
          print('Device has no city in locationDetails'); // Debug
          return false;
        }
        
        final cityStr = city.toString().trim();
        bool matches = _selectedFilters['city']!.contains(cityStr);
        print('Device city: "$cityStr", matches filter: $matches'); // Debug
        return matches;
      }).toList();
      print('After city filter: ${filtered.length} devices'); // Debug
    }
    
    // Apply state filter - FIXED VERSION
    if (_selectedFilters['state']!.isNotEmpty) {
      print('Applying state filter with: ${_selectedFilters['state']}'); // Debug
      filtered = filtered.where((device) {
        final locationDetails = device['locationDetails'];
        if (locationDetails == null) {
          print('Device has no locationDetails'); // Debug
          return false;
        }
        
        final state = locationDetails['state'];
        if (state == null) {
          print('Device has no state in locationDetails'); // Debug
          return false;
        }
        
        final stateStr = state.toString().trim();
        bool matches = _selectedFilters['state']!.contains(stateStr);
        print('Device state: "$stateStr", matches filter: $matches'); // Debug
        return matches;
      }).toList();
      print('After state filter: ${filtered.length} devices'); // Debug
    }
    
    setState(() {
      _filteredDevices = filtered;
    });
    
    print('Final filtered devices count: ${_filteredDevices.length}'); // Debug
  }

  // Add a debug method to inspect your device data structure
  void _debugDeviceStructure() {
    if (_devices.isNotEmpty) {
      print('=== DEVICE STRUCTURE DEBUG ===');
      print('First device structure:');
      print(_devices.first);
      print('LocationDetails structure:');
      print(_devices.first['locationDetails']);
      print('Available keys in locationDetails:');
      if (_devices.first['locationDetails'] != null) {
        print(_devices.first['locationDetails'].keys.toList());
      }
      print('==============================');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[80],
      appBar: const CustomAppBar(title: 'All Devices'),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSearchSection(),
          const SizedBox(height: 16),
          _buildFilterSection(),
          const SizedBox(height: 8),
          Expanded(child: _buildDevicesList()),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        onTap:(currentIndex) => BottomNavigation.navigateTo(currentIndex, context),
        
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SearchBarWidget(
        controller: _searchController,
        onChanged: (value) {
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (_hasActiveFilters())
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildFilterDropdown('AWG Model', 'model', _modelOptions)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterDropdown('State', 'state', _stateOptions)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterDropdown('City', 'city', _cityOptions)),
            ],
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 8),
            _buildActiveFiltersDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String title, String filterKey, List<String> options) {
    if (options.isEmpty) return const SizedBox.shrink();
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<String>(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedFilters[filterKey]!.isNotEmpty 
                        ? Color.fromARGB(255, 23, 24, 24)
                        : Colors.grey[700],
                    fontWeight: _selectedFilters[filterKey]!.isNotEmpty 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: _selectedFilters[filterKey]!.isNotEmpty 
                    ? const Color.fromARGB(255, 23, 24, 24) 
                    : Colors.grey[700],
                size: 20,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => options.map((option) {
          return PopupMenuItem<String>(
            value: option,
            child: StatefulBuilder(
              builder: (context, setMenuState) {
                bool isSelected = _selectedFilters[filterKey]!.contains(option);
                return Row(
                  children: [
                    Checkbox(
                      activeColor: Colors.grey[800],
                      value: isSelected,
                      onChanged: (bool? value) {
                        // Update the main state immediately
                        setState(() {
                          if (value == true) {
                            if (!_selectedFilters[filterKey]!.contains(option)) {
                              _selectedFilters[filterKey]!.add(option);
                              print('Added $option to $filterKey filter'); // Debug
                            }
                          } else {
                            _selectedFilters[filterKey]!.remove(option);
                            print('Removed $option from $filterKey filter'); // Debug
                          }
                        });
                        
                        // Also update the menu state for immediate visual feedback
                        setMenuState(() {});
                        
                        // Apply filters immediately
                        _applyFilters();
                      },
                    ),
                    Expanded(child: Text(option)),
                  ],
                );
              },
            ),
          );
        }).toList(),
        onSelected: (value) {
          // Selection is handled in checkbox onChanged
        },
      ),
    );
  }

  Widget _buildActiveFiltersDisplay() {
    List<Widget> filterChips = [];
    
    _selectedFilters.forEach((filterType, selectedValues) {
      for (String value in selectedValues) {
        filterChips.add(
          Chip(
            label: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              setState(() {
                _selectedFilters[filterType]!.remove(value);
              });
              _applyFilters();
            },
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            side: BorderSide(color: const Color.fromARGB(255, 75, 75, 75)),
          ),
        );
      }
    });
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: filterChips,
    );
  }

  bool _hasActiveFilters() {
    return _selectedFilters.values.any((filters) => filters.isNotEmpty);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.forEach((key, value) => value.clear());
    });
    _applyFilters();
  }

  Widget _buildDevicesList() {
    if (_devices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredDevices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No devices found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredDevices.length,
      itemBuilder: (context, index) {
        final device = _filteredDevices[index];
        final deviceInfo = device['deviceInfo'] ?? {};
        final customerDetails = device['customerDetails'] ?? {};
        final locationDetails = device['locationDetails'] ?? {};

        return DeviceCard(
          deviceModel: deviceInfo['model'] ?? 'Unknown',
          
          awgSerialNumber: deviceInfo['awgSerialNumber'] ?? 'N/A',
          customer: customerDetails['company'] ?? 'Unknown',
          location: locationDetails['city'] ?? 'Unknown',
          lastService: deviceInfo['installationDate'] ?? 'N/A',
          onEdit: () => _editDevice(device),
          onService: () => _serviceDevice(device),
          onView: () => _viewDeviceDetails(device),
          onDelete: () => _showDeleteConfirmation(deviceInfo['awgSerialNumber'] ?? ''),
        );
      },
    );
  }

  void _viewDeviceDetails(Map<String, dynamic> device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
appBar: Normalappbar(title: 'Device details'),          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildDeviceDetailsView(device),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: 1,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/alldevice');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/profile');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/history');
                  break;
                case 4:
                  Navigator.pushReplacementNamed(context, '/notifications');
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  void _editDevice(Map<String, dynamic> device){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
           appBar: Normalappbar(title: 'Edit Device'),          
      body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: DeviceForm(deviceToEdit: device),
          ),
        ),
      ),
    );
  }

  void _serviceDevice(Map<String, dynamic> device){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: NewServiceRequestPage(deviceToService: device),
        ),
      ),
    );
  }

 Widget _buildDeviceDetailsView(Map<String, dynamic> device) {
  final deviceInfo = device['deviceInfo'] ?? {};
  final customerDetails = device['customerDetails'] ?? {};
  final locationDetails = device['locationDetails'] ?? {};
  final maintenanceContract = device['maintenanceContract'] ?? {};
  
  // Get photos list from deviceInfo
  final photos = deviceInfo['photos'] as List<dynamic>? ?? [];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Photo Carousel Section - only show if photos exist
      if (photos.isNotEmpty) ...[
        _buildPhotoCarousel(photos),
        const SizedBox(height: 20),
      ],
      
      _buildDetailSection('Device Information', [
        _buildDetailRow('Model', deviceInfo['model'] ?? 'N/A'),
        _buildDetailRow('AWG Serial Number', deviceInfo['awgSerialNumber'] ?? 'N/A'),
        _buildDetailRow('Dispenser', deviceInfo['dispenserDetails'] ?? 'N/A'),
        _buildDetailRow('Power Source', deviceInfo['powerSource'] ?? 'N/A'),
        _buildDetailRow('Installation Date', deviceInfo['installationDate'] ?? 'N/A'),
      ]),
      const SizedBox(height: 20),
      _buildDetailSection('Customer Details', [
        _buildDetailRow('Name', customerDetails['name'] ?? 'N/A'),
        _buildDetailRow('Company', customerDetails['company'] ?? 'N/A'),
        _buildDetailRow('Phone', customerDetails['phone'] ?? 'N/A'),
        _buildDetailRow('Email', customerDetails['email'] ?? 'N/A'),
      ]),
      const SizedBox(height: 20),
      _buildDetailSection('Location Details', [
        _buildDetailRow('City', locationDetails['city'] ?? 'N/A'),
        _buildDetailRow('State', locationDetails['state'] ?? 'N/A'),
        _buildDetailRow('Full Address', locationDetails['fullAddress'] ?? 'N/A'),
      ]),
      const SizedBox(height: 20),
      _buildDetailSection('Maintenance Contract', [
        _buildDetailRow('Annual Contract', maintenanceContract['annualContract'] == true ? 'Yes' : 'No'),
        _buildDetailRow('AMC Type', maintenanceContract['amcType'] ?? 'N/A'),
        _buildDetailRow('AMC Start Date', maintenanceContract['amcStartDate'] ?? 'N/A'),
        _buildDetailRow('AMC End Date', maintenanceContract['amcEndDate'] ?? 'N/A'),
      ]),
    ],
  );
}

Widget _buildPhotoCarousel(List<dynamic> photos) {
  final PageController pageController = PageController();
  
  return Card(
    color: Colors.white,
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Device Photos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                '${photos.length} photo${photos.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: pageController,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () => _showFullScreenImage(photo),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImageWidget(photo),
                    ),
                  ),
                );
              },
            ),
          ),
          if (photos.length > 1) ...[
            const SizedBox(height: 12),
            _buildPhotoIndicators(photos.length, pageController),
          ],
        ],
      ),
    ),
  );
}

Widget _buildImageWidget(dynamic photo) {
  // Handle different photo formats (URL string, File path, base64, etc.)
  if (photo is String) {
    if (photo.startsWith('http')) {
      // Network image
      return Image.network(
        photo,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImageLoading();
        },
      );
    } else if (photo.startsWith('data:image')) {
      // Base64 image
      try {
        final bytes = base64Decode(photo.split(',').last);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError();
          },
        );
      } catch (e) {
        return _buildImageError();
      }
    } else {
      // File path
      return Image.asset(
        photo,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }
  }
  
  // Default error case
  return _buildImageError();
}

Widget _buildImageError() {
  return Container(
    width: double.infinity,
    height: double.infinity,
    color: Colors.grey[200],
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.broken_image,
          size: 48,
          color: Colors.grey,
        ),
        SizedBox(height: 8),
        Text(
          'Image not available',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Widget _buildImageLoading() {
  return Container(
    width: double.infinity,
    height: double.infinity,
    color: Colors.grey[100],
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Widget _buildPhotoIndicators(int photoCount, PageController pageController) {
  return StatefulBuilder(
    builder: (context, setState) {
      int currentPage = 0;
      
      pageController.addListener(() {
        int page = pageController.page?.round() ?? 0;
        if (page != currentPage) {
          setState(() {
            currentPage = page;
          });
        }
      });
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(photoCount, (index) {
          return GestureDetector(
            onTap: () {
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentPage 
                    ? Colors.grey[800] 
                    : Colors.grey[400],
              ),
            ),
          );
        }),
      );
    },
  );
}

void _showFullScreenImage(dynamic photo) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) {
      return Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildImageWidget(photo),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
  Widget _buildDetailSection(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 95, 95, 95),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[850],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDevice(String serialNumber) async {
    if (serialNumber.isEmpty) {
      _showSnackBar('Invalid serial number', isError: true);
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await AdminAction.deleteDevice(serialNumber);
      
      // Hide loading indicator
      Navigator.of(context).pop();

      if (success) {
        // Remove device from local lists
        setState(() {
          _devices.removeWhere((device) => 
            device['deviceInfo']?['awgSerialNumber'] == serialNumber);
          _filteredDevices.removeWhere((device) => 
            device['deviceInfo']?['awgSerialNumber'] == serialNumber);
        });
        
        _showSnackBar('Device deleted successfully');
      } else {
        _showSnackBar('Failed to delete device', isError: true);
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      _showSnackBar('Error deleting device: $e', isError: true);
    }
  }

  void _showDeleteConfirmation(String serialNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Device'),
          content: Text('Are you sure you want to delete device with serial number: $serialNumber?\n\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDevice(serialNumber);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}