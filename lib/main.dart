
import 'package:flutter/material.dart';
import 'package:offline_posts_manager/database/database_helper.dart';
import 'package:offline_posts_manager/screens/home_screen.dart';

void main() {
  // Initialize database for web support
  DatabaseHelper.init();
  
  runApp(const OfflinePostsManager());
}

class OfflinePostsManager extends StatelessWidget {
  const OfflinePostsManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Posts Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}