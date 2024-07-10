import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiddielink_admin_panel/common/app_color.dart';

class HeaderWidget extends StatefulWidget {
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Text("Dashboard",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget navigationIcon({icon}){
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: AppColor.black,
        ),
      );
  }
}