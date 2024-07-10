import 'package:flutter/material.dart';
import 'package:kiddielink_admin_panel/screens/dashboard.dart';
import 'package:kiddielink_admin_panel/screens/report/attend_report.dart';
import 'package:kiddielink_admin_panel/screens/rooms/add_room.dart';
import 'package:kiddielink_admin_panel/screens/student/student_homepage.dart';
import 'package:kiddielink_admin_panel/screens/teacher/teacher_homepage.dart';
import '../../common/app_color.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedIndex = 0; // Variable to keep track of the selected index

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Material(
        color: AppColor.bgSideMenu,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                "KiddieLink",
                style: TextStyle(
                  color: AppColor.font,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DrawerListTile(
              title: "Dashboard",
              icon: "images/menu_home.png",
              press: () {
                _onItemTapped(0);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => Dashboard(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              isSelected: _selectedIndex == 0,
            ),
            DrawerListTile(
              title: "Student",
              icon: "images/little-kid.png",
              press: () {
                _onItemTapped(1);
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
              isSelected: _selectedIndex == 1,
            ),
            DrawerListTile(
              title: "Staff",
              icon: "images/user.png",
              press: () {
                _onItemTapped(2);
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
              isSelected: _selectedIndex == 2,
            ),
            DrawerListTile(
              title: "Rooms",
              icon: "images/room.png",
              press: () {
                _onItemTapped(3);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AddRoom(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              isSelected: _selectedIndex == 3,
            ),
            DrawerListTile(
              title: "Reports",
              icon: "images/report.png",
              press: () {
                _onItemTapped(4);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => AttendanceReport(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              isSelected: _selectedIndex == 4,
            ),
            Divider(),
            DrawerListTile(
              title: "Sign Out",
              icon: "images/logout.png",
              press: () {
                _onItemTapped(6);
              },
              isSelected: _selectedIndex == 6,
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class DrawerListTile extends StatelessWidget {
  final String title, icon;
  final VoidCallback press;
  final bool isSelected;

  const DrawerListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.press,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: BorderRadius.circular(5.0),
      child: ListTile(
        horizontalTitleGap: 0.0,
        leading: Image.asset(
          icon,
          color: isSelected ? Colors.purple : AppColor.black,
          height: 16,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.purple : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
