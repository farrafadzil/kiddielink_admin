import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeaderStudent extends StatefulWidget {
  _HeaderStudentState createState() => _HeaderStudentState();
}

class _HeaderStudentState extends State<HeaderStudent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Text("Student List",
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
