import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PostDetailPage extends StatefulWidget {
  final String postId; // Firestore document ID of the post
  final String postMessage; // Post content
  final String postUser; // User who posted
  final String? imageUrl; // Optional image URL for the post
  final VoidCallback onLike;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.postMessage,
    required this.postUser,
    this.imageUrl,
    required this.onLike,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  int likes = 0; // Initialize likes (can be fetched dynamically)
  bool isLikedByUser = false; // Track if the post is liked by the user
  bool isLoading = false; // Track loading state for comment submission

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchLikeData();
  }

  // Fetch likes count and check if the user has liked the post
  void _fetchLikeData() async {
    final postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    final snapshot = await postRef.get();
    if (snapshot.exists) {
      final postData = snapshot.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(postData['LikedBy'] ?? []);
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      setState(() {
        likes = postData['Likes'] ?? 0;
        isLikedByUser = likedBy.contains(userEmail);
      });
    }
  }

  // Handle like/unlike action
  void _onLikePost() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    // Get the current post data
    DocumentSnapshot postSnapshot = await postRef.get();
    if (postSnapshot.exists) {
      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>;
      List<dynamic> likedBy = postData['LikedBy'] ?? [];

      // Check if the current user has already liked the post
      if (likedBy.contains(userEmail)) {
        // Undo the like (remove user from the "LikedBy" array)
        likedBy.remove(userEmail);
        setState(() {
          isLikedByUser = false;
          likes--; // Decrease the like count
        });
        // Update the "Likes" count and "LikedBy" array
        await postRef.update({
          'Likes': FieldValue.increment(-1), // Decrease the like count
          'LikedBy': likedBy, // Remove the user's email from the "LikedBy" array
        });
      } else {
        // Add the like (add user to the "LikedBy" array)
        likedBy.add(userEmail);
        setState(() {
          isLikedByUser = true;
          likes++; // Increase the like count
        });
        // Update the "Likes" count and "LikedBy" array
        await postRef.update({
          'Likes': FieldValue.increment(1), // Increase the like count
          'LikedBy': likedBy, // Add the user's email to the "LikedBy" array
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
      ),
      body: Stack(
        children: [
          // Main content of the post and comments
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Post Details
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.postUser,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (widget.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.imageUrl!,
                                    fit: BoxFit.cover,
                                    height: 250,
                                    width: double.infinity,
                                  ),
                                ),
                              const SizedBox(height: 15),
                              Text(
                                widget.postMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),
                        // Actions Row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Like Button and Likes Count
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      _onLikePost();
                                    },
                                    icon: Icon(
                                      isLikedByUser
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLikedByUser
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '$likes', // Display the likes count
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              // Comment Button
                              TextButton.icon(
                                onPressed: () {
                                  // Focus on the comment field
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                icon: const Icon(Icons.comment, color: Colors.green),
                                label: const Text("Comment"),
                              ),
                              // Share Button
                              TextButton.icon(
                                onPressed: () {
                                  // Handle sharing functionality here
                                },
                                icon: const Icon(Icons.share, color: Colors.orange),
                                label: const Text("Share"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Comments Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Comments",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No comments yet."));
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final commentData =
                              comments[index].data() as Map<String, dynamic>;
                          final timestamp =
                              commentData['timestamp'] as Timestamp?;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[400],
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Comment and User Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // User Name (in gray)
                                        Text(
                                          commentData['user'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Comment Text (bold)
                                        Text(
                                          commentData['comment'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Timestamp
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            timestamp != null
                                                ? intl.DateFormat('dd MMM, HH:mm')
                                                    .format(timestamp.toDate())
                                                : '',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          // Full-screen Loading Indicator
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballClipRotateMultiple,
                      colors: const [Colors.green],
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: "Add a comment...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  if (_commentController.text.isNotEmpty) {
                    setState(() {
                      isLoading = true;
                    });

                    // Save the comment
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('comments')
                        .add({
                      'comment': _commentController.text,
                      'timestamp': FieldValue.serverTimestamp(),
                      'user': FirebaseAuth.instance.currentUser!.email,
                    });

                    // Clear the input field
                    _commentController.clear();

                    setState(() {
                      isLoading = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
