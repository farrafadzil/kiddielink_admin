import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAvatar extends StatefulWidget {
  final String studentId;

  const StudentAvatar({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentAvatarState createState() => _StudentAvatarState();
}

class _StudentAvatarState extends State<StudentAvatar> {
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchAvatar();
  }

  Future<void> _fetchAvatar() async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('student')
          .doc(widget.studentId)
          .get();

      if (studentDoc.exists) {
        Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          _avatarUrl = studentData['profile_picture'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching student data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius:  80,
          child: _avatarUrl.isNotEmpty
              ? Image.network(
            _avatarUrl,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return const Icon(Icons.error);
            },
          )
              : const Icon(Icons.person),
        ),
      ],
    );
  }
}
