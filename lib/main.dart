import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import generated config file
import 'splash.dart'; // Your splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Replace your current database reference with:
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://hostel-finder-65872-default-rtdb.firebaseio.com/",
      ).ref();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(), // Start with splash screen
    );
  }
}
