import 'package:flutter/material.dart';
import 'package:healthsync/main.dart' show NavBarController;

/// A simplified login page for debugging
class BasicLoginPage extends StatefulWidget {
  const BasicLoginPage({super.key});

  @override
  State<BasicLoginPage> createState() => _BasicLoginPageState();
}

class _BasicLoginPageState extends State<BasicLoginPage> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('BasicLoginPage initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthSync'),
        backgroundColor: Colors.green,
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
              const Icon(
                Icons.health_and_safety,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to HealthSync',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your personal health dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
              else
                ElevatedButton(
                  onPressed: _simulateLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Login (Debug Mode)',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  debugPrint('About button pressed');
                  // Show an about dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('About HealthSync'),
                      content: const Text(
                        'HealthSync is a debug version created for troubleshooting iOS issues.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('About'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _simulateLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    debugPrint('Simulating login...');
    
    try {
      // Simulate a network request
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        debugPrint('Login successful, navigating to main screen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavBarController(
              email: 'debug@example.com',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during simulated login: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }
}
