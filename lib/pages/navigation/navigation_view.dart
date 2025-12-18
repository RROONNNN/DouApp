// navigation_view.dart
import 'package:duo_app/common/resources/app_colors.dart';
import 'package:duo_app/gen/assets.gen.dart';
import 'package:duo_app/pages/home/home_page.dart';
import 'package:duo_app/pages/leaderboard/leaderboard_page.dart';
import 'package:duo_app/pages/mistakes/mistakes_page.dart';
import 'package:duo_app/pages/knowledge/knowledge_page.dart';
import 'package:duo_app/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),

    const MistakesPage(),

    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 2)),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.background,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          height: 60,
          indicatorColor: AppColors.onSelection,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: [
            NavigationDestination(
              icon: Image.asset(
                Assets.navigationIcons.navHome.path,
                width: 24,
                height: 24,
              ),
              label: 'Home',
            ),
            // NavigationDestination(
            //   icon: Image.asset(
            //     Assets.navigationIcons.navGraph.path,
            //     width: 24,
            //     height: 24,
            //   ),
            //   label: 'Leaderboard',
            // ),
            NavigationDestination(
              icon: Image.asset(
                Assets.navigationIcons.navRemove.path,
                width: 24,
                height: 24,
              ),
              label: 'Mistakes',
            ),
            // NavigationDestination(
            //   icon: Image.asset(
            //     Assets.navigationIcons.navInfo.path,
            //     width: 24,
            //     height: 24,
            //   ),
            //   label: 'Knowledge',
            // ),
            NavigationDestination(
              icon: Image.asset(
                Assets.navigationIcons.navUser.path,
                width: 24,
                height: 24,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
    );
  }
}
