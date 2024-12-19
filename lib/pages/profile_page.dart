import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotfinder/components/text_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final locationController = TextEditingController();
  String email = "";
  String gender = ""; // Initially empty
  bool isEditing = false;
  List<String> genderOptions = ["Male", "Female", "Other"];

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      setState(() {
        email = currentUser.email ?? "";
      });

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        nameController.text = userData['name'] ?? "";
        gender = userData['gender'] ?? ""; // Keep empty if not set
        dobController.text = userData['dob'] ?? "";
        locationController.text = userData['location'] ?? "";
      }
    }
  }

  Future<void> saveUserProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'name': nameController.text,
        'gender': gender,
        'dob': dobController.text,
        'location': locationController.text,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF22577a),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Email Label
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                // Name Field
                MyTextField(
                  controller: nameController,
                  hintText: "Name",
                  obscureText: false,
                  readOnly: !isEditing,
                ),
                const SizedBox(height: 20),
                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: gender.isEmpty ? null : gender,
                  onChanged: isEditing
                      ? (String? newValue) {
                          setState(() {
                            gender = newValue ?? "";
                          });
                        }
                      : null,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Theme.of(context).colorScheme.primary,
                    filled: true,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: const Text(
                        "Select Gender",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ...genderOptions.map((String genderOption) {
                      return DropdownMenuItem<String>(
                        value: genderOption,
                        child: Text(genderOption),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 20),
                // Date of Birth Field
                MyTextField(
                  controller: dobController,
                  hintText: "YYYY-MM-DD",
                  obscureText: false,
                  readOnly: true,
                  suffixIcon: isEditing
                      ? IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.grey),
                          onPressed: () => _selectDate(context),
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                // Location Field
                MyTextField(
                  controller: locationController,
                  hintText: "Location",
                  obscureText: false,
                  readOnly: !isEditing,
                ),
                const SizedBox(height: 30),
                // Save Button
                if (isEditing)
                  ElevatedButton(
                    onPressed: saveUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22577a),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Save"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
