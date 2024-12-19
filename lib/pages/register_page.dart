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
    // Dismiss loading circle
    Navigator.pop(context);

    // Display error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Passwords don't match!"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  try {
    // Try creating user
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
    if (e.code == 'email-already-in-use') {
      errorMessage = 'The email is already in use. Try another.';
    } else if (e.code == 'weak-password') {
      errorMessage = 'The password is too weak. Use a stronger password.';
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
      resizeToAvoidBottomInset: true,
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

                  const SizedBox(height: 30),

                  // Welcome message
                  const Text(
                    "Let's create an account for you!",
                    style: TextStyle(
                      color: Color(0xFF22577a), // Primary dark blue
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Email textfield
                  MyTextField(
                    controller: emailTextController,
                    hintText: "Email",
                    obscureText: false,
                    readOnly: false,
                  ),

                  const SizedBox(height: 10),

                  // Password textfield
                  MyTextField(
                    controller: passwordTextController,
                    hintText: "Password",
                    obscureText: true,
                    readOnly: false,
                  ),

                  const SizedBox(height: 10),

                  // Confirm password textfield
                  MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: "Confirm Password",
                    obscureText: true,
                    readOnly: false,
                  ),

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
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Color(0xFF22577a), // Primary dark blue
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login now",
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
