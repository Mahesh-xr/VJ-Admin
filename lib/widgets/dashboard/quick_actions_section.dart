import 'package:flutter/material.dart';
import 'package:vayujal/screens/add_device_screen.dart';
import 'package:vayujal/screens/all_devices.dart';
import 'package:vayujal/screens/all_service_request_page.dart';
import 'action_button.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            
            Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
        );
          },
          child: ActionButton(
            title: 'Register new AWG', 
            onPressed: () {


              Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
        );
              
            },
          ),
        ),
        const SizedBox(height: 12),
         ActionButton(
          onPressed: () {
             Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AllServiceRequestsPage(),
        ),
      );
          },
          title: 'View all Tasks', 
        ),
        const SizedBox(height: 12),
        ActionButton(
           onPressed: () {


              Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DevicesScreen()),
        );
              
            },
          title: 'View all Devices', 
        ),
      ],
    );
  }
}