import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiddielink_admin_panel/screens/teacher/component/avatar.dart';
import 'package:kiddielink_admin_panel/screens/teacher/component/certificate.dart';
import 'package:kiddielink_admin_panel/screens/teacher/component/personal_info.dart';
import 'package:kiddielink_admin_panel/screens/teacher/component/professional_info.dart';
import 'package:kiddielink_admin_panel/screens/teacher/headerTeacher.dart';
import 'package:kiddielink_admin_panel/screens/teacher/teacher_homepage.dart';
import '../../common/app_color.dart';
import '../widget/side_bar_menu.dart';

class ViewTeacherDetail extends StatefulWidget {
  final Teacher teacher;

  const ViewTeacherDetail({Key? key, required this.teacher}) : super(key: key);

  @override
  State<ViewTeacherDetail> createState() => _ViewTeacherDetailState();
}

class _ViewTeacherDetailState extends State<ViewTeacherDetail> with SingleTickerProviderStateMixin {
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
                                pageBuilder: (context, animation, secondaryAnimation) => TeacherHomePage(),
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
                        HeaderTeacher(),
                      ],
                    ),
                    SizedBox(height: 20),
                    EditableAvatar(staffId: widget.teacher.staffId),
                    SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: "Personal Info"),
                        Tab(text: "Professional Info"),
                        Tab(text: "Certificates"),
                      ],
                    ),
                    Container(
                      height: 510, // Adjust as needed for your content
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          PersonalInfo(staffId: widget.teacher.staffId),
                          ProInfo(staffId: widget.teacher.staffId),
                          Certificate(staffId: widget.teacher.staffId),
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
