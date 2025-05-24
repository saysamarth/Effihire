import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile/screens/profile_screen.dart';
import 'home/screen/home_screen.dart'; // Add this import

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 2; 
  late final List<Widget> _pages;
  
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Center(child: Text('Referral')),
      const Center(child: Text('My Tasks')),
      const HomeScreen(), // Replace placeholder with HomeScreen
      const Center(child: Text('Payment')),
      ProfileScreen(
        userPhone: _auth.currentUser?.phoneNumber,
      ),
    ];
  }

  final List<IconData> _navigationIcons = [
    Icons.group,
    Icons.assignment,
    Icons.home,
    Icons.payment,
    Icons.person,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navigationIcons.length, (i) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(i),
                  child: Icon(
                    _navigationIcons[i],
                    color: i == _selectedIndex ? Colors.red : Colors.black54,
                    size: i == _selectedIndex ? 32 : 26,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
} 