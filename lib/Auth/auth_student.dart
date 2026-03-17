// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Auth/create_account_parent.dart';
import 'package:banco_mobile/Auth/staff_select.dart';
import 'package:banco_mobile/main.dart';
import 'package:banco_mobile/parentFcmToken.dart';
import 'package:banco_mobile/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthStudent extends StatefulWidget {
  const AuthStudent({super.key});

  @override
  State<AuthStudent> createState() => _AuthStudentState();
}

class _AuthStudentState extends State<AuthStudent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String error = "";
  bool isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
     GoogleSignIn.instance.initialize();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _friendlyAuthMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Login failed. Please try again.';
    }
  }

Future<void> signInWithGoogle() async {
  try {
    setState(() {
      isLoading = true;
      error = "";
    });

    await GoogleSignIn.instance.initialize();

    final GoogleSignInAccount account =
        await GoogleSignIn.instance.authenticate(scopeHint: ['email']);

    final GoogleSignInClientAuthorization? auth =
        await account.authorizationClient.authorizationForScopes(
      ['email', 'profile'],
    );

    if (auth == null) {
      setState(() {
        error = "Google authorization failed.";
      });
      return;
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: account.authentication.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    await setupFcm();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MyApp()),
    );
  } catch (e) {
    setState(() {

      error = "Google sign-in failed.";
      print("Google sign-in error: $e");
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  Future<void> login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        error = "Please enter email and password.";
      });
      return;
    }


    try {
      setState(() {
        isLoading = true;
        error = "";
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await setupFcm();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyApp()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = _friendlyAuthMessage(e.code);
      });
    } catch (_) {
      setState(() {
        error = "Something went wrong.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> forgotPassword() async {
    TextEditingController emailReset = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          controller: emailReset,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Enter your email",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: emailReset.text.trim(),
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password reset email sent."),
                  ),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to send reset email."),
                  ),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Future<void> showAccountType() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mainColor,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          content: SizedBox(
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateAccountParent(),
                      ),
                    );
                  },
                  child: Column(
                    children: const [
                      Icon(Icons.school, size: 80, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Parent",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StaffSelect(),
                      ),
                    );
                  },
                  child: Column(
                    children: const [
                      Icon(Icons.people, size: 80, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Staff",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(""),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 270,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Welcome!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style:  TextStyle(color: mainColor),
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 215,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                    ),
                    onPressed: login,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Log In",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 25),
              SizedBox(
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: signInWithGoogle,
                  icon: Image.asset("assets/googlelogo.png", height: 22),

                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    side: BorderSide(color: Colors.grey),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
                 SizedBox(height: 20),

                InkWell(
                  onTap: showAccountType,
                  child: const Text("Don't have an account? Sign Up"),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: forgotPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.red),
                  ),
                ),

                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}