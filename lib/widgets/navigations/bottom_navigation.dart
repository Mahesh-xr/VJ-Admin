import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap; // Add this callback

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap, // Require the callback
  }) : super(key: key);


  static void navigateTo(int index, BuildContext context){
    

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
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
  }



  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color.fromARGB(255, 35, 35, 36),
      unselectedItemColor: const Color.fromARGB(255, 129, 127, 127),
      onTap: onTap, // Connect the callback
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.devices),
          label: 'Device',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              // Badge for unread notifications
              Positioned(
                right: 0,
                top: 0,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('recipientRole', isEqualTo: 'admin')
                      .where('isRead', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${snapshot.data!.docs.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          label: 'Notification',
        ),
      ],
    );
  }
   
  

}


