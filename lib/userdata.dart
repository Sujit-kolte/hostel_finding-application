import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  String name;
  String interest;
  String skills;
  String collegeName;
  String branch;
  String mobileNumber;
  String hostelName;
  String rent;
  String address;
  List<String> photos;
  List<String> features;
  List<String> rules;

  UserData({
    required this.uid,
    required this.name,
    required this.interest,
    required this.skills,
    required this.collegeName,
    required this.branch,
    required this.mobileNumber,
    required this.hostelName,
    required this.rent,
    required this.address,
    required this.photos,
    required this.features,
    required this.rules,
  });

  // From Firestore Document
  factory UserData.fromMap(String uid, Map<String, dynamic> data) {
    return UserData(
      uid: uid,
      name: data['name'] ?? '',
      interest: data['interest'] ?? '',
      skills: data['skills'] ?? '',
      collegeName: data['collegeName'] ?? '',
      branch: data['branch'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      hostelName: data['hostelName'] ?? '',
      rent: data['rent'] ?? '',
      address: data['address'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      features: List<String>.from(data['features'] ?? []),
      rules: List<String>.from(data['rules'] ?? []),
    );
  }

  // To Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'interest': interest,
      'skills': skills,
      'collegeName': collegeName,
      'branch': branch,
      'mobileNumber': mobileNumber,
      'hostelName': hostelName,
      'rent': rent,
      'address': address,
      'photos': photos,
      'features': features,
      'rules': rules,
    };
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user data
  Future<UserData?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserData.fromMap(uid, doc.data()!);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  // Update user data
  Future<void> setUserData(UserData userData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userData.uid)
          .set(userData.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
}
