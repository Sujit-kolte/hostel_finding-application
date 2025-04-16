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
  List<Map<dynamic, dynamic>> hostels = [];

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _fetchHostels();
  }

  Future<void> _fetchHostels() async {
    try {
      final hostelsSnapshot = await _databaseRef.child('hostels').get();
      if (hostelsSnapshot.exists) {
        final data = hostelsSnapshot.value as Map<dynamic, dynamic>;
        setState(() {
          hostels =
              data.entries.map((entry) {
                return {
                  'id': entry.key,
                  ...Map<dynamic, dynamic>.from(entry.value),
                };
              }).toList();
        });
      }
    } catch (e) {
      print('Error fetching hostels: $e');
    }
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

  Widget _buildHostelCard(Map<dynamic, dynamic> hostel) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child:
                hostel['imageurl'] != null
                    ? Image.network(
                      hostel['imageurl'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                    : Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.home,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
          ),

          // Details Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${hostel['name'] ?? 'Not Available'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Rent: ${hostel['rent'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                SizedBox(height: 8),
                Text(
                  'Distance: ${hostel['distance'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: hostels.length,
                    itemBuilder: (context, index) {
                      return _buildHostelCard(hostels[index]);
                    },
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
                              _buildSidebarButton("Logout", Icons.logout),
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
