import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<WelcomePage> _pages = [
    WelcomePage(
      title: 'Find Your Perfect Companion',
      description: 'Discover loving animals waiting for their forever homes',
      icon: Icons.pets,
      color: primaryPurple,
    ),
    WelcomePage(
      title: 'Support Local Shelters',
      description: 'Connect with animal shelters in your community',
      icon: Icons.location_city,
      color: primaryViolet,
    ),
    WelcomePage(
      title: 'Easy Adoption Process',
      description: 'Simple steps to bring home your new furry friend',
      icon: Icons.favorite,
      color: accentPink,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9333EA), Color(0xFF7C3AED), Color(0xFF6D28D9)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _controller.reset();
                      _controller.forward();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                
                // Page indicators and buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.4),
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Next button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.25),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 
                                ? 'Get Started' 
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sign in button (only show on last page)
                      if (_currentPage == _pages.length - 1)
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: const Text(
                            'Already have an account? Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(WelcomePage page) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(
                      page.icon,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    page.title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    page.description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Decorative elements
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDecorativeIcon(Icons.pets, 0),
                      const SizedBox(width: 24),
                      _buildDecorativeIcon(Icons.home, 200),
                      const SizedBox(width: 24),
                      _buildDecorativeIcon(Icons.favorite_border, 400),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecorativeIcon(IconData icon, int delay) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500 + delay),
      opacity: 1.0,
      child: Icon(
        icon,
        color: Colors.white.withOpacity(0.3),
        size: 32,
      ),
    );
  }
}

class WelcomePage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  WelcomePage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}