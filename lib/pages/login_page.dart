import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/components/button.dart';
import 'package:spotfinder/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  //sign user in
  void signIn() async {
    //show loading circle
    showDialog(
      context: context, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      );

    //try sign in
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailTextController.text, 
      password: passwordTextController.text,
      );

      //pop loading circle
      if(context.mounted) Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      //display error message
      displayMessage(e.code);
    }
  }

  //display a dialog message
  void displayMessage(String message){
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App name header
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
                  size: 120,
                ),

                const SizedBox(height: 50),

                // Welcome back message
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 25),

                // Email textfield
                MyTextField(
                  controller: emailTextController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password textfield
                MyTextField(
                  controller: passwordTextController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // Sign in button
                MyButton(
                  onTap: signIn,
                  text: "Sign In",
                ),

                const SizedBox(height: 25),

                // Go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
    );
  }
}
