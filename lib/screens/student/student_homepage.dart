import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kiddielink_admin_panel/common/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiddielink_admin_panel/screens/student/view_student_details.dart';
import '../parent/add_parent.dart';
import '../widget/side_bar_menu.dart';
import 'add_student.dart';
import 'package:uuid/uuid.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Student> students = [];
  String? _revealedStudentId; // State variable to track revealed unique code
  String? _revealedAttendanceCode;

  @override
  void initState() {
    super.initState();
    fetchStudentsWithParents();
  }

  void fetchStudentsWithParents() async {
    QuerySnapshot studentSnapshot = await FirebaseFirestore.instance.collection('student').get();
    List<Student> fetchedStudents = [];

    for (var doc in studentSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String studentId = doc.id;

      QuerySnapshot parentSnapshot = await FirebaseFirestore.instance.collection('student').doc(studentId).collection('parents').get();
      List<Parent> parents = parentSnapshot.docs.map((parentDoc) {
        Map<String, dynamic> parentData = parentDoc.data() as Map<String, dynamic>;
        return Parent(
          name: parentData['name'],
          relationshipType: parentData['relationship_type'],
        );
      }).toList();

      fetchedStudents.add(Student(
        fullName: data['full_name'] ?? '',
        preferredName: data['preferred_name'] ?? '',
        gender: data['gender'] ?? '',
        studentId: studentId,
        uniqueCode: data['unique_code'] ?? '',
        status: data['status'] ?? 'Active',
        attendanceCode: data['attendance_code'] ?? '',
        parents: parents,
      ));
    }

    setState(() {
      students = fetchedStudents;
    });
  }

  void showAddParentDialog(BuildContext context, String studentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddParent(
          onFormSubmitted: (name, phoneNumber, email, relationshipType, parentType) {
            // Add parent/guardian data to Firestore using the stored studentId
            String parentId = Uuid().v4();
            FirebaseFirestore.instance.collection('student').doc(studentId).collection('parents').add({
              'name': name,
              'phone_number': phoneNumber,
              'email': email,
              'relationship_type': relationshipType,
              'parent_type': parentType,
              'parent_id': parentId,
            }).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Parent added successfully')),
              );
              fetchStudentsWithParents(); // Refresh the data
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add parent: $error')),
              );
            });
          },
        );
      },
    );
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
                  AddStudent(
                    onFormSubmitted: (String fullName, String preferredName, String gender, String status) {
                      String uniqueCode = Uuid().v4().substring(0, 6); // Generate a unique code
                      String attendanceCode = generateAttendanceCode();
                      String studentId = Uuid().v4();
                      FirebaseFirestore.instance.collection('student').add({
                        'full_name': fullName,
                        'preferred_name': preferredName,
                        'gender': gender,
                        'status': status,
                        'unique_code': uniqueCode,
                        'student_id': studentId,
                        'attendance_code': attendanceCode,
                      }).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Student added successfully')),
                        );
                        fetchStudentsWithParents(); // Refresh the data
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add student: $error')),
                        );
                      });
                    },
                  ),
                  SizedBox(height: 25),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey[300],
                        ),
                        dataRowHeight: 100,
                        columns: [
                          DataColumn(label: Text("NAME", style: TextStyle(fontWeight: FontWeight.bold),)),
                          DataColumn(label: Text("SIGNED UP", style: TextStyle(fontWeight: FontWeight.bold),)),
                          DataColumn(label: Text("PARENTS", style: TextStyle(fontWeight: FontWeight.bold),)),
                          DataColumn(label: Text("CHECK-IN/OUT CODE", style: TextStyle(fontWeight: FontWeight.bold),)),
                          DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold),)),
                          DataColumn(label: Text("ACTION", style: TextStyle(fontWeight: FontWeight.bold),)),
                        ],
                        rows: students.map((student) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text(student.preferredName[0]),
                                    ),
                                    SizedBox(width: 10.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 28),
                                        Text(student.preferredName),
                                        Text(student.fullName, style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    Text(_revealedStudentId == student.studentId ? student.uniqueCode : '****'),
                                    IconButton(
                                      icon: Icon(_revealedStudentId == student.studentId ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _revealedStudentId = _revealedStudentId == student.studentId ? null : student.studentId;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height:10 ),
                                    ...student.parents.map((parent) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0), // Adjust the bottom padding for line spacing
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              child: Text(parent.name[0]), // Initial of the parent's name
                                              radius: 12, // Adjust the radius as needed
                                            ),
                                            SizedBox(width: 8), // Space between the avatar and the text
                                            Text('${parent.name}'),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    GestureDetector(
                                      onTap: () {
                                        showAddParentDialog(context, student.studentId);
                                      },

                                      child: Row(
                                        children: [
                                          Icon(Icons.person_add, size: 15),
                                          SizedBox(width: 10),
                                          Text(
                                            "Add Parent",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.none,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    SizedBox(width: 50,),
                                    Text(_revealedAttendanceCode == student.studentId ? student.attendanceCode : '****'),
                                    IconButton(
                                      icon: Icon(_revealedAttendanceCode == student.studentId ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _revealedAttendanceCode = _revealedAttendanceCode == student.studentId ? null : student.studentId;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(student.status)),
                              DataCell(
                                SizedBox(
                                  width: 130,
                                  child: DropdownButtonFormField<String>(
                                    value: 'Option 1',
                                    onChanged: (newValue) async {
                                      if (newValue == 'Option 2') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewStudentDetail(student: student),
                                          ),
                                        );
                                      } else if (newValue == 'Option 3') {
                                        // Delete student from Firestore
                                        try {
                                          await FirebaseFirestore.instance.collection('student').doc(student.studentId).delete();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Student deleted successfully')),
                                          );
                                          fetchStudentsWithParents(); // Refresh the data
                                        } catch (error) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to delete student: $error')),
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

  String generateAttendanceCode() {
    Random random = Random();
    int min = 1000; // Minimum 4-digit number
    int max = 9999; // Maximum 4-digit number
    int randomNumber = min + random.nextInt(max - min);
    return randomNumber.toString();
  }


}

class Student {
  final String fullName;
  final String preferredName;
  final String gender;
  final String studentId;
  final String uniqueCode;
  final String attendanceCode;
  final String status;
  final List<Parent> parents;

  Student({
    required this.fullName,
    required this.preferredName,
    required this.gender,
    required this.studentId,
    required this.uniqueCode,
    required this.attendanceCode,
    required this.status,
    required this.parents,
  });
}

class Parent {
  final String name;
  final String relationshipType;

  Parent({
    required this.name,
    required this.relationshipType,
  });
}
