import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeaderTeacher extends StatefulWidget {
  _HeaderTeacherState createState() => _HeaderTeacherState();
}

class _HeaderTeacherState extends State<HeaderTeacher> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Text("Staff List",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
