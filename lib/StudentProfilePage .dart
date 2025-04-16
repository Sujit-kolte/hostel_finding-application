import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// MODEL CLASS
class StudentData {
  String name;
  String interest;
  String skills;
  String college;
  String branch;
  String mobile;
  String hostelName;
  String rent;
  String address;
  List<String> photos;
  List<String> features;
  List<String> rules;

  StudentData({
    required this.name,
    required this.interest,
    required this.skills,
    required this.college,
    required this.branch,
    required this.mobile,
    required this.hostelName,
    required this.rent,
    required this.address,
    required this.photos,
    required this.features,
    required this.rules,
  });

  factory StudentData.fromMap(Map<dynamic, dynamic> data) {
    return StudentData(
      name: data['name'] ?? '',
      interest: data['interests'] ?? '',
      skills: data['skills'] ?? '',
      college: data['college'] ?? '',
      branch: data['branch'] ?? '',
      mobile: data['mobile'] ?? '',
      hostelName: data['hostelName'] ?? '',
      rent: data['rent'] ?? '',
      address: data['address'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      features: List<String>.from(data['features'] ?? []),
      rules: List<String>.from(data['rules'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'interests': interest,
      'skills': skills,
      'college': college,
      'branch': branch,
      'mobile': mobile,
      'hostelName': hostelName,
      'rent': rent,
      'address': address,
      'photos': photos,
      'features': features,
      'rules': rules,
    };
  }
}

// SERVICE CLASS
class StudentDataService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<StudentData?> fetchStudentData() async {
    if (_user == null) return null;
    final snapshot = await _ref.child('users').child(_user!.uid).get();
    if (snapshot.exists) {
      return StudentData.fromMap(snapshot.value as Map<dynamic, dynamic>);
    }
    return null;
  }

  Future<void> saveStudentData(StudentData data) async {
    if (_user == null) return;
    await _ref.child('users').child(_user!.uid).update(data.toMap());
  }
}

// UI PAGE
class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({Key? key}) : super(key: key);

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();

  String userName = '';
  String userAbout = '';
  bool isLoading = true;
  bool isEditable = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final dataService = StudentDataService();
    final studentData = await dataService.fetchStudentData();

    if (studentData == null) {
      setState(() {
        errorMessage = 'Failed to fetch user data.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      userName = studentData.name;
      userAbout = studentData.interest;
      collegeController.text = studentData.college;
      interestController.text = studentData.interest;
      skillsController.text = studentData.skills;
      isLoading = false;
    });
  }

  Future<void> _saveProfileChanges() async {
    final dataService = StudentDataService();

    final updatedData = StudentData(
      name: userName,
      interest: interestController.text,
      skills: skillsController.text,
      college: collegeController.text,
      branch: '',
      mobile: '',
      hostelName: '',
      rent: '',
      address: '',
      photos: [],
      features: [],
      rules: [],
    );

    try {
      await dataService.saveStudentData(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      setState(() {
        isEditable = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF919DFF),
      body: SafeArea(
        child: Stack(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
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
                                userName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userAbout,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildLabeledTextField(
                                'College:',
                                collegeController,
                              ),
                              const SizedBox(height: 20),
                              _buildLabeledTextField(
                                'Interests:',
                                interestController,
                              ),
                              const SizedBox(height: 20),
                              _buildLabeledTextField(
                                'Skills:',
                                skillsController,
                              ),
                              const Spacer(),
                              const SizedBox(height: 0), // moved up
                              ElevatedButton(
                                onPressed:
                                    isEditable ? _saveProfileChanges : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 14,
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            Positioned(
              top: 250,
              right: 20,
              child: IconButton(
                icon: Icon(
                  isEditable ? Icons.lock_open : Icons.edit,
                  color: Colors.white,
                ),
                tooltip: isEditable ? 'Disable Edit' : 'Enable Edit',
                onPressed: () {
                  setState(() {
                    isEditable = !isEditable;
                  });
                },
              ),
            ),
          ],
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
          enabled: isEditable,
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
