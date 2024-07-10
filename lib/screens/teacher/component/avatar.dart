import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class EditableAvatar extends StatefulWidget {
  final String staffId;

  const EditableAvatar({Key? key, required this.staffId}) : super(key: key);

  @override
  _EditableAvatarState createState() => _EditableAvatarState();
}

class _EditableAvatarState extends State<EditableAvatar> {
  String _avatarUrl = ''; // Initialize avatarUrl to an empty string

  @override
  void initState() {
    super.initState();
    // Fetch the avatar URL from Firestore when the widget initializes
    _fetchAvatar();
  }

  Future<void> _fetchAvatar() async {
    try {
      // Retrieve the avatar URL from Firestore based on the user ID
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('staff')
          .doc(widget.staffId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _avatarUrl = docSnapshot['avatarUrl'] ?? ''; // Get the avatar URL
        });
      }
    } catch (error) {
      // Handle any errors
      print('Error fetching avatar: $error');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      print('Picked image path: ${pickedImage.path}'); // Debug print

      // Upload the selected image to Firebase Storage
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${widget.staffId}.jpg');
      await ref.putFile(File(pickedImage.path));

      // Get the download URL of the uploaded image
      final String downloadUrl = await ref.getDownloadURL();

      print('Download URL: $downloadUrl'); // Debug print

      // Update the avatar URL in Firestore
      await FirebaseFirestore.instance
          .collection('staff')
          .doc(widget.staffId)
          .update({'avatarUrl': downloadUrl});

      // Update the avatar URL in the state
      setState(() {
        _avatarUrl = pickedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickImage, // Call _pickImage() when the avatar is tapped
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                child: CircleAvatar(
                  backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                  radius: 80,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: _pickImage, // Call _pickImage() when the edit icon is tapped
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
