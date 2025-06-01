import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/opportunity.dart';
import '../widgets/curved_background_clipper.dart';
import '../widgets/home_widgets.dart';
import '../widgets/company_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _welcomeController;
  late AnimationController _cardController;
  late AnimationController _opportunitiesController;
  
  late Animation<double> _welcomeAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _opportunitiesAnimation;
  
  String? selectedOpportunity;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _opportunitiesController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _welcomeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeOutBack),
    );
    
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );
    
    _opportunitiesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _opportunitiesController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _welcomeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _cardController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _opportunitiesController.forward();
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    _cardController.dispose();
    _opportunitiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              _buildBackground(screenHeight),
              _buildContent(screenWidth, screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(double screenHeight) {
    return Stack(
      children: [
        ClipPath(
          clipper: CurvedBackgroundClipper(),
          child: Container(
            width: double.infinity,
            height: screenHeight * 0.32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF7C3AED),
                  Color(0xFF6D28D9),
                ],
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: CurvedBackgroundClipper(),
          child: Container(
            width: double.infinity,
            height: screenHeight * 0.32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.02),
          WelcomeSection(animation: _welcomeAnimation),
          SizedBox(height: screenHeight * 0.015),
          LocationSection(animation: _cardAnimation),
          SizedBox(height: screenHeight * 0.025),
          _buildOpportunitySection(),
          SizedBox(height: screenHeight * 0.02),
          _buildEarningOpportunitiesSection(),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  Widget _buildOpportunitySection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final opportunities = OpportunityData.getOpportunityButtons();

    return AnimatedBuilder(
      animation: _opportunitiesAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _opportunitiesAnimation.value)),
          child: Opacity(
            opacity: _opportunitiesAnimation.value.clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Opportunity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    if (selectedOpportunity != null)
                      TextButton(
                        onPressed: () => setState(() => selectedOpportunity = null),
                        child: Text(
                          'Clear',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF5B3E86),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.03),
                SizedBox(
                  height: screenWidth * 0.1,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: opportunities.length,
                    itemBuilder: (context, index) {
                      final opportunity = opportunities[index];
                      final isSelected = selectedOpportunity == opportunity['name'];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < opportunities.length - 1 ? screenWidth * 0.025 : 0,
                        ),
                        child: OpportunityButton(
                          name: opportunity['name'],
                          color: opportunity['color'],
                          logoPath: opportunity['logoPath'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              selectedOpportunity = isSelected ? null : opportunity['name'];
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected: ${opportunity['name']}')),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEarningOpportunitiesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return AnimatedBuilder(
      animation: _opportunitiesAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _opportunitiesAnimation.value)),
          child: Opacity(
            opacity: _opportunitiesAnimation.value.clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Earning Potential',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View all clicked!')),
                        );
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5B3E86),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.03),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: screenWidth * 0.03,
                    crossAxisSpacing: screenWidth * 0.03,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: OpportunityData.opportunities.length,
                  itemBuilder: (context, index) {
                    final opportunity = OpportunityData.opportunities[index];
                    return EarningCard(
                      opportunity: opportunity,
                      onTap: () => _showCompanyDetails(opportunity),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCompanyDetails(Opportunity opportunity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompanyDetailsSheet(
        company: opportunity.name,
        location: opportunity.location,
        earning: opportunity.earning,
        color: opportunity.color,
        logoPath: opportunity.logoPath,
      ),
    );
  }
}