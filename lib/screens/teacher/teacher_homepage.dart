import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:kiddielink_admin_panel/common/app_color.dart';
import 'package:kiddielink_admin_panel/screens/teacher/view_teacher_details.dart';
import '../widget/side_bar_menu.dart';
import 'add_teacher.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({Key? key}) : super(key: key);

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  List<Teacher> teachers = [];
  String? selectedOption = 'Option 1';

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  void fetchTeachers() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('staff').get();

      List<Teacher> fetchedTeachers = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String firstName = data['first_name'] ?? '';
        String lastName = data['last_name'] ?? '';
        String fullName = '$firstName $lastName';
        String staffId = data['staff_id'] ?? '';
        return Teacher(
          staffId: staffId,
          name: fullName,
          email: data['email'] ?? '',
          role: data['role'] ?? '',
          classroom: List<String>.from(data['classrooms'] ?? []),
          status: data['status'] ?? '',
        );
      }).toList();

      setState(() {
        teachers = fetchedTeachers;
      });
    } catch (error) {
      print('Error fetching teachers: $error');
      // Handle error fetching data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AddTeacher(
                    onFormSubmitted: (String firstName, String lastName, String email, List<String> classroom, String role) {
                      String staffId = Uuid().v4(); // Generate a unique staffId
                      String fullName = '$firstName $lastName';

                      // Add teacher data to Firestore with specific document ID (staffId)
                      FirebaseFirestore.instance.collection('staff').doc(staffId).set({
                        'staff_id': staffId,
                        'first_name': firstName,
                        'last_name': lastName,
                        'email': email,
                        'role': role,
                        'classrooms': classroom,
                        'status': 'Active', // Set default status
                      }).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Staff added successfully.')),
                        );
                        fetchTeachers(); // Refresh the teacher list
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add teacher: $error')),
                        );
                      });
                    },
                  ),

                  SizedBox(height: 25),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[300]),
                        dataRowHeight: 80,
                        columns: [
                          DataColumn(label: Text("NAME", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("EMAIL", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("CLASSROOM", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("ACTION", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: teachers.map((teacher) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text(teacher.name.isNotEmpty ? teacher.name[0] : ''),
                                    ),
                                    SizedBox(width: 10.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 23),
                                        Text(teacher.name),
                                        Text(teacher.role, style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(teacher.email)),
                              DataCell(Text(teacher.classroom.join(', '))),
                              DataCell(Text(teacher.status)),
                              DataCell(
                                SizedBox(
                                  width: 130,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedOption,
                                    onChanged: (newValue) async {
                                      setState(() {
                                        selectedOption = newValue;
                                      });
                                      if (newValue == 'Option 2') {
                                        // Navigate to view teacher details page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ViewTeacherDetail(teacher: teacher)),
                                        );
                                      } else if (newValue == 'Option 3') {
                                        // Delete teacher from Firestore
                                        try {
                                          await FirebaseFirestore.instance.collection('staff').doc(teacher.staffId).delete();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Teacher deleted successfully')),
                                          );
                                          fetchTeachers(); // Refresh the teacher list
                                        } catch (error) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to delete teacher: $error')),
                                          );
                                        }
                                      }
                                    },
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'Option 1',
                                        child: Text('Options'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Option 2',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 5),
                                            Text('View/Edit'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Option 3',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete),
                                            SizedBox(width: 5),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Teacher {
  final String staffId;
  final String name;
  final String email;
  final String role;
  final List<String> classroom;
  final String status;

  Teacher({
    required this.staffId,
    required this.name,
    required this.email,
    required this.role,
    required this.classroom,
    required this.status,
  });
}
