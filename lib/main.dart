import 'package:flutter/material.dart';
import 'package:spotfinder/auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spotfinder/theme/dark_theme.dart';
import 'package:spotfinder/theme/light_theme.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://ooekznsaamtgfelkncvi.supabase.co', // Replace with your Supabase project URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vZWt6bnNhYW10Z2ZlbGtuY3ZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwOTA3MDIsImV4cCI6MjA0OTY2NjcwMn0.PpdivQPZ9JHmG5r4wTnJjPrn2zmeLcpMmQ1s9XIiTLs', // Replace with your Supabase anon key
    );
  } catch (e) {
    // Handle errors in initialization  
    print('Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const AuthPage(),
    );
  }
}
