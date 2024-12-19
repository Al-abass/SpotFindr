import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotfinder/pages/post_detail_page.dart';
import 'package:spotfinder/components/wall_post.dart'; // Assuming you have a WallPost component

class LikedPostsPage extends StatefulWidget {
  const LikedPostsPage({super.key});

  @override
  State<LikedPostsPage> createState() => _LikedPostsPageState();
}

class _LikedPostsPageState extends State<LikedPostsPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Function to like/unlike a post
  Future<void> likePost(String postId) async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("User Posts").doc(postId);

    // Get the current post data
    DocumentSnapshot postSnapshot = await postRef.get();
    if (postSnapshot.exists) {
      Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;

      // Get the list of users who have liked the post
      List<dynamic> likedBy = postData['LikedBy'] ?? [];

      // Check if the current user has already liked the post
      if (likedBy.contains(currentUser.email)) {
        // User has already liked, so we undo the like (remove user from the "LikedBy" array)
        likedBy.remove(currentUser.email);

        // Update the "Likes" count and "LikedBy" array
        await postRef.update({
          'Likes': FieldValue.increment(-1), // Decrease the like count
          'LikedBy': likedBy, // Remove the user's email from the "LikedBy" array
        });
      } else {
        // User has not liked yet, so we add the like (add user to the "LikedBy" array)
        likedBy.add(currentUser.email);

        // Update the "Likes" count and "LikedBy" array
        await postRef.update({
          'Likes': FieldValue.increment(1), // Increase the like count
          'LikedBy': likedBy, // Add the user's email to the "LikedBy" array
        });
      }
    }
  }

  // Function to navigate to post details page
  void navigateToPostDetail(String postId, String postMessage, String postUser,
      List<dynamic> comments) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(
          postId: postId,
          postMessage: postMessage,
          postUser: postUser,
          onLike: () => likePost(postId),
          comments: comments,
          onComment: (commentText) => addComment(postId, commentText),
        ),
      ),
    );
  }

  // Function to add a comment to a post
  Future<void> addComment(String postId, String commentText) async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("User Posts").doc(postId);

    // Add the new comment to the "Comments" array
    await postRef.update({
      'Comments': FieldValue.arrayUnion([commentText]),
      'CommentsCount': FieldValue.increment(1), // Increment the comment count
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liked Posts")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("User Posts")
            .where('LikedBy', arrayContains: currentUser.email) // Filter posts liked by the current user
            .orderBy("Timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final post = snapshot.data!.docs[index];
                final data = post.data();
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
                  onLike: () => likePost(postId),
                  onComment: (commentText) => navigateToPostDetail(
                    postId,
                    message,
                    userEmail,
                    data['Comments'] ?? [],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
