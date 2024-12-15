import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WallPost extends StatelessWidget {
  final String message;
  final String user;
  final String? imageUrl;
  final int likes;
  final int commentsCount;
  final String postId;
  final List<String> likedBy;
  final VoidCallback onLike;
  final VoidCallback onComment; // Can also be used for navigation

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.imageUrl,
    required this.likes,
    required this.commentsCount,
    required this.postId,
    required this.likedBy,
    required this.onLike,
    required this.onComment,
  });

 


  @override
  Widget build(BuildContext context) {
    bool isLikedByUser = likedBy.contains(FirebaseAuth.instance.currentUser?.email);

    return GestureDetector(
      onTap: onComment, // Navigate to the post details when tapped
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(message),
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.network(imageUrl!),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onLike,
                        icon: Icon(
                          isLikedByUser ? Icons.favorite : Icons.favorite_border,
                          color: isLikedByUser ? Colors.red : Colors.grey,
                        ),
                      ),
                      Text('$likes'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text('$commentsCount'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}