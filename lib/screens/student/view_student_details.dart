import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiddielink_admin_panel/screens/student/component/basic_info.dart';
import 'package:kiddielink_admin_panel/screens/student/component/contact_info.dart';
import 'package:kiddielink_admin_panel/screens/student/component/medical_info.dart';
import 'package:kiddielink_admin_panel/screens/student/component/student_avatar.dart';
import 'package:kiddielink_admin_panel/screens/student/studentHeader.dart';
import 'package:kiddielink_admin_panel/screens/student/student_homepage.dart';
import '../../common/app_color.dart';
import '../widget/side_bar_menu.dart';

class ViewStudentDetail extends StatefulWidget {
  final Student student;

  const ViewStudentDetail({Key? key, required this.student}) : super(key: key);

  @override
  State<ViewStudentDetail> createState() => _ViewStudentDetailState();
}

class _ViewStudentDetailState extends State<ViewStudentDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => StudentHomePage(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        HeaderStudent(),
                      ],
                    ),
                    SizedBox(height: 20),
                    StudentAvatar(studentId: widget.student.studentId),
                    SizedBox(height: 30),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: "Basic Info"),
                        Tab(text: "Contact Info"),
                        Tab(text: "Medical Info"),
                      ],
                    ),

                    Container(
                      height: 550, // Adjust as needed for your content
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          BasicInfo(studentId: widget.student.studentId),
                          ContactInfo(studentId: widget.student.studentId),
                          MedicInfo(studentId: widget.student.studentId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
