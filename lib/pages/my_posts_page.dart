import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/components/wall_post.dart'; // Import your WallPost widget

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('You are not logged in!'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Posts"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("User Posts")
            .where('UserEmail', isEqualTo: currentUser.email) // Filter by user email
            .orderBy('Timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final message = data['Message'] ?? 'No message';
              final userEmail = data['UserEmail'] ?? 'Unknown user';
              final imageUrl = data['ImageUrl'];
              final likes = data['Likes'] ?? 0;
              final commentsCount = data['CommentsCount'] ?? 0;
              final postId = post.id;
              final likedBy = List<String>.from(data['LikedBy'] ?? []);

              return WallPost(
                message: message,
                user: userEmail,
                imageUrl: imageUrl,
                likes: likes,
                commentsCount: commentsCount,
                postId: postId,
                likedBy: likedBy,
                onLike: () {
                  // Implement like functionality here
                },
                onComment: (commentText) {
                  // Implement comment functionality here
                },
              );
            },
          );
        },
      ),
    );
  }
}
