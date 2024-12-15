import 'package:flutter/material.dart';

class WallPost extends StatelessWidget {
  final String message;
  final String user;
  final int likes;
  final int commentsCount;
  final String? imageUrl; // New field for the image
  final VoidCallback onLike;
  final VoidCallback onComment;

  const WallPost({
    required this.message,
    required this.user,
    required this.likes,
    required this.commentsCount,
    this.imageUrl,
    required this.onLike,
    required this.onComment,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(message),
            if (imageUrl != null) ...[
              const SizedBox(height: 10),
              Image.network(imageUrl!),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onLike,
                  icon: const Icon(Icons.thumb_up),
                  label: Text(likes.toString()),
                ),
                TextButton.icon(
                  onPressed: onComment,
                  icon: const Icon(Icons.comment),
                  label: Text(commentsCount.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
