import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotfinder/components/text_field.dart';
import 'package:spotfinder/components/wall_post.dart';
import 'package:spotfinder/pages/search_page.dart';
import 'package:spotfinder/pages/profile_page.dart';
import 'package:spotfinder/pages/post_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _selectedImage;

  final ImagePicker _imagePicker = ImagePicker();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> postMessage(BuildContext context) async {
    if (textController.text.isNotEmpty || _selectedImage != null) {
      String? publicUrl;

      // Upload image to Supabase if one is selected
      if (_selectedImage != null) {
        publicUrl = await _uploadImagetoSupabase(_selectedImage!);
      }

      // Save text message and image URL to Firestore
      await FirebaseFirestore.instance.collection("User Posts").add({
        "UserEmail": currentUser.email,
        "Message": textController.text,
        "Timestamp": Timestamp.now(),
        "Likes": 0, // Initial like count
        "CommentsCount": 0, // Initial comment count
        "ImageUrl":
            publicUrl ?? '', // Store the public URL or empty if no image
      });

      // Clear inputs
      textController.clear();
      setState(() {
        _selectedImage = null;
      });

      Navigator.pop(context);
    } else {
      // Show an alert if both fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please write a message or select an image.")),
      );
    }
  }

  Future<void> likePost(String postId) async {
    // Update like count
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("User Posts").doc(postId);

    postRef.update({
      'Likes': FieldValue.increment(1),
    });
  }

  Future<void> navigateToPostDetail(String postId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(postId: postId),
      ),
    );
  }

  Future<String?> _uploadImagetoSupabase(File image) async {
    try {
      final fileName =
          'post_images/${DateTime.now().microsecondsSinceEpoch}.jpg';

      // Read the file as Bytes
      final fileBytes = await image.readAsBytes();

      // Upload the file to Supabase
      await Supabase.instance.client.storage
          .from('images') // Replace with your bucket name
          .uploadBinary(fileName, fileBytes);

      // Retrieve the public URL
      final publicUrl = Supabase.instance.client.storage
          .from('images') // Replace with your bucket name
          .getPublicUrl(fileName);

      debugPrint('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  void showPostModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFc7f9cc),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Write something on the wall",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22577a),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: textController,
                  hintText: "Type your message here...",
                  obscureText: false,
                  readOnly: false,
                ),
                const SizedBox(height: 10),
                _selectedImage != null
                    ? Column(
                        children: [
                          Image.file(
                            _selectedImage!,
                            height: 150,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: const Text(
                              "Remove Image",
                              style: TextStyle(color: Color(0xFF38a3a5)),
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.photo),
                        label: const Text("Add Image"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38a3a5),
                          foregroundColor: Colors.white,
                        ),
                      ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => postMessage(context),
                  icon: const Icon(Icons.send),
                  label: const Text("Post"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22577a),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void navigateToSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  void navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFc7f9cc),
      appBar: AppBar(
        title: const Text("Discover"),
        titleTextStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF22577a),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // THE WALL
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("Timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        final data = post.data();
                        final message = data['Message'] ?? 'No message';
                        final userEmail = data['UserEmail'] ?? 'Unknown user';
                        final likes = data['Likes'] ?? 0;
                        final commentsCount = data['CommentsCount'] ?? 0;
                        final postId = post.id;
                        final imageUrl =
                            data['ImageUrl'] ?? ''; // Get the image URL

                        return WallPost(
                          message: message,
                          user: userEmail,
                          likes: likes,
                          commentsCount: commentsCount,
                          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                          onLike: () => likePost(postId),
                          onComment: () => navigateToPostDetail(postId),
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF22577a),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: scrollToTop,
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: navigateToSearchPage,
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: navigateToProfilePage,
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPostModal(context),
        backgroundColor: const Color(0xFF38a3a5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}