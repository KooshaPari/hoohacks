import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String email; // Add email parameter

  const SettingsPage({super.key, required this.email}); // Make email required

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false; // Placeholder for theme state

  void _changePassword() {
    // Placeholder for change password action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change Password action triggered (stub)')),
    );
  }

  void _toggleTheme(bool value) {
    // Placeholder for theme change action
    setState(() {
      _isDarkMode = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme changed to ${_isDarkMode ? "Dark" : "Light"} (stub)')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green, // Consistent AppBar color
        titleTextStyle: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
         iconTheme: const IconThemeData(
          color: Colors.white, // Set back button color to white
        ),
      ),
      body: ListView( // Use ListView for potentially more settings
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Logged in as'),
            subtitle: Text(widget.email), // Display the email passed from NavBarController
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _changePassword, // Stub function
          ),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            value: _isDarkMode, // Stub state
            onChanged: _toggleTheme, // Stub function
          ),
          // Add more settings options here
        ],
      ),
    );
  }
}
