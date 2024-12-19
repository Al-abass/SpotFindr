import 'package:flutter/material.dart';
import 'package:spotfinder/pages/liked_posts.dart';
import 'package:spotfinder/pages/my_posts_page.dart';

class UserOptionsPage extends StatelessWidget {
  const UserOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the theme is light or dark
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Options"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    isDarkMode ? Colors.grey[300] : Colors.grey[700], // Darker for light mode, lighter for dark mode
                  ),
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
                    isDarkMode ? Colors.grey[300] : Colors.grey[700], // Darker for light mode, lighter for dark mode
                  ),
                ),
                child: const Text("Liked Posts"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
