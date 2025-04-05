import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProfilesScreen extends StatefulWidget {
  const UpdateProfilesScreen({Key? key, required String username})
      : super(key: key);

  @override
  _UpdateProfilesScreenState createState() => _UpdateProfilesScreenState();
}

class _UpdateProfilesScreenState extends State<UpdateProfilesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> profiles = [];
  bool isLoading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    fetchProfiles();
    listenToProfileUpdates();
  }

  Future<void> fetchProfiles() async {
    try {
      final response = await supabase.from('profiles').select();
      if (mounted) {
        setState(() {
          profiles = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching profiles: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void listenToProfileUpdates() {
    _subscription = supabase
        .from('profiles')
        .stream(primaryKey: ['user_id']).listen((data) {
      if (mounted) {
        setState(() => profiles = List<Map<String, dynamic>>.from(data));
      }
    });
  }

  Future<void> updateProfile(
      String id, Map<String, dynamic> updatedData) async {
    try {
      await supabase.from('profiles').update(updatedData).eq('user_id', id);
      fetchProfiles();
    } catch (e) {
      print("❌ Error updating profile: $e");
    }
  }

  void showEditDialog(BuildContext context, Map<String, dynamic> profile) {
    TextEditingController nameController =
        TextEditingController(text: profile['name'] ?? '');
    TextEditingController emailController =
        TextEditingController(text: profile['email'] ?? '');
    TextEditingController roleController =
        TextEditingController(text: profile['role'] ?? '');
    TextEditingController heightController =
        TextEditingController(text: profile['height']?.toString() ?? '');
    TextEditingController weightController =
        TextEditingController(text: profile['weight']?.toString() ?? '');
    TextEditingController ageController =
        TextEditingController(text: profile['age']?.toString() ?? '');
    TextEditingController dobController =
        TextEditingController(text: profile['date_of_birth'] ?? '');
    String? imageUrl = profile['image_url'];
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email')),
                TextField(
                    controller: roleController,
                    decoration: const InputDecoration(labelText: 'Role')),
                TextField(
                    controller: heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: dobController,
                    decoration:
                        const InputDecoration(labelText: 'Date of Birth')),
                const SizedBox(height: 10),
                if (imageUrl?.isNotEmpty == true)
                  Image.network(imageUrl!,
                      height: 100, width: 100, fit: BoxFit.cover),
                TextButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setDialogState(() => isUploading = true);
                      String? uploadedUrl = await uploadImage(
                          File(pickedFile.path), profile['user_id']);
                      if (uploadedUrl != null) {
                        setDialogState(() {
                          imageUrl = uploadedUrl;
                          isUploading = false;
                        });
                      }
                    }
                  },
                  child: isUploading
                      ? const CircularProgressIndicator()
                      : const Text('Change Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                updateProfile(profile['user_id'], {
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': roleController.text,
                  'height': double.tryParse(heightController.text),
                  'weight': double.tryParse(weightController.text),
                  'age': int.tryParse(ageController.text),
                  'date_of_birth': dobController.text,
                  if (imageUrl?.isNotEmpty == true) 'image_url': imageUrl,
                });
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      final String filePath =
          'profiles/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('profileimages').upload(filePath, imageFile);
      final String publicUrl =
          supabase.storage.from('profileimages').getPublicUrl(filePath);
      await supabase
          .from('profiles')
          .update({'image_url': publicUrl}).eq('user_id', userId);
      return publicUrl;
    } catch (e) {
      print("❌ Image Upload Error: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Profiles')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profiles.isEmpty
              ? const Center(
                  child:
                      Text("No profiles found", style: TextStyle(fontSize: 20)))
              : ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: (profile['image_url']?.isNotEmpty == true)
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(profile['image_url']!))
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(profile['name'] ?? 'No Name',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "Role: ${profile['role'] ?? 'No Role'}\nEmail: ${profile['email'] ?? 'No Email'}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showEditDialog(context, profile),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
