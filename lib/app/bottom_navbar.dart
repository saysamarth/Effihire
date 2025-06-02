import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile/screens/profile_screen.dart';
import 'home/screen/home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 2;
  late final List<Widget> _pages;
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  late final String? _userPhone;

  static const List<IconData> _navigationIcons = [
    Icons.group,
    Icons.assignment,
    Icons.home,
    Icons.payment,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();

    _userPhone = _auth.currentUser?.phoneNumber;

    _pages = [
      const _ReferralPage(),
      const _TasksPage(),
      const HomeScreen(),
      const _PaymentPage(),
      ProfileScreen(userPhone: _userPhone),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
                child: _NavItem(
                  icon: _navigationIcons[i],
                  index: i,
                  isSelected: i == _selectedIndex,
                  onTap: _onItemTapped,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool isSelected;
  final Function(int) onTap;
  
  const _NavItem({
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        color: isSelected ? Colors.red : Colors.black54,
        size: isSelected ? 32 : 26,
      ),
    );
  }
}

class _ReferralPage extends StatelessWidget {
  const _ReferralPage();
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Referral'));
  }
}

class _TasksPage extends StatelessWidget {
  const _TasksPage();
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('My Tasks'));
  }
}

class _PaymentPage extends StatelessWidget {
  const _PaymentPage();
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Payment'));
  }
}