import 'package:flutter/material.dart';
import 'login_page.dart'; // Import Login Page for navigation

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDrawerOpen = false; // Sidebar is hidden initially

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen; // Toggle sidebar visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Search Box & Menu Button
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // Search Box
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

                      // Menu Button (Sidebar Toggle)
                      IconButton(
                        icon: Icon(Icons.menu, size: 30),
                        onPressed: toggleDrawer,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Sidebar (Appears on Right Below Button)
            Positioned(
              top: 80, // Space from top
              right: 10, // Align to right
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width:
                    isDrawerOpen ? screenWidth * 0.4 : 0, // 40% width when open
                height:
                    isDrawerOpen
                        ? screenHeight * 0.4
                        : 0, // 40% height when open
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
                child: SingleChildScrollView(
                  child:
                      isDrawerOpen
                          ? Column(
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
                          )
                          : SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar Button Function
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
          toggleDrawer(); // Close sidebar when clicked

          // Navigate to Login Page
          if (text == "Login") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        },
      ),
    );
  }
}
