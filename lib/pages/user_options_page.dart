import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotfinder/pages/liked_posts.dart';
import 'package:spotfinder/pages/my_posts_page.dart';

class UserOptionsPage extends StatelessWidget {
  const UserOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Check if the theme is light or dark
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Options"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Profile Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF22577a),
              child: currentUser?.photoURL != null
                  ? CircleAvatar(
                      radius: 58,
                      backgroundImage: NetworkImage(currentUser!.photoURL!),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(height: 20),
            // Email Text
            Text(
              currentUser?.email ?? "No Email",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // My Posts Button - Adjusted based on theme
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyPostsPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                child: const Text("My Posts"),
              ),
            ),
            const SizedBox(height: 16),
            // Liked Posts Button - Adjusted based on theme
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LikedPostsPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                child: const Text("Liked Posts"),
              ),
            ),
            const Spacer(), // Push the sign-out button to the bottom
            const SizedBox(height: 16),
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context); // Navigate back to the login page
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.red,
                  ),
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
