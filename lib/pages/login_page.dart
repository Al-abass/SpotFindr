import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotfinder/components/button.dart';
import 'package:spotfinder/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  // Sign user in
void signIn() async {
  // Show loading circle
  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Try signing in
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailTextController.text,
      password: passwordTextController.text,
    );

    // Dismiss loading circle
    if (context.mounted) Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    // Dismiss loading circle
    Navigator.pop(context);

    // Check the error code and display appropriate messages
    String errorMessage;
    if (e.code == 'user-not-found') {
      errorMessage = 'Email does not exist.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Incorrect password.';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'Please enter a valid email address.';
    } else {
      errorMessage = 'An unexpected error occurred. Please try again.';
    }

    // Show the error message in a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFc7f9cc), // Light green background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 20),

                  // Logo
                  Image.asset(
                    'assets/spotfindr_logo.png', // Path to your logo file
                    width: 250, // Adjust the size as needed
                    height: 250, // Adjust the size as needed
                  ),

                  const SizedBox(height: 50),

                  // Welcome Back
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      color: Color(0xFF22577a), // Primary dark blue
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Email TextField
                  MyTextField(
                    controller: emailTextController,
                    hintText: "Email",
                    obscureText: false,
                    readOnly: false,
                  ),

                  const SizedBox(height: 10),

                  // Password TextField
                  MyTextField(
                    controller: passwordTextController,
                    hintText: "Password",
                    obscureText: true,
                    readOnly: false,
                  ),

                  const SizedBox(height: 25),

                  // Sign In Button
                  MyButton(
                    onTap: signIn,
                    text: "Sign In",
                  ),

                  const SizedBox(height: 25),

                  // Register Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Not a member?",
                        style: TextStyle(
                          color: Color(0xFF22577a),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Register now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF38a3a5), // Secondary teal
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
