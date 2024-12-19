import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/components/wall_post.dart';
import 'package:spotfinder/pages/post_detail_page.dart'; // Assuming you have a PostDetailsPage

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];
  String searchTerm = '';
  List<DocumentSnapshot> filteredPosts = [];
  List<DocumentSnapshot> allPosts = [];

  @override
  void initState() {
    super.initState();
    loadRecentSearches();
    fetchPosts();
  }

  // Load recent searches from Firestore
  void loadRecentSearches() {
    FirebaseFirestore.instance
        .collection('recent_searches')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          recentSearches = List<String>.from(doc['searches']);
        });
      }
    });
  }

  // Fetch all posts initially
  void fetchPosts() {
    FirebaseFirestore.instance
        .collection("User Posts")
        .orderBy("Timestamp", descending: true)
        .get()
        .then((snapshot) {
      setState(() {
        allPosts = snapshot.docs;
        filteredPosts = allPosts; // Initially show all posts
      });
    });
  }

  // Save search term to recent searches
  void saveRecentSearch(String searchTerm) {
    if (!recentSearches.contains(searchTerm)) {
      recentSearches.insert(0, searchTerm);
      if (recentSearches.length > 5) {
        recentSearches.removeLast();
      }
    }

    FirebaseFirestore.instance
        .collection('recent_searches')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'searches': recentSearches});

    setState(() {});
  }

  // Delete a search term from recent searches
  void deleteSearchTerm(int index) {
    setState(() {
      recentSearches.removeAt(index);
    });

    FirebaseFirestore.instance
        .collection('recent_searches')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'searches': recentSearches});
  }

  // Handle search input and filter posts based on the search term
  void onSearch(String query) {
    setState(() {
      searchTerm = query;
      if (searchTerm.isEmpty) {
        // If the search term is empty, show all posts and recent searches
        filteredPosts = allPosts;
      } else {
        filteredPosts = allPosts.where((post) {
          final message = post['Message'].toLowerCase();
          return message.contains(searchTerm.toLowerCase());
        }).toList();
      }
    });
  }

  // Navigate to PostDetailsPage when a post card is tapped
  void navigateToPostDetails(DocumentSnapshot post) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailPage(
            postId: post.id,
            postMessage: post['Message'],
            postUser: post['UserEmail'],
            onLike: () {},
            comments: const [],
            onComment: (String comment) {},
          ), // Your PostDetailsPage
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                
                hintText: 'Search for spots...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    onSearch(_searchController.text.trim());
                    if (_searchController.text.isNotEmpty) {
                      saveRecentSearch(_searchController.text.trim());
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Theme.of(context).colorScheme.primary,
              ),
              onChanged: (value) {
                onSearch(value.trim()); // Trigger search as the user types
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  saveRecentSearch(value);
                  _searchController.clear();
                }
              },
            ),
            const SizedBox(height: 20),
            searchTerm.isEmpty
                ? const Text(
                    'Recent Searches',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : const SizedBox(),
            const SizedBox(height: 10),
            // Show recent searches if the search term is empty
            searchTerm.isEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: recentSearches.length,
                      itemBuilder: (context, index) {
                        final searchTerm = recentSearches[index];
                        return ListTile(
                          title: Text(searchTerm),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => deleteSearchTerm(index),
                          ),
                          onTap: () {
                            _searchController.text = searchTerm;
                            onSearch(searchTerm);
                          },
                        );
                      },
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        final likedBy =
                            List<String>.from((post.data() as Map<String, dynamic>)['LikedBy'] ?? []);
                        return GestureDetector(
                          onTap: () => navigateToPostDetails(post), // Navigate on tap
                          child: WallPost(
                            message: post['Message'],
                            user: post['UserEmail'],
                            postId: post.id,
                            likedBy: likedBy,
                            imageUrl: post['ImageUrl'] ?? null,
                            likes: 0,
                            commentsCount: 0,
                            onLike: () {},
                            onComment: (String comment) {},
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
