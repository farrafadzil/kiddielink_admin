import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiddielink_admin_panel/screens/widget/headerWidget.dart';
import 'package:kiddielink_admin_panel/screens/widget/side_bar_menu.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import '../common/app_color.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var currentDateTime;
  List<UpcomingBirthday> upcomingBirthdays = [];
  List<AttendanceRecord> attendanceRecords = [];
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<String>> _events = {};
  int totalStudents = 0;
  int presentStudents = 0;
  int absentStudents = 0;

  @override
  void initState() {
    currentDateTime = DateTime.now();
    fetchUpcomingBirthdays(); // Call method to fetch upcoming birthdays
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    fetchEvents();
    fetchTotalStudent();
    fetchAttendanceRecords();
    super.initState();
  }

  void fetchEvents() async {
    try {
      // Fetch events from Firestore
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();

      // Clear the existing events map
      _events.clear();

      // Loop through each event document and add it to the events map
      eventsSnapshot.docs.forEach((eventDoc) {
        DateTime eventDate = (eventDoc['date'] as Timestamp).toDate();
        String eventName = eventDoc['event'];
        if (_events[eventDate] != null) {
          _events[eventDate]!.add(eventName);
        } else {
          _events[eventDate] = [eventName];
        }
      });

      // Print the contents of the events map for debugging
      _events.forEach((key, value) {
        print('Event Date: $key, Events: $value');
      });

      // Update the UI
      setState(() {});
    } catch (error) {
      print('Error fetching events: $error');
    }
  }


  void fetchUpcomingBirthdays() async {
    try {
      print('Fetching upcoming birthdays...');

      // Clear the existing list of upcoming birthdays
      upcomingBirthdays.clear();

      // Get the current date
      DateTime currentDate = DateTime.now();

      // Fetch birthdays of staff
      QuerySnapshot staffSnapshot =
          await FirebaseFirestore.instance.collection('student').get();
      staffSnapshot.docs.forEach((staffDoc) {
        DateTime staffBirthday = DateTime.parse(
            (staffDoc.data() as Map<String, dynamic>)['dateOfBirth']);
        print('Name: ${staffDoc['preferred_name']}, Birthday: $staffBirthday');

        // Check if the birthday is after the current date
        if (staffBirthday.month == currentDate.month) {
          upcomingBirthdays.add(UpcomingBirthday(
            name: (staffDoc.data() as Map<String, dynamic>)['preferred_name'],
            date: staffBirthday,
          ));
        }
      });

      // Sort upcoming birthdays by date
      upcomingBirthdays.sort((a, b) => a.date.compareTo(b.date));

      // Update the UI
      setState(() {});
    } catch (error) {
      print('Error fetching upcoming birthdays: $error');
    }
  }

  void fetchAttendanceRecords() async {
    try {
      // Clear the existing list of attendance records
      attendanceRecords.clear();

      // Get today's date
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      // Fetch all student documents
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance.collection('student').get();
      List<String> studentIds = studentSnapshot.docs.map((doc) => doc.id).toList();
      List<String> presentStudentIds = [];

      // Loop through each student document to fetch their attendance records
      for (QueryDocumentSnapshot studentDoc in studentSnapshot.docs) {
        String studentId = studentDoc.id;
        String studentName = studentDoc['full_name']; // Assuming student document has a 'full_name' field

        // Fetch attendance records for today from the student's 'attendance' sub-collection
        QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
            .collection('student')
            .doc(studentId)
            .collection('attendance')
            .where('check_in_time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('check_in_time', isLessThan: Timestamp.fromDate(endOfDay))
            .get();

        // Check if student has checked in today
        if (attendanceSnapshot.docs.isNotEmpty) {
          presentStudentIds.add(studentId);
          attendanceSnapshot.docs.forEach((attendanceDoc) {
            Map<String, dynamic> data = attendanceDoc.data() as Map<String, dynamic>;
            attendanceRecords.add(AttendanceRecord(
              studentId: studentId,
              studentName: studentName,
              checkInTime: (data['check_in_time'] as Timestamp).toDate(),
              checkOutTime: data['check_out_time'] != null
                  ? (data['check_out_time'] as Timestamp).toDate()
                  : null,
            ));
          });
        } else {
          // Add absent students
          attendanceRecords.add(AttendanceRecord(
            studentId: studentId,
            studentName: studentName,
            checkInTime: null,
            checkOutTime: null,
          ));
        }
      }

      // Sort attendance records to show absent students on top
      attendanceRecords.sort((a, b) {
        if (a.checkInTime == null && b.checkInTime != null) return -1;
        if (a.checkInTime != null && b.checkInTime == null) return 1;
        return 0;
      });

      // Update total students count
      totalStudents = studentIds.length;
      presentStudents = presentStudentIds.length;
      absentStudents = totalStudents - presentStudents;

      // Update the UI
      setState(() {});
    } catch (error) {
      print('Error fetching attendance records: $error');
    }
  }

  bool isInCurrentMonth(DateTime date) {
    DateTime now = DateTime.now();
    bool isInMonth = date.month == now.month;
    print('$date is in current month: $isInMonth');
    return isInMonth;
  }


  // Method to fetch total staff
  void fetchTotalStudent() {
    FirebaseFirestore.instance
        .collection('student') // Assuming your staff collection name is 'staff'
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        totalStudents = querySnapshot.size; // Update total staff count
        absentStudents = totalStudents - presentStudents;
      });
    }).catchError((error) {
      print('Failed to fetch total student count: $error');
    });
  }

  void fetchPresentStudents() async {
    try {
      DateTime now = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd').format(now);

      int presentCount = 0;
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance.collection('student').get();

      for (QueryDocumentSnapshot studentDoc in studentSnapshot.docs) {
        String studentId = studentDoc.id;

        QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
            .collection('student')
            .doc(studentId)
            .collection('attendance')
            .where('date', isEqualTo: todayDate)
            .where('check_out_time', isEqualTo: null)
            .get();

        if (attendanceSnapshot.docs.isNotEmpty) {
          presentCount++;
        }
      }

      setState(() {
        presentStudents = presentCount;
        absentStudents = totalStudents - presentStudents;
      });
    } catch (error) {
      print('Error fetching present students: $error');
    }
  }

  void _addEvent(DateTime date, String event) async {
    try {
      // Store the event in Firebase Firestore
      String eventId = Uuid().v4();
      await FirebaseFirestore.instance.collection('events').add({
        'date': Timestamp.fromDate(date),
        'event': event,
      });

      // Add the event to the local events map
      setState(() {
        if (_events[date] != null) {
          _events[date]!.add(event);
        } else {
          _events[date] = [event];
        }
      });

      // Show a snackbar to indicate success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Event added successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      // Show a snackbar to indicate error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add event: $error'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      // your existing Scaffold code
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventBottomSheet(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      body: Row(
        children: [
          SideBar(), // Display the Sidebar
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  HeaderWidget(),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                      "Today is ${DateFormat('MMMM dd, yyyy').format(currentDateTime)}",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center align the row
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoBox(totalStudents.toString(), "Students",
                            Icons.child_care),
                        SizedBox(width: 20),
                        _buildInfoBox(
                          presentStudents.toString(),
                          "Present Students",
                          Icons.check_circle,
                          Colors.green.shade300, // Green for present students
                        ),
                        SizedBox(width: 20),
                        _buildInfoBox(
                          absentStudents.toString(),
                          "Absent Students",
                          Icons.cancel,
                          Colors.red.shade200, // Red for absent students
                        ),
                      ],
                    ),
                  ),
                  // Display upcoming birthdays
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Container(
                            height: 400,
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.cake, color: Colors.grey),
                                      SizedBox(width: 10),
                                      Text(
                                        "Upcoming Birthdays",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                upcomingBirthdays.isEmpty
                                    ? Text(
                                        "No upcoming birthdays this month",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    : Column(
                                        children:
                                            upcomingBirthdays.map((birthday) {
                                          return _buildBirthdayItem(
                                              birthday.name, birthday.date);
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 400,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Expanded(
                            child: TableCalendar(
                              calendarFormat: _calendarFormat,
                              focusedDay: _focusedDay,
                              firstDay: DateTime(2010),
                              lastDay: DateTime(2030),
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                                print('Selected Day: $_selectedDay');
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              eventLoader: (day) {
                                return _events[day] ?? [];
                              },
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  return Center(
                                    child: Text(
                                      day.day.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSameDay(day, DateTime.now()) ? Colors.red : null,
                                      ),
                                    ),
                                  );
                                },
                                selectedBuilder: (context, day, focusedDay) {
                                  return Container(
                                    margin: EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      day.day.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                },
                                todayBuilder: (context, day, focusedDay) {
                                  return Container(
                                    margin: EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.green),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      day.day.toString(),
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  );
                                },
                                markerBuilder: (context, date, events) {
                                  if (events.isNotEmpty) {
                                    return Positioned(
                                      right: 1,
                                      bottom: 1,
                                      child: _buildEventsMarker(date, events),
                                    );
                                  }
                                },
                              ),
                            )
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Container(
                            height: 400,
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month_outlined, color: Colors.grey),
                                      SizedBox(width: 10),
                                      Text(
                                        "Event",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                _selectedDay == null || _events[_selectedDay] == null
                                    ? Text('No events')
                                    : Column(
                                  children: _events[_selectedDay]!
                                      .map((event) => ListTile(
                                    title: Text(event),
                                  ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                    width: 20,
                  ),
                  _buildAttendanceTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventBottomSheet(BuildContext context) {
    TextEditingController eventController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: eventController,
                    decoration: InputDecoration(
                      labelText: 'Event Name',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _addEvent(selectedDate, eventController.text);
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: Text('Add Event'),
                  ),
                  SizedBox(height: 16.0),
                  Text('Select Date:'),
                  SizedBox(height: 8.0),
                  ListTile(
                    title: Text(DateFormat('MMMM dd, yyyy').format(selectedDate)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }


  Widget _buildAttendanceTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    "Today's Attendance",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            attendanceRecords.isEmpty
                ? Text(
              "No attendance records for today",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
                : DataTable(
              headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.grey[300],
              ),
              columns: [
                DataColumn(
                    label: Text(
                      'NO.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                DataColumn(
                    label: Text(
                      '             STUDENT NAME',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                DataColumn(
                    label: Text(
                      'CHECK-IN TIME',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                DataColumn(
                    label: Text(
                      'CHECK-OUT TIME',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                DataColumn(
                    label: Text(
                      '            PRESENT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ],
              rows: List<DataRow>.generate(
                attendanceRecords.length,
                    (index) {
                  final record = attendanceRecords[index];
                  return DataRow(cells: [
                    DataCell(Container(
                        width: 100,
                        child: Text((index + 1).toString()))), // Auto-incrementing number
                    DataCell(Row(
                      children: [
                        CircleAvatar(
                          child: Text(record.studentName[0]),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                            width: 300,
                            child: Text(record.studentName)),
                      ],
                    )),
                    DataCell(Container(
                      width: 250,
                      child: Text(record.checkInTime != null
                          ? DateFormat('hh:mm a').format(record.checkInTime!)
                          :       '--/--'),
                    )),
                    DataCell(Container(
                      width: 250,
                      child: Text(record.checkOutTime != null
                          ? DateFormat('hh:mm a').format(record.checkOutTime!)
                          : '--/--'),
                    )),
                    DataCell(Container(
                      width: 150,
                      child: Icon(
                        record.checkInTime != null
                            ? Icons.check
                            : Icons.close,
                        color: record.checkInTime != null
                            ? Colors.green
                            : Colors.red,
                      ),
                    )),
                  ]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String title, String value, IconData icon, [Color color = const Color(0xFFCE93D8)]) {
    return Container(
      height: 100,
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
                Icon(icon, color: Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayItem(String name, DateTime date) {
    // Format date to display in a readable format
    String formattedDate = DateFormat('MMMM d').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
                // Provide the URL of the avatar image
                radius: 20, // Adjust the size of the avatar as needed
              ),
              SizedBox(width: 10), // Add some space between the avatar and text
              Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            formattedDate,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Define the UpcomingBirthday class
class UpcomingBirthday {
  final String name;
  final DateTime date;

  UpcomingBirthday({required this.name, required this.date});
}

class AttendanceRecord {
  final String studentId;
  final String studentName;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    this.checkInTime,
    this.checkOutTime,
  });
}
