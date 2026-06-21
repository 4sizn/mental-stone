import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_stone_ui/mental_stone_ui.dart';

import '../../router/app_router.dart';
import '../calendar/calendar_screen.dart';
import '../home/home_screen.dart';
import '../records/records_screen.dart';

/// Bottom-nav host for the three top-level destinations. Detail screens
/// (Record, Analysis, Synthesis, Diary, Profile) are pushed via go_router.
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  NavItem _active = NavItem.home;

  static const _items = [NavItem.home, NavItem.calendar, NavItem.records];

  @override
  Widget build(BuildContext context) {
    final index = _items.indexOf(_active);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: index,
            children: const [
              HomeScreen(showBottomNav: false),
              CalendarScreen(),
              RecordsScreen(showBottomNav: false),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNav(
              active: _active,
              onChanged: (item) => setState(() => _active = item),
            ),
          ),
        ],
      ),
      floatingActionButton: _active == NavItem.home
          ? FloatingActionButton(
              backgroundColor: AppColors.onSurface,
              foregroundColor: AppColors.surface,
              shape: const CircleBorder(),
              onPressed: () => context.push(Routes.record),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

