// navigation_view.dart
import 'package:duo_app/common/resources/app_colors.dart';
import 'package:duo_app/gen/assets.gen.dart';
import 'package:duo_app/pages/home/home_page.dart';
import 'package:duo_app/pages/mistakes/mistakes_page.dart';
import 'package:duo_app/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<AnimationController> _iconAnimationControllers;
  late List<Animation<double>> _iconScaleAnimations;
  late List<Animation<double>> _iconBounceAnimations;

  final List<Widget> _pages = [
    const HomePage(),
    const MistakesPage(),
    const ProfilePage(),
  ];

  final List<String> _labels = ['Home', 'Mistakes', 'Profile'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize animation controllers for each icon
    _iconAnimationControllers = List.generate(
      _pages.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    // Initialize scale animations
    _iconScaleAnimations = _iconAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Initialize bounce animations
    _iconBounceAnimations = _iconAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    // Animate the first icon
    _iconAnimationControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _iconAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == _currentIndex) return;

    setState(() {
      // Reset previous icon animation
      _iconAnimationControllers[_currentIndex].reverse();

      _currentIndex = index;

      // Animate new icon
      _iconAnimationControllers[index].forward();
    });

    // Animate page transition
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_pages.length, (index) {
                return _buildNavItem(index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final icons = [
      Assets.navigationIcons.navHome,
      Assets.navigationIcons.navRemove,
      Assets.navigationIcons.navUser,
    ];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onDestinationSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _iconAnimationControllers[index],
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              tween: Tween<double>(
                begin: isSelected ? 0.0 : 1.0,
                end: isSelected ? 1.0 : 0.0,
              ),
              builder: (context, value, child) {
                return Container(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * value,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        Colors.transparent,
                        AppColors.onSelection,
                        value,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale:
                              1.0 +
                              (_iconScaleAnimations[index].value - 1.0) *
                                  value *
                                  0.5,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              -3 * _iconBounceAnimations[index].value * value,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Image.asset(
                                icons[index].path,
                                width: 26,
                                height: 26,
                              ),
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 8 * value),
                          AnimatedOpacity(
                            opacity: value,
                            duration: const Duration(milliseconds: 300),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1976D2),
                              ),
                              child: Text(_labels[index]),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
