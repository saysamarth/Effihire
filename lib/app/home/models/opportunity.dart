import 'package:flutter/material.dart';

class Opportunity {
  final String name;
  final Color color;
  final IconData icon;
  final String location;
  final String earning;

  const Opportunity({
    required this.name,
    required this.color,
    required this.icon,
    required this.location,
    required this.earning,
  });
}

class OpportunityData {
  static final List<Opportunity> opportunities = [
    Opportunity(
      name: 'Blinkit',
      color: Colors.yellow.shade700,
      icon: Icons.flash_on,
      location: 'Delhi',
      earning: '₹ 4,000',
    ),
    Opportunity(
      name: 'Zomato',
      color: Colors.red.shade600,
      icon: Icons.restaurant,
      location: 'Delhi',
      earning: '₹ 4,500',
    ),
    Opportunity(
      name: 'CMS',
      color: Colors.blue.shade600,
      icon: Icons.business,
      location: 'Delhi',
      earning: '₹ 3,800',
    ),
    Opportunity(
      name: 'Swiggy',
      color: Colors.orange.shade600,
      icon: Icons.delivery_dining,
      location: 'Delhi',
      earning: '₹ 5,000',
    ),
  ];

  static List<Map<String, dynamic>> getOpportunityButtons() {
    return opportunities.map((op) => {
      'name': op.name,
      'color': op.color,
      'icon': op.icon,
    }).toList();
  }
}