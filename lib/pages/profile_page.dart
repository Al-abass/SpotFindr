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
  String gender = "Male"; // Default gender
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
        gender = userData['gender'] ?? "Male";
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
          backgroundColor: const Color(0xFF22577a),
          foregroundColor: Colors.white,
        ),
        body: Container(
          color: const Color(0xFFc7f9cc),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Name field (editable)
                MyTextField(
                  controller: nameController,
                  hintText: "Name (optional)",
                  obscureText: false,
                  readOnly: false,
                ),
                const SizedBox(height: 20),
                // Email field (read-only)
                MyTextField(
                  controller: TextEditingController(text: email),
                  hintText: "Email",
                  obscureText: false,
                  readOnly: true, // Email is read-only
                ),
                const SizedBox(height: 20),
                // Gender Dropdown field (editable)
                DropdownButtonFormField<String>(
                  value: gender,
                  onChanged: (String? newValue) {
                    setState(() {
                      gender = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Gender",
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  items: genderOptions.map((String genderOption) {
                    return DropdownMenuItem<String>(
                      value: genderOption,
                      child: Text(genderOption),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Date of Birth field with calendar icon (editable, with date picker)
                MyTextField(
                  controller: dobController,
                  hintText: "YYYY-MM-DD",
                  obscureText: false,
                  readOnly:
                      true, // Make it read-only for direct input, but still tappable
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.grey),
                    onPressed: () => _selectDate(
                        context), // Trigger date picker on icon press
                  ),
                ),
                const SizedBox(height: 20),
                // Location field (editable)
                MyTextField(
                  controller: locationController,
                  hintText: "Location (optional)",
                  obscureText: false,
                  readOnly: false,
                ),
                const SizedBox(height: 30),
                // Save button
                Center(
                  child: ElevatedButton(
                    onPressed: saveUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22577a),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        )
      );
  }
}
