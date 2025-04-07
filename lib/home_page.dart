import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hostel_finding/OwnerProfilePage%20.dart';
import 'package:hostel_finding/StudentProfilePage%20.dart';
import 'package:hostel_finding/login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDrawerOpen = false;
  String? userRole;
  bool isLoading = true;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final userSnapshot =
          await _databaseRef.child('users').child(currentUser!.uid).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        setState(() {
          userRole = userData['role']?.toString();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  void _navigateToProfile() {
    if (userRole == 'student') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StudentProfilePage()),
      );
    } else if (userRole == 'owner') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OwnerProfilePage()),
      );
    } else {
      // Handle case where role isn't set or user isn't logged in
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login first')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search College...",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.menu, size: 30),
                        onPressed: toggleDrawer,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Sidebar
            Positioned(
              top: 80,
              right: 10,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: isDrawerOpen ? screenWidth * 0.4 : 0,
                height: isDrawerOpen ? screenHeight * 0.4 : 0,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              _buildSidebarButton("Home", Icons.home),
                              SizedBox(height: 10),
                              _buildSidebarButton("Login", Icons.login),
                              SizedBox(height: 10),
                              _buildSidebarButton("Profile", Icons.person),
                              SizedBox(height: 10),
                              _buildSidebarButton(
                                "Notifications",
                                Icons.notifications,
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarButton(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          minimumSize: Size(double.infinity, 40),
        ),
        icon: Icon(icon),
        label: Text(text),
        onPressed: () {
          toggleDrawer();

          if (text == "Login") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else if (text == "Profile") {
            _navigateToProfile();
          }
        },
      ),
    );
  }
}
