import 'package:flutter/material.dart';
import 'package:hostel_finding/OwnerProfilePage%20.dart';
import 'package:hostel_finding/StudentProfilePage%20.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum UserRole { student, owner }

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  UserRole? _selectedRole;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Future<void> signUpUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      // Step 1: Create user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Step 2: Save user data in Firebase Realtime Database
      await _databaseRef.child('users').child(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': _selectedRole == UserRole.student ? 'student' : 'owner',
        'createdAt': ServerValue.timestamp,
      });

      // Step 3: Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Account created successfully!")));

      // Step 4: Navigate based on role
      if (_selectedRole == UserRole.student) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StudentProfilePage()),
        );
      }
      if (_selectedRole == UserRole.owner) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OwnerProfilePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF949CFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, size: 70, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Role Selection
            RadioListTile<UserRole>(
              title: const Text(
                "Student",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: UserRole.student,
              groupValue: _selectedRole,
              onChanged: (UserRole? value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
            RadioListTile<UserRole>(
              title: const Text(
                "Owner",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: UserRole.owner,
              groupValue: _selectedRole,
              onChanged: (UserRole? value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUpUser, // Simplified - just call signUpUser
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5ECDF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
