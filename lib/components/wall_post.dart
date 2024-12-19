import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart'; // Import the share package
import 'package:spotfinder/pages/post_detail_page.dart'; // Import the PostDetailsPage

class WallPost extends StatelessWidget {
  final String message;
  final String user;
  final String? imageUrl;
  final int likes;
  final int commentsCount;
  final String postId;
  final List<String> likedBy;
  final VoidCallback onLike;
  final Function(String) onComment; // Can also be used for navigation

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
    bool isLikedByUser =
        likedBy.contains(FirebaseAuth.instance.currentUser?.email);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(
              postId: postId, // Pass the post ID
              postMessage: message, // Pass the post message
              postUser: user, // Pass the user
              imageUrl: imageUrl, // Pass the image URL here
              onLike: onLike, // Pass the onLike callback
              onComment: (comment) =>
                  onComment(comment), // Pass the onComment callback
              comments: const [],
            ),
          ),
        );
      },
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for Avatar and User Name
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color.fromARGB(255, 211, 211, 211),
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                  const SizedBox(
                      width: 12), // Add spacing between avatar and name
                  Text(
                    user,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                  height: 10), // Add spacing between user info and message
              Text(message),
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    child: Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover, // Ensures image scales properly
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onLike,
                        icon: Icon(
                          isLikedByUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isLikedByUser ? Colors.red : Colors.grey,
                        ),
                      ),
                      Text('$likes Likes'),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.comment, color: Colors.green),
                      SizedBox(width: 5),
                      Text('Comment'),
                    ],
                  ),
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.blue),
                    onPressed: () {
                      String shareContent = message;
                      if (imageUrl != null) {
                        shareContent +=
                            '\n$imageUrl'; // Append image URL if available
                      }
                      Share.share(shareContent); // Share the message
                    },
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
