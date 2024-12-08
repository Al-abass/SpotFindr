import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/components/button.dart';
import 'package:spotfinder/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // Sign user up
  void signUp() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Make sure passwords match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      // Pop loading circle
      Navigator.pop(context);
      // Display error message
      displayMessage("Passwords don't match!");
      return;
    }

    // Try creating user
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      Navigator.pop(context);
      // Display error message
      displayMessage(e.code);
    }
  }

  // Display a dialog message
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        resizeToAvoidBottomInset: true,
        body: SafeArea(
  child: Center(
    child: SingleChildScrollView( // Add this
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SpotFinder",
              style: TextStyle(
                fontSize: 32, // Adjust the size as needed
                fontWeight: FontWeight.bold,
                color: Colors.black, // Choose a color that fits your theme
              ),
            ),

            const SizedBox(height: 20), // Add some spacing

            // Logo
            const Icon(
              Icons.search,
              size: 100,
            ),

            const SizedBox(height: 30),

            // Welcome message
            Text(
              "Let's create an account for you!",
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 25),

            // Email textfield
            MyTextField(
                controller: emailTextController,
                hintText: "Email",
                obscureText: false),

            const SizedBox(height: 10),

            // Password textfield
            MyTextField(
                controller: passwordTextController,
                hintText: "Password",
                obscureText: true),

            const SizedBox(height: 10),

            // Confirm password textfield
            MyTextField(
                controller: confirmPasswordTextController,
                hintText: "Confirm Password",
                obscureText: true),

            const SizedBox(height: 25),

            // Sign up button
            MyButton(
              onTap: signUp,
              text: "Sign Up",
            ),

            const SizedBox(height: 25),

            // Go to login page
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    "Login now",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
        ),
      ),
    );
  }
}
