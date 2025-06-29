// bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/home/screen/home_screen.dart';
import '../app/profile/screens/profile_screen.dart';
import 'payment/views/payment.dart';

class BottomNavBar extends StatefulWidget {
  final Widget child;

  const BottomNavBar({super.key, required this.child});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 2;
  late final List<Widget> _pages;
  late final String? _userPhone;

  static const List<IconData> _navigationIcons = [
    Icons.group,
    Icons.assignment,
    Icons.home,
    Icons.payment,
    Icons.person,
  ];

  static const List<String> _tabRoutes = [
    '/main/referral',
    '/main/tasks',
    '/main/home',
    '/main/payment',
    '/main/profile',
  ];

  @override
  void initState() {
    super.initState();
    _userPhone = FirebaseAuth.instance.currentUser?.phoneNumber;

    _pages = [
      const ReferralScreen(),
      const TasksScreen(),
      const HomeScreen(),
      PaymentTab(),
      ProfileScreen(userPhone: _userPhone),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final String location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabRoutes.length; i++) {
      if (location.startsWith(_tabRoutes[i])) {
        if (_selectedIndex != i) {
          setState(() {
            _selectedIndex = i;
          });
        }
        break;
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      context.go(_tabRoutes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _pages),
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

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Referral')),
      body: const Center(child: Text('Referral Screen')),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: const Center(child: Text('Tasks Screen')),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: const Center(child: Text('Payment Screen')),
    );
  }
}
