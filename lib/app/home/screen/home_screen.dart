import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/opportunity.dart';
import '../widgets/company_detail_sheet.dart';
import '../widgets/curved_background_clipper.dart';
import '../widgets/home_widgets.dart';
import '../widgets/opportunity_filters_widget.dart';

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

  OpportunityFilters currentFilters = const OpportunityFilters();
  List<Opportunity> filteredOpportunities = [];

  late double screenHeight;
  late double screenWidth;

  late TextStyle titleTextStyle;
  late TextStyle buttonTextStyle;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _initializeFilteredOpportunities();
  }

  void _initializeFilteredOpportunities() {
    filteredOpportunities = List.from(OpportunityData.opportunities);
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
      CurvedAnimation(
        parent: _opportunitiesController,
        curve: Curves.easeOutCubic,
      ),
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
                currentFilters: currentFilters,
                onFiltersChanged: _onFiltersChanged,
                filteredOpportunities: filteredOpportunities,
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

  void _onFiltersChanged(OpportunityFilters newFilters) {
    setState(() {
      currentFilters = newFilters;
      filteredOpportunities = _applyFilters(newFilters);
    });
  }

  List<Opportunity> _applyFilters(OpportunityFilters filters) {
    List<Opportunity> filtered = List.from(OpportunityData.opportunities);

    if (filters.company != 'All Companies') {
      filtered = filtered.where((opp) => opp.name == filters.company).toList();
    }
    if (filters.paymentRange != 'All Ranges') {
      filtered = filtered
          .where((opp) => _matchesPaymentRange(opp, filters.paymentRange))
          .toList();
    }
    if (filters.distance != 'All Distances') {
      filtered = filtered
          .where((opp) => _matchesDistance(opp, filters.distance))
          .toList();
    }
    if (filters.workType != 'All Types') {}
    // Sort opportunities
    filtered = _sortOpportunities(filtered, filters.sort);

    return filtered;
  }

  bool _matchesPaymentRange(Opportunity opportunity, String paymentRange) {
    final cleanEarning = opportunity.earning.replaceAll(RegExp(r'[^\d]'), '');
    final earning = int.tryParse(cleanEarning) ?? 0;

    switch (paymentRange) {
      case 'Under ₹5,000':
        return earning < 5000;
      case '₹5,000 - ₹10,000':
        return earning >= 5000 && earning <= 10000;
      case '₹10,000 - ₹20,000':
        return earning >= 10000 && earning <= 20000;
      case '₹20,000 - ₹30,000':
        return earning >= 20000 && earning <= 30000;
      case 'Above ₹30,000':
        return earning > 30000;
      default:
        return true;
    }
  }

  bool _matchesDistance(Opportunity opportunity, String distance) {
    return true;
  }

  List<Opportunity> _sortOpportunities(
    List<Opportunity> opportunities,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'Highest Pay':
        opportunities.sort((a, b) {
          final aEarning =
              int.tryParse(a.earning.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          final bEarning =
              int.tryParse(b.earning.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          return bEarning.compareTo(aEarning);
        });
        break;
      case 'Lowest Pay':
        opportunities.sort((a, b) {
          final aEarning =
              int.tryParse(a.earning.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          final bEarning =
              int.tryParse(b.earning.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
          return aEarning.compareTo(bEarning);
        });
        break;
      case 'Company A-Z':
        opportunities.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Company Z-A':
        opportunities.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Most Recent':
        opportunities.shuffle();
        break;
      case 'Nearest First':
      default:
        break;
    }
    return opportunities;
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
                  Color.fromARGB(255, 82, 39, 137),
                  Color.fromARGB(255, 118, 57, 224),
                  Color(0xFF8B5CF6),
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
                colors: [Colors.white.withOpacity(0.1), Colors.transparent],
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
  final OpportunityFilters currentFilters;
  final Function(OpportunityFilters) onFiltersChanged;
  final List<Opportunity> filteredOpportunities;
  final Function(Opportunity) onCompanyTap;
  final TextStyle titleTextStyle;
  final TextStyle buttonTextStyle;

  const _ContentWidget({
    required this.screenWidth,
    required this.screenHeight,
    required this.welcomeAnimation,
    required this.cardAnimation,
    required this.opportunitiesAnimation,
    required this.currentFilters,
    required this.onFiltersChanged,
    required this.filteredOpportunities,
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
          _FilterSection(
            animation: opportunitiesAnimation,
            screenWidth: screenWidth,
            currentFilters: currentFilters,
            onFiltersChanged: onFiltersChanged,
            availableCompanies: _getAvailableCompanies(),
          ),
          SizedBox(height: screenHeight * 0.02),
          _EarningSection(
            animation: opportunitiesAnimation,
            screenWidth: screenWidth,
            filteredOpportunities: filteredOpportunities,
            onCompanyTap: onCompanyTap,
            titleTextStyle: titleTextStyle,
            buttonTextStyle: buttonTextStyle,
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  List<String> _getAvailableCompanies() {
    return [
      'All Companies',
      ...OpportunityData.opportunities.map((e) => e.name).toSet(),
    ];
  }
}

class _FilterSection extends StatelessWidget {
  final Animation<double> animation;
  final double screenWidth;
  final OpportunityFilters currentFilters;
  final Function(OpportunityFilters) onFiltersChanged;
  final List<String> availableCompanies;

  const _FilterSection({
    required this.animation,
    required this.screenWidth,
    required this.currentFilters,
    required this.onFiltersChanged,
    required this.availableCompanies,
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
            child: OpportunityFiltersWidget(
              currentFilters: currentFilters,
              onFiltersChanged: onFiltersChanged,
              availableCompanies: availableCompanies,
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
  final List<Opportunity> filteredOpportunities;
  final Function(Opportunity) onCompanyTap;
  final TextStyle titleTextStyle;
  final TextStyle buttonTextStyle;

  const _EarningSection({
    required this.animation,
    required this.screenWidth,
    required this.filteredOpportunities,
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
                  itemCount: filteredOpportunities.length,
                  itemBuilder: (context, index) {
                    final opportunity = filteredOpportunities[index];
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
