import 'package:flutter/material.dart';

class LikedPostsPage extends StatelessWidget {
  const LikedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liked Posts")),
      body: const Center(child: Text("Posts you've liked will be listed here.")),
    );
  }
}