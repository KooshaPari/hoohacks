import 'package:flutter/material.dart';
import 'package:healthsync/main.dart'; // Import NavBarController

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  void _createAccountAndNavigate(BuildContext context) {
    // In a real app, you would handle account creation logic here.
    // For this dummy page, we just navigate to the main app page.
    // Pass a dummy email for created accounts
    const dummyEmail = 'created@account.com';
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => NavBarController(email: dummyEmail)),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
         backgroundColor: Colors.green, // Consistent AppBar color
         titleTextStyle: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This is the create account page.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Add dummy form fields if desired, but not required for navigation
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
               const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _createAccountAndNavigate(context),
                child: const Text('Create Account & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}