import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailPage extends StatefulWidget {
  final String postId; // Firestore document ID of the post
  final String postMessage; // Post content
  final String postUser; // User who posted
  final String? imageUrl; // Optional image URL for the post
  final VoidCallback onLike;
  final List<dynamic> comments; // Add this line
  final Function(String) onComment;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.postMessage,
    required this.postUser,
    this.imageUrl,
    required this.onLike,
    required this.comments, // Add this line
    required this.onComment,
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
          'LikedBy':
              likedBy, // Remove the user's email from the "LikedBy" array
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

                              Text(
                                widget.postMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 5),

                              // Image widget (remove height constraint)
                              if (widget.imageUrl != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                    child: Image.network(
                                      widget.imageUrl!,
                                      width: double.infinity,
                                      fit: BoxFit
                                          .cover, // Ensures image scales properly
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.broken_image,
                                              size: 50, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 15),
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
                                    onPressed: _onLikePost,
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
                                    '$likes likes',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              // Comment Button
                              TextButton.icon(
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                icon: const Icon(Icons.comment,
                                    color: Colors.green),
                                label: const Text("Comment"),
                              ),
                              // Share Button
                              TextButton.icon(
                                onPressed: () {
                                  String shareContent = widget.postMessage;
                                  if (widget.imageUrl != null) {
                                    shareContent +=
                                        '\n${widget.imageUrl}'; // Append image URL if available
                                  }
                                  Share.share(
                                      shareContent); // Share the message
                                },
                                icon:
                                    const Icon(Icons.share, color: Colors.blue),
                                label: const Text(""),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Comments Section
                  const SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Comments",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('User Posts') // Ensure it's consistent
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
                                    child: const Icon(
                                      Icons.person,
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
                                                ? intl.DateFormat(
                                                        'dd MMM, HH:mm')
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
                  const SizedBox(height: 55),
                ],
              ),
            ),
          ),
          // Full-screen Loading Indicator
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballRotateChase,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Comment input at the bottom of the screen
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_commentController.text.isEmpty) return;

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      // Add comment to Firestore
                      await FirebaseFirestore.instance
                          .collection('User Posts')
                          .doc(widget.postId)
                          .collection('comments')
                          .add({
                        'comment': _commentController.text,
                        'user': FirebaseAuth.instance.currentUser!.email,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Clear the input field after adding the comment
                      _commentController.clear();
                    } catch (e) {
                      print("Error adding comment: $e");
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
