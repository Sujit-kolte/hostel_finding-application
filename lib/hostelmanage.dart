import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class HostelManagePage extends StatefulWidget {
  const HostelManagePage({super.key});

  @override
  State<HostelManagePage> createState() => _HostelManagePageState();
}

class _HostelManagePageState extends State<HostelManagePage>
    with WidgetsBindingObserver {
  final auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.ref();
  final storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  final Connectivity connectivity = Connectivity();

  bool isEditable = false;
  bool isLoading = true;
  bool isUploading = false;
  bool hasNetworkConnection = true;
  double uploadProgress = 0.0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController depositController = TextEditingController();
  final TextEditingController facilitiesController = TextEditingController();
  final TextEditingController rulesController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  List<String> imageUrls = [];
  List<XFile> selectedImages = [];
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initConnectivity();
    fetchData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnection();
      if (isUploading) {
        _resumeUploads();
      }
    } else if (state == AppLifecycleState.paused) {
      _pauseUploads();
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await connectivity.checkConnectivity();
      _updateConnectionStatus(result as ConnectivityResult);
    } on PlatformException catch (e) {
      debugPrint('Could not check connectivity status: $e');
    }

    connectivitySubscription =
        connectivity.onConnectivityChanged.listen(
              _updateConnectionStatus
                  as void Function(List<ConnectivityResult> event)?,
            )
            as StreamSubscription<ConnectivityResult>?;
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      hasNetworkConnection = result != ConnectivityResult.none;
    });
  }

  Future<bool> _checkConnection() async {
    final result = await connectivity.checkConnectivity();
    final connected = result != ConnectivityResult.none;
    setState(() => hasNetworkConnection = connected);
    return connected;
  }

  void _pauseUploads() {
    // In a real app, you might want to pause ongoing uploads
    debugPrint('App backgrounded - uploads paused');
  }

  void _resumeUploads() {
    // In a real app, you might want to resume paused uploads
    debugPrint('App resumed - checking upload status');
  }

  Future<void> fetchData() async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      final connected = await _checkConnection();
      if (!connected) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No internet connection')));
        setState(() => isLoading = false);
        return;
      }

      final snapshot = await dbRef.child('owners/${user.uid}').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        if (!mounted) return;
        setState(() {
          nameController.text = data['name'] ?? '';
          rentController.text = data['rent'] ?? '';
          depositController.text = data['deposit'] ?? '';
          facilitiesController.text =
              (data['features'] as List?)?.join(', ') ?? '';
          rulesController.text = (data['rules'] as List?)?.join(', ') ?? '';
          emailController.text = data['email'] ?? '';
          mobileController.text = data['contact'] ?? '';
          websiteController.text = data['website'] ?? '';
          imageUrls = List<String>.from(data['photos'] ?? []);
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: ${e.toString()}')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> saveData() async {
    final user = auth.currentUser;
    if (user == null) return;

    final connected = await _checkConnection();
    if (!connected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection. Please connect to save changes',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
    });

    try {
      // Upload selected images with retry logic
      for (int i = 0; i < selectedImages.length; i++) {
        final file = selectedImages[i];
        if (!await File(file.path).exists()) {
          debugPrint('File does not exist: ${file.path}');
          continue;
        }

        String extension = file.path.split('.').last;
        final ref = storage.ref().child(
          'hostel_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.$extension',
        );

        final uploadTask = await _uploadWithRetry(File(file.path), ref, 3);
        final url = await uploadTask.ref.getDownloadURL();
        imageUrls.add(url);
      }

      selectedImages.clear();

      final data = {
        'name': nameController.text,
        'rent': rentController.text,
        'deposit': depositController.text,
        'features':
            facilitiesController.text.split(',').map((e) => e.trim()).toList(),
        'rules': rulesController.text.split(',').map((e) => e.trim()).toList(),
        'email': emailController.text,
        'contact': mobileController.text,
        'website': websiteController.text,
        'photos': imageUrls,
      };

      await dbRef.child('owners/${user.uid}').update(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Changes saved successfully")),
      );
    } catch (e) {
      debugPrint('Error saving data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: ${e.toString()}")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isEditable = false;
        isUploading = false;
      });
    }
  }

  Future<TaskSnapshot> _uploadWithRetry(
    File file,
    Reference ref,
    int retries,
  ) async {
    try {
      final uploadTask = ref.putFile(file);
      uploadTask.snapshotEvents.listen((snapshot) {
        if (!mounted) return;
        setState(() {
          uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });
      return await uploadTask;
    } catch (e) {
      if (retries > 0) {
        debugPrint('Upload failed, retrying... ($retries attempts left)');
        await Future.delayed(const Duration(seconds: 2));
        return _uploadWithRetry(file, ref, retries - 1);
      }
      rethrow;
    }
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;

    if (!mounted) return;
    setState(() {
      selectedImages.addAll(picked);
    });
  }

  void removeImage(int index, bool isNewImage) {
    if (!mounted) return;
    setState(() {
      if (isNewImage) {
        selectedImages.removeAt(index);
      } else {
        imageUrls.removeAt(index);
      }
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label:", style: labelStyle),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: isEditable,
          decoration: inputDecoration,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF949DFF),
      appBar: AppBar(
        title: const Text('Manage Hostel'),
        backgroundColor: const Color(0xFF6C73FF),
        actions: [
          IconButton(
            icon: Icon(isEditable ? Icons.lock : Icons.edit),
            onPressed: () {
              if (!mounted) return;
              setState(() => isEditable = !isEditable);
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Connection status indicator
                        if (!hasNetworkConnection)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.red,
                            child: const Center(
                              child: Text(
                                'No Internet Connection',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                        // Rest of your content
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              if (isUploading)
                                LinearProgressIndicator(
                                  value: uploadProgress,
                                  backgroundColor: Colors.grey[300],
                                  color: const Color(0xFF6C73FF),
                                ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  ...imageUrls.asMap().entries.map((entry) {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            entry.value,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (isEditable)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => removeImage(
                                                    entry.key,
                                                    false,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                                  ...selectedImages.asMap().entries.map((
                                    entry,
                                  ) {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(entry.value.path),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => removeImage(
                                                  entry.key,
                                                  true,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                              if (isEditable)
                                ElevatedButton.icon(
                                  onPressed: pickImages,
                                  icon: const Icon(Icons.add_a_photo),
                                  label: const Text('Add Photos'),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField("Nearby College Name", nameController),
                        _buildTextField("Rent", rentController),
                        _buildTextField("Deposit", depositController),
                        _buildTextField(
                          "Facilities (comma separated)",
                          facilitiesController,
                        ),
                        _buildTextField(
                          "Rules (comma separated)",
                          rulesController,
                        ),
                        _buildTextField("e-mail", emailController),
                        _buildTextField("Mobile No.", mobileController),
                        _buildTextField("Website", websiteController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              (isEditable &&
                                      !isUploading &&
                                      hasNetworkConnection)
                                  ? saveData
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              isUploading
                                  ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(),
                                      ),
                                      SizedBox(width: 10),
                                      Text("Uploading..."),
                                    ],
                                  )
                                  : const Text("Save Changes"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  final TextStyle labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.white,
  );

  final InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  );
}
