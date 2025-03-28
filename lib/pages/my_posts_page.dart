// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/components/wall_post.dart'; // Import your WallPost widget

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  _MyPostsPageState createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  Future<void> _deletePost(BuildContext context, String postId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Save reference

    try {
      await FirebaseFirestore.instance
          .collection('User Posts')
          .doc(postId)
          .delete();

      if (mounted) {
        setState(() {
          // Trigger UI update (StreamBuilder will pick it up)
        });

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editPost(BuildContext context, String postId) async {
    final postDoc =
        FirebaseFirestore.instance.collection('User Posts').doc(postId);
    final postData = await postDoc.get();

    if (!postData.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch post data for editing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = postData.data() as Map<String, dynamic>;
    final TextEditingController messageController =
        TextEditingController(text: data['Message']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Post',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16),
                ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Set the background color here
                ),
                onPressed: () async {
                  final updatedMessage = messageController.text.trim();

                  if (updatedMessage.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message cannot be empty!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await postDoc.update({'Message': updatedMessage});
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update post: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String postId) {
    // Ensure the dialog only interacts with valid widget context
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content:
              const Text('Are you sure you want to permanently delete this post?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey, // Gray "No" button
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (mounted) Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  _deletePost(context, postId); // Perform the delete action
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: const Text('You are not logged in!'),
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

              return Column(
                children: [
                  WallPost(
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
                    onDelete: () => _showDeleteConfirmationDialog(context, postId),
                    onEdit: () => _editPost(context, postId),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
