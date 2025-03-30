import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped; // Added callback for navigation

  const NavBar({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: const NavigationBarThemeData(
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      child: NavigationBar(
        height: MediaQuery.of(context).size.height * 0.07,
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onItemTapped, // Use the callback
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.black),
            selectedIcon: Icon(Icons.home, color: Colors.black),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: Colors.black),
            selectedIcon: Icon(Icons.bar_chart, color: Colors.black),
            label: "Weekly",
          ),
          NavigationDestination(
            icon: Icon(Icons.note_add_outlined, color: Colors.black),
            selectedIcon: Icon(Icons.note_add, color: Colors.black),
            label: "Entries",
          ),
        ],
      ),
    );
  }
}