import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiddielink_admin_panel/common/app_color.dart';
import 'package:kiddielink_admin_panel/screens/report/report_header.dart';
import 'package:kiddielink_admin_panel/screens/widget/side_bar_menu.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({super.key});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  DateTime selectedDate = DateTime.now();
  String selectedClassroom = 'All Classroom';
  String selectedGroup = 'All Group';
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController searchController = TextEditingController();

  List<String> classrooms = ['All Classroom', 'Classroom 1', 'Classroom 2'];
  List<String> groups = ['All Group', 'Group 1', 'Group 2'];
  List<Map<String, dynamic>> attendanceData = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
    if (!kIsWeb) requestStoragePermission();
    searchController.addListener(_filterAttendanceData);
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> fetchAttendanceData() async {
    try {
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance.collection('student').get();
      List<Map<String, dynamic>> data = [];

      for (var student in studentSnapshot.docs) {
        String fullName = student['full_name'];

        QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
            .collection('student')
            .doc(student.id)
            .collection('attendance')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)))
            .where('date', isLessThan: Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day).add(Duration(days: 1))))
            .get();

        if (attendanceSnapshot.docs.isEmpty) {
          data.add({
            'name': fullName,
            'checkInTime': 'N/A',
            'checkOutTime': 'N/A',
            'markedAbsent': true,
          });
          _notifyParent(fullName);
        } else {
          for (var doc in attendanceSnapshot.docs) {
            data.add({
              'name': fullName,
              'checkInTime': doc['check_in_time'] != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format((doc['check_in_time'] as Timestamp).toDate())
                  : 'N/A',
              'checkOutTime': doc['check_out_time'] != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format((doc['check_out_time'] as Timestamp).toDate())
                  : 'N/A',
              'markedAbsent': false,
            });
          }
        }
      }

      setState(() {
        attendanceData = data;
        filteredData = data;
      });
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  Future<void> _filterAttendanceData() async {
    String query = searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('student')
            .where('full_name', isGreaterThanOrEqualTo: query)
            .where('full_name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();

        List<Map<String, dynamic>> data = [];

        for (var student in querySnapshot.docs) {
          String fullName = student['full_name'];

          QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
              .collection('student')
              .doc(student.id)
              .collection('attendance')
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)))
              .where('date', isLessThan: Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day).add(Duration(days: 1))))
              .get();

          if (attendanceSnapshot.docs.isEmpty) {
            data.add({
              'name': fullName,
              'checkInTime': 'N/A',
              'checkOutTime': 'N/A',
              'markedAbsent': true,
            });
            _notifyParent(fullName);
          } else {
            for (var doc in attendanceSnapshot.docs) {
              data.add({
                'name': fullName,
                'checkInTime': doc['check_in_time'] != null
                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format((doc['check_in_time'] as Timestamp).toDate())
                    : 'N/A',
                'checkOutTime': doc['check_out_time'] != null
                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format((doc['check_out_time'] as Timestamp).toDate())
                    : 'N/A',
                'markedAbsent': false,
              });
            }
          }
        }

        setState(() {
          filteredData = data;
          isSearching = true;
        });
      } catch (e) {
        print('Error fetching filtered attendance data: $e');
      }
    } else {
      setState(() {
        filteredData = attendanceData;
        isSearching = false;
      });
    }
  }

  Future<void> _notifyParent(String studentName) async {
    print('Notify parent: $studentName has missed check-in.');
  }

  Future<void> _checkInStudent(String studentId) async {
    await FirebaseFirestore.instance
        .collection('student')
        .doc(studentId)
        .collection('attendance')
        .add({
      'check_in_time': Timestamp.now(),
      'date': Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)),
    });

    fetchAttendanceData();
  }

  Future<void> _checkOutStudent(String studentId) async {
    await FirebaseFirestore.instance
        .collection('student')
        .doc(studentId)
        .collection('attendance')
        .add({
      'check_out_time': Timestamp.now(),
      'date': Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)),
    });

    fetchAttendanceData();
  }

  Future<void> _exportToExcel() async {
    try {
      if (filteredData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No data to export')));
        return;
      }

      // Debug: Print filteredData
      print(filteredData);

      var excel = Excel.createExcel();
      Sheet sheet = excel['Attendance'];

      sheet.appendRow(['No.', 'Name', 'Checked-in Time', 'Checked-out Time', 'Marked Absent']);

      for (int i = 0; i < filteredData.length; i++) {
        var data = filteredData[i];
        print(data); // Debug: Print each data row

        sheet.appendRow([
          (i + 1).toString(),
          data['name'],
          data['checkInTime'],
          data['checkOutTime'],
          data['markedAbsent'] ? 'Yes' : 'No',
        ]);
      }

      var excelBytes = excel.encode();
      if (excelBytes != null) {
        if (kIsWeb) {
          final content = base64Encode(excelBytes);
          html.AnchorElement(
            href: 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$content',
          )
            ..setAttribute('download', 'Attendance_Report_${DateFormat('yyyyMMdd').format(selectedDate)}.xlsx')
            ..click();
        } else {
          // Save file to mobile storage
          final directory = await getExternalStorageDirectory();
          final path = '${directory!.path}/Attendance_Report_${DateFormat('yyyyMMdd').format(selectedDate)}.xlsx';
          final file = File(path);
          await file.writeAsBytes(excelBytes);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance report saved to $path')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to encode Excel data')));
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export report')));
    }
  }


  @override
  void dispose() {
    searchController.removeListener(_filterAttendanceData);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: Row(
        children: [
          SideBar(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ReportHeader(),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 600.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _selectDate(context),
                              child: Text("${selectedDate.toLocal()}".split(' ')[0]),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              width: 300,
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search by name',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            const SizedBox(width: 850),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert), // This shows the three-dot menu icon
                              onSelected: (String result) {
                                switch (result) {
                                  case 'Download Attendance':
                                    _exportToExcel();
                                    break;
                                // Add other cases here for different menu actions
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Download Attendance',
                                  child: Text('Download Attendance'),
                                ),
                              ],
                            ),

                          ],
                        ),
                        SizedBox(height: 25),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[300]),
                              columns: const [
                                DataColumn(label: Text('No.')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Checked-in Time & By')),
                                DataColumn(label: Text('Checked-out Time & By')),
                                DataColumn(label: Text('Marked Absent')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredData.map((data) {
                                int index = filteredData.indexOf(data);
                                return DataRow(cells: [
                                  DataCell(Container(
                                    width: 50,
                                    child: Text((index + 1).toString()),
                                  )),
                                  DataCell(Container(
                                    width: 150,
                                    child: Text(data['name']),
                                  )),
                                  DataCell(Container(
                                    width: 250,
                                    child: Text(data['checkInTime']),
                                  )),
                                  DataCell(Container(
                                    width: 250,
                                    child: Text(data['checkOutTime']),
                                  )),
                                  DataCell(Container(
                                    width: 150,
                                    child: Text(data['markedAbsent'] ? 'Yes' : 'No'),
                                  )),
                                  DataCell(Container(
                                    width: 150,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.login),
                                          onPressed: () => _checkInStudent(data['studentId']),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.logout),
                                          onPressed: () => _checkOutStudent(data['studentId']),
                                        ),
                                      ],
                                    ),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                        if (isSearching && filteredData.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('No results found for your search.'),
                          ),
                        if (!isSearching && attendanceData.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('No attendance data available for the selected date.'),
                          ),
                      ],
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

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchAttendanceData();
    }
  }
}
