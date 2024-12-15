import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final commentController = TextEditingController();

  Future<void> addComment() async {
    if (commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection("Comments").add({
        "PostId": widget.postId,
        "UserEmail": FirebaseAuth.instance.currentUser?.email,
        "Comment": commentController.text,
        "Timestamp": Timestamp.now(),
      });

      // Update comment count in the post
      DocumentReference postRef = FirebaseFirestore.instance
          .collection("User Posts")
          .doc(widget.postId);
      postRef.update({
        'CommentsCount': FieldValue.increment(1),
      });

      commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        backgroundColor: const Color(0xFF22577a),
      ),
      body: Column(
        children: [
          // Display the post message here
          // Display the comments
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Comments")
                  .where("PostId", isEqualTo: widget.postId)
                  .orderBy("Timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final comment = snapshot.data!.docs[index];
                      final commentText = comment['Comment'];
                      final userEmail = comment['UserEmail'];

                      return ListTile(
                        title: Text(commentText),
                        subtitle: Text(userEmail),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: addComment,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
