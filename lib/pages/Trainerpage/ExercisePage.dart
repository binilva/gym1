import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ExercisePage extends StatefulWidget {
  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final _supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  File? _selectedVideo;
  bool isUploading = false;

  // Pick video from device
  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
      });
    }
  }

  // Upload video to Supabase Storage
  Future<String?> _uploadVideo(File videoFile) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = 'exercise-videos/$userId/$fileName';

      // Upload the file
      await _supabase.storage.from('exercise-videos').upload(filePath, videoFile);

      // Return the public URL of the video
      return _supabase.storage.from('exercise-videos').getPublicUrl(filePath);
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  // Add Exercise with Video
  Future<void> _addExercise() async {
    if (_nameController.text.isEmpty || _detailsController.text.isEmpty || _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a video.')),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final videoUrl = await _uploadVideo(_selectedVideo!);
      if (videoUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video upload failed. Try again.')),
        );
        return;
      }

      // Save to database
      await _supabase.from('exercises').insert({
        'trainer_id': _supabase.auth.currentUser!.id,
        'exercise_name': _nameController.text.trim(),
        'details': _detailsController.text.trim(),
        'video_url': videoUrl, // Store video URL
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise added successfully!')),
      );
      _nameController.clear();
      _detailsController.clear();
      setState(() => _selectedVideo = null);
    } catch (e) {
      print("Error: $e");
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Tracker'),
        backgroundColor: Colors.indigo[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Exercise Name')),
            TextField(controller: _detailsController, decoration: const InputDecoration(labelText: 'Exercise Details')),
            const SizedBox(height: 20),

            // Select Video Button
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text('Select Video'),
            ),

            _selectedVideo != null
                ? Text('Selected: ${_selectedVideo!.path.split('/').last}')
                : const Text('No video selected'),

            const SizedBox(height: 20),

            isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _addExercise,
              child: const Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
