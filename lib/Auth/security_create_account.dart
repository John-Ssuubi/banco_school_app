import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/Auth/security_form.dart';
import 'package:banco_mobile/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SecurityCreateAccount extends StatefulWidget {
  const SecurityCreateAccount({super.key});

  @override
  State<SecurityCreateAccount> createState() => _SecurityCreateAccountState();
}

class _SecurityCreateAccountState extends State<SecurityCreateAccount> {
  // 1. Separate controller for "Retype Password"
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();

  // 2. GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers to free up memory
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  // Helper function for the button's onPressed
  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      // If validation passes (passwords match and other fields are valid)
      // Perform account creation logic here (e.g., Firebase Auth)
      // Then navigate:
      try {
        FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SecurityForm()),
        );
      } catch (e) {
        // Handle errors here, e.g., show a snackbar
        if (kDebugMode) {
          print('Error creating account');
        }
        // showsnackBar(context, 'Error creating account: $e');
      }
    }
  }

  // Custom Input Decoration for reuse
  InputDecoration _customDecoration({required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: mainColor,
        fontWeight: FontWeight.bold,
        fontSize: normalFontSize,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainColor),
      ),
      errorBorder: OutlineInputBorder(
        // Added for better error display
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Added for better error display
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Banco Mobile")),
      // 2. Wrap content in Form widget
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0), // Added padding to ListView
          children: [
            Column(
              children: [
                Text(
                  'Create Account', // Note: Title says 'LogIn' but widget is 'SecurityCreateAccount'
                  style: TextStyle(
                    color: mainColor,
                    fontSize: largefonts,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field (using TextFormField)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _customDecoration(labelText: 'Email'),
                  style: TextStyle(color: mainColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email format check
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Create Password Field (using TextFormField)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _customDecoration(labelText: 'Create Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please create a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Retype Password Field (using TextFormField with validation)
                TextFormField(
                  controller:
                      _retypePasswordController, // Use separate controller
                  obscureText: true,
                  decoration: _customDecoration(labelText: 'Retype Password'),
                  // 4. Validation logic for password match
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please retype your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match'; // This is the core validation
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ElevatedButton
                ElevatedButton(
                  // 5. Call validation function
                  onPressed: _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        mainColor, // Use mainColor for button background
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Create Account',
                      style: TextStyle(fontSize: normalFontSize),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // LogIn InkWell
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthStudent(),
                      ),
                    );
                  },
                  child: Text(
                    'Already have an account? LogIn',
                    style: TextStyle(color: mainColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
