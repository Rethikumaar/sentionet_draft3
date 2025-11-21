import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Pricing Plans",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigoAccent,
                Colors.indigo.shade700,
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigoAccent,
                    Colors.indigoAccent.withOpacity(0.05),
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 30 : 20),
                vertical: isDesktop ? 50 : (isTablet ? 40 : 30),
              ),
              child: Column(
                children: [
                  Text(
                    "Choose Your Plan",
                    style: TextStyle(
                      fontSize: isDesktop ? 36 : (isTablet ? 30 : 26),
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Select the perfect plan for your mental wellness journey",
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                      color: Colors.indigo.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Pricing Cards
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 30 : 20),
                vertical: isDesktop ? 40 : 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : double.infinity,
                  ),
                  child: isDesktop || isTablet
                      ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PricingCard(
                          title: "Basic",
                          price: "Free",
                          period: "Forever",
                          features: const [
                            "PHQ-10 assessment",
                            "Text emotion analysis",
                            "Basic mood tracking",
                            "Email support",
                          ],
                          isPopular: false,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 24 : 16),
                      Expanded(
                        child: PricingCard(
                          title: "Premium",
                          price: "₹299",
                          period: "per month",
                          features: const [
                            "Full AI emotion fusion",
                            "Facial expression model",
                            "Advanced mood trends",
                            "Report export (PDF)",
                            "Priority support",
                            "Custom insights",
                          ],
                          isPopular: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade400,
                              Colors.purple.shade500,
                            ],
                          ),
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      PricingCard(
                        title: "Basic",
                        price: "Free",
                        period: "Forever",
                        features: const [
                          "PHQ-10 assessment",
                          "Text emotion analysis",
                          "Basic mood tracking",
                          "Email support",
                        ],
                        isPopular: false,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                        ),
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 20),
                      PricingCard(
                        title: "Premium",
                        price: "₹299",
                        period: "per month",
                        features: const [
                          "Full AI emotion fusion",
                          "Facial expression model",
                          "Advanced mood trends",
                          "Report export (PDF)",
                          "Priority support",
                          "Custom insights",
                        ],
                        isPopular: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.purple.shade500,
                          ],
                        ),
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // FAQ or Info Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 30 : 20),
                vertical: 20,
              ),
              child: Container(
                padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade50,
                      Colors.purple.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.indigo.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.indigo.shade700,
                      size: isDesktop ? 48 : 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "All plans include secure data encryption and privacy protection",
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}

class PricingCard extends StatefulWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final Gradient gradient;
  final bool isDesktop;
  final bool isTablet;

  const PricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
    required this.gradient,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  State<PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<PricingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPopular
                        ? Colors.indigo.withOpacity(_isHovered ? 0.3 : 0.2)
                        : Colors.grey.withOpacity(_isHovered ? 0.2 : 0.1),
                    blurRadius: _isHovered ? 20 : 15,
                    offset: Offset(0, _isHovered ? 12 : 8),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: widget.isPopular
                      ? BorderSide(color: Colors.indigo.shade300, width: 2)
                      : BorderSide.none,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        widget.isPopular
                            ? Colors.indigo.shade50.withOpacity(0.3)
                            : Colors.blue.shade50.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      widget.isDesktop ? 32 : (widget.isTablet ? 28 : 24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => widget.gradient.createShader(bounds),
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: widget.isDesktop ? 28 : (widget.isTablet ? 24 : 22),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => widget.gradient.createShader(bounds),
                              child: Text(
                                widget.price,
                                style: TextStyle(
                                  fontSize: widget.isDesktop ? 48 : (widget.isTablet ? 42 : 38),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.period,
                          style: TextStyle(
                            fontSize: widget.isDesktop ? 16 : 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: widget.isDesktop ? 32 : 24),

                        // Features
                        ...widget.features.map(
                              (feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: widget.gradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: widget.isDesktop ? 16 : (widget.isTablet ? 15 : 14),
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: widget.isDesktop ? 32 : 24),

                        // Button
                        SizedBox(
                          width: double.infinity,
                          height: widget.isDesktop ? 56 : (widget.isTablet ? 52 : 48),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: widget.gradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isPopular
                                      ? Colors.indigo.withOpacity(0.4)
                                      : Colors.blue.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${widget.title} plan selected!'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                widget.price == "Free" ? "Get Started" : "Choose ${widget.title}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: widget.isDesktop ? 18 : (widget.isTablet ? 16 : 15),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Popular Badge
            if (widget.isPopular)
              Positioned(
                top: -12,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "POPULAR",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.isDesktop ? 14 : 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}