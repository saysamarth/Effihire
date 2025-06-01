import 'package:flutter/material.dart';

class Opportunity {
  final String name;
  final Color color;
  final String logoPath; // Changed from IconData to String for image path
  final String location;
  final String earning;

  const Opportunity({
    required this.name,
    required this.color,
    required this.logoPath, // Updated parameter name
    required this.location,
    required this.earning,
  });
}

class OpportunityData {
  static final List<Opportunity> opportunities = [
    Opportunity(
      name: 'Blinkit',
      color: Colors.yellow.shade700,
      logoPath: 'assets/logos/blinkit.png', // Update with your actual logo file names
      location: 'Delhi',
      earning: '₹ 4,000',
    ),
    Opportunity(
      name: 'Zomato',
      color: Colors.red.shade600,
      logoPath: 'assets/logos/zomato.png',
      location: 'Delhi',
      earning: '₹ 4,500',
    ),
    Opportunity(
      name: 'Zepto',
      color: Colors.blue.shade600,
      logoPath: 'assets/logos/zepto.png',
      location: 'Delhi',
      earning: '₹ 3,800',
    ),
    Opportunity(
      name: 'Swiggy',
      color: Colors.orange.shade600,
      logoPath: 'assets/logos/swiggy.png',
      location: 'Delhi',
      earning: '₹ 5,000',
    ),
  ];

  static List<Map<String, dynamic>> getOpportunityButtons() {
    return opportunities.map((op) => {
      'name': op.name,
      'color': op.color,
      'logoPath': op.logoPath, // Updated key name
    }).toList();
  }
}