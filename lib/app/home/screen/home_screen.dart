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

  late double screenHeight;
  late double screenWidth;
  late List<Map<String, dynamic>> opportunities;

  late TextStyle titleTextStyle;
  late TextStyle buttonTextStyle;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    opportunities = OpportunityData.getOpportunityButtons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    titleTextStyle = GoogleFonts.plusJakartaSans(
      fontSize: screenWidth * 0.055,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );

    buttonTextStyle = GoogleFonts.plusJakartaSans(
      fontSize: screenWidth * 0.032,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF5B3E86),
    );
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
    if (mounted) _welcomeController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _cardController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _opportunitiesController.forward();
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              _BackgroundWidget(screenHeight: screenHeight),
              _ContentWidget(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                welcomeAnimation: _welcomeAnimation,
                cardAnimation: _cardAnimation,
                opportunitiesAnimation: _opportunitiesAnimation,
                opportunities: opportunities,
                selectedOpportunity: selectedOpportunity,
                onOpportunitySelected: _onOpportunitySelected,
                onCompanyTap: _showCompanyDetails,
                titleTextStyle: titleTextStyle,
                buttonTextStyle: buttonTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onOpportunitySelected(String? opportunityName) {
    setState(() {
      selectedOpportunity = opportunityName;
    });
    if (opportunityName != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: $opportunityName')),
      );
    }
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

class _BackgroundWidget extends StatelessWidget {
  final double screenHeight;

  const _BackgroundWidget({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
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
}

class _ContentWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final Animation<double> welcomeAnimation;
  final Animation<double> cardAnimation;
  final Animation<double> opportunitiesAnimation;
  final List<Map<String, dynamic>> opportunities;
  final String? selectedOpportunity;
  final Function(String?) onOpportunitySelected;
  final Function(Opportunity) onCompanyTap;
  final TextStyle titleTextStyle;
  final TextStyle buttonTextStyle;

  const _ContentWidget({
    required this.screenWidth,
    required this.screenHeight,
    required this.welcomeAnimation,
    required this.cardAnimation,
    required this.opportunitiesAnimation,
    required this.opportunities,
    required this.selectedOpportunity,
    required this.onOpportunitySelected,
    required this.onCompanyTap,
    required this.titleTextStyle,
    required this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.02),
          WelcomeSection(animation: welcomeAnimation),
          SizedBox(height: screenHeight * 0.015),
          LocationSection(animation: cardAnimation),
          SizedBox(height: screenHeight * 0.025),
          _OpportunitySection(
            animation: opportunitiesAnimation,
            screenWidth: screenWidth,
            opportunities: opportunities,
            selectedOpportunity: selectedOpportunity,
            onOpportunitySelected: onOpportunitySelected,
            titleTextStyle: titleTextStyle,
            buttonTextStyle: buttonTextStyle,
          ),
          SizedBox(height: screenHeight * 0.02),
          _EarningSection(
            animation: opportunitiesAnimation,
            screenWidth: screenWidth,
            onCompanyTap: onCompanyTap,
            titleTextStyle: titleTextStyle,
            buttonTextStyle: buttonTextStyle,
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}

class _OpportunitySection extends StatelessWidget {
  final Animation<double> animation;
  final double screenWidth;
  final List<Map<String, dynamic>> opportunities;
  final String? selectedOpportunity;
  final Function(String?) onOpportunitySelected;
  final TextStyle titleTextStyle;
  final TextStyle buttonTextStyle;

  const _OpportunitySection({
    required this.animation,
    required this.screenWidth,
    required this.opportunities,
    required this.selectedOpportunity,
    required this.onOpportunitySelected,
    required this.titleTextStyle,
    required this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Opportunity',
                      style: titleTextStyle,
                    ),
                    if (selectedOpportunity != null)
                      TextButton(
                        onPressed: () => onOpportunitySelected(null),
                        child: Text(
                          'Clear',
                          style: buttonTextStyle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.03),
                SizedBox(
                  height: screenWidth * 0.1,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: opportunities.length,
                    itemBuilder: (context, index) {
                      final opportunity = opportunities[index];
                      final isSelected = selectedOpportunity == opportunity['name'];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < opportunities.length - 1 ? screenWidth * 0.025 : 0,
                        ),
                        child:  OpportunityButton(
                          name: opportunity['name'],
                          color: opportunity['color'],
                          logoPath: opportunity['logoPath'],
                          isSelected: isSelected,
                          onTap: () {
                            onOpportunitySelected(
                                isSelected ? null : opportunity['name']
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
}

class _EarningSection extends StatelessWidget {
  final Animation<double> animation;
  final double screenWidth;
  final Function(Opportunity) onCompanyTap;
  final TextStyle titleTextStyle;
  final TextStyle buttonTextStyle;

  const _EarningSection({
    required this.animation,
    required this.screenWidth,
    required this.onCompanyTap,
    required this.titleTextStyle,
    required this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Earning Potential',
                      style: titleTextStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View all clicked!')),
                        );
                      },
                      child: Text(
                        'View All',
                        style: buttonTextStyle,
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
                      onTap: () => onCompanyTap(opportunity),
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
}