import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hostel_finding/hostelmanage.dart';

// MODEL CLASS
class OwnerData {
  String name;
  String contact;
  String hostelName;
  String rent;
  String address;
  String website;
  List<String> features;
  List<String> rules;
  List<String> photos;

  OwnerData({
    required this.name,
    required this.contact,
    required this.hostelName,
    required this.rent,
    required this.address,
    required this.website,
    required this.features,
    required this.rules,
    required this.photos,
  });

  factory OwnerData.fromMap(Map<dynamic, dynamic> data) {
    return OwnerData(
      name: data['name'] ?? '',
      contact: data['contact'] ?? '',
      hostelName: data['hostelName'] ?? '',
      rent: data['rent'] ?? '',
      address: data['address'] ?? '',
      website: data['website'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      rules: List<String>.from(data['rules'] ?? []),
      photos: List<String>.from(data['photos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'hostelName': hostelName,
      'rent': rent,
      'address': address,
      'website': website,
      'features': features,
      'rules': rules,
      'photos': photos,
    };
  }
}

// SERVICE CLASS
class OwnerDataService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<OwnerData?> fetchOwnerData() async {
    if (_user == null) return null;
    final snapshot = await _ref.child('owners').child(_user!.uid).get();
    if (snapshot.exists) {
      return OwnerData.fromMap(snapshot.value as Map<dynamic, dynamic>);
    }
    return null;
  }
}

// UI PAGE
class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController hostelNameController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOwnerData();
  }

  Future<void> _fetchOwnerData() async {
    final dataService = OwnerDataService();
    final ownerData = await dataService.fetchOwnerData();

    if (ownerData == null) {
      setState(() {
        errorMessage = 'Failed to fetch owner data.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      nameController.text = ownerData.name;
      contactController.text = ownerData.contact;
      hostelNameController.text = ownerData.hostelName;
      rentController.text = ownerData.rent;
      addressController.text = ownerData.address;
      websiteController.text = ownerData.website;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF949DFF),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        nameController.text,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        contactController.text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildLabeledTextField(
                        'Hostel Name:',
                        hostelNameController,
                      ),
                      const SizedBox(height: 20),
                      _buildLabeledTextField('Rent:', rentController),
                      const SizedBox(height: 20),
                      _buildLabeledTextField('Address:', addressController),
                      const SizedBox(height: 20),
                      _buildLabeledTextField('Website:', websiteController),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HostelManagePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Manage Hostel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        TextField(
          controller: controller,
          enabled: false,
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  final TextStyle labelStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

// Dummy placeholder for navigation (you can design this later)
