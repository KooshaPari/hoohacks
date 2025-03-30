import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      // In a real app, you would implement email sending logic here.
      // For now, just simulate success and show a message.
      setState(() {
        _emailSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email requested for $email (stub)')),
      );
      // Optionally, navigate back or disable the button after sending
    }
  }

   @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Enter your email address to receive a password reset link.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                     return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _emailSent ? null : _sendResetEmail, // Disable button after sending
                child: Text(_emailSent ? 'Reset Email Sent' : 'Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}