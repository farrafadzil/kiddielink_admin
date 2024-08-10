import 'dart:convert';
import 'dart:math';
import 'dart:js' as js;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiddielink_admin_panel/screens/student/view_student_details.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../../common/app_color.dart';
import '../parent/add_parent.dart';
import '../widget/side_bar_menu.dart';
import 'add_student.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;


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

  void showAddParentDialog(BuildContext context, String studentId, String fullName, String uniqueCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddParent(
          onFormSubmitted: (name, phoneNumber, email, relationshipType, parentType) async {
            String parentId = Uuid().v4();
            try {
              // Add the parent to Firestore
              await FirebaseFirestore.instance.collection('student').doc(studentId).collection('parents').add({
                'name': name,
                'phone_number': phoneNumber,
                'email': email,
                'relationship_type': relationshipType,
                'parent_type': parentType,
                'parent_id': parentId,
              });

              // Send the unique code via email
              sendEmail(email, fullName, uniqueCode);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Parent added and email sent successfully')),
              );

              Navigator.of(context).pop();
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add parent: $error')),
              );
            }
          },
        );
      },
    );
  }

  Future<void> sendEmail(String email, String fullName, String uniqueCode) async {
    const serviceId = 'service_jc8vemd';
    const templateId = 'template_gt1d6qj';
    const userId = 'ZYr9_x9TYMEJx52xy';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': email,
          'child_name': fullName,
          'unique_code': uniqueCode,
        }
      }),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully');
    } else {
      print('Failed to send email: ${response.body}');
    }
  }


  /*Future<void> sendEmail(String email, String fullName, String uniqueCode) async {
    final smtpServer = gmail('your-email@gmail.com', 'your-app-password');

    final message = Message()
      ..from = Address('your-email@gmail.com', 'KiddieLink')
      ..recipients.add(email)  // Using the email passed from onFormSubmitted
      ..subject = 'Unique Code for Check-In/Out'
      ..text = 'Hello, \n\nHere is the unique code for $fullName: $uniqueCode. Please use this code for check-in and check-out.'
      ..html = '<h1>Hello,</h1>\n<p>Here is the unique code for <strong>$fullName</strong>: <strong>$uniqueCode</strong>. Please use this code for check-in and check-out.</p>';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } catch (e) {
      print('Error occurred while sending email: $e');
    }
  }*/

  /*void sendEmail(String email, String fullName, String uniqueCode) {
    var serviceId = 'service_jc8vemd';
    var templateId = 'template_gt1d6qj';
    var userId = 'ZYr9_x9TYMEJx52xy';

    var templateParams = {
      'to_email': email,
      'child_name': fullName,
      'unique_code': uniqueCode,
    };

    try {
      js.context.callMethod('emailjs.send', [
        serviceId,
        templateId,
        js.JsObject.jsify(templateParams),
        userId
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sent successfully to $email')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $error')),
      );
    }
  }*/

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
                                    SizedBox(height: 10),
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
                                        showAddParentDialog(context, student.studentId, student.fullName, student.uniqueCode);
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
