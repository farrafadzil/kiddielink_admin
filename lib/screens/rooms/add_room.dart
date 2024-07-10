import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiddielink_admin_panel/common/app_color.dart';
import 'package:kiddielink_admin_panel/screens/rooms/room_header.dart';
import 'package:kiddielink_admin_panel/screens/widget/side_bar_menu.dart';
import 'package:uuid/uuid.dart';

class AddRoom extends StatefulWidget {
  const AddRoom({Key? key}) : super(key: key);

  @override
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _studentController = TextEditingController();

  Future<void> _addRoom() async {
    // Get the data from the text fields
    final String roomId = Uuid().v4();
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final int teachers = int.tryParse(_teacherController.text) ?? 0;
    final int students = int.tryParse(_studentController.text) ?? 0;

    try {
      // Add the data to Firestore
      await FirebaseFirestore.instance.collection('rooms').add({
        'room_id': roomId,
        'name': name,
        'description': description,
        'teachers': teachers,
        'students': students,
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room successfully added'),
        ),
      );

      // Clear the text fields after successful addition
      _nameController.clear();
      _descriptionController.clear();
      _teacherController.clear();
      _studentController.clear();
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add room: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: Row(
        children: [
          SideBar(), // Assuming SideBar is a widget for navigation or menu
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  RoomHeader(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _buildAddRoomBox(),
                  ),
                  SizedBox(height: 10),
                  _buildRoomTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRoomBox() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Basic Info",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 150, // Fixed width for the label
                child: Text(
                  'Name of Room',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 20),
              Container(
                width: 500, // Set the desired width of the TextField
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 150, // Fixed width for the label
                child: Text(
                  'Short description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 20),
              Container(
                width: 800, // Set the desired width of the TextField
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Divider(),
          SizedBox(height: 30),
          Text(
            'Room Ratio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 150, // Fixed width for the label
                      child: Text(
                        'No of Teacher',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 150, // Set the desired width of the TextField
                      child: TextField(
                        controller: _teacherController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 150, // Fixed width for the label
                      child: Text(
                        'No of Student',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 150, // Set the desired width of the TextField
                      child: TextField(
                        controller: _studentController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft, // Align to the left
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: ElevatedButton(
                onPressed: _addRoom,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.white, // Button color
                ),
                child: Text(
                  'Add Room',
                  style: TextStyle(fontSize: 18, color: Colors.purple),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No rooms available'));
        }
        final rooms = snapshot.data!.docs;
        return Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: DataTable(
            headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[300]),
            columns: [
              DataColumn(label: Text('No.')),
              DataColumn(label: Text('Room')),
              DataColumn(label: Text('Ratio student:staff')),
              DataColumn(label: Text('# Checked-in students')),
              DataColumn(label: Text('# Checked-in staff')),
            ],
            rows: rooms.map((room) {
              int index = rooms.indexOf(room);
              final data = room.data() as Map<String, dynamic>;
              final roomName = data['name'];
              final ratio = data['students'].toString() + ':' + data['teachers'].toString();
              final checkedInStudents = data['students'].toString();
              final checkedInStaff = data['teachers'].toString();
              return DataRow(cells: [
                DataCell(Container(
                    width: 130,
                    child: Text((index + 1).toString()),
                )),
                DataCell(Container(
                    width: 250,
                    child: Text(roomName))),
                DataCell(Container(
                    width: 250,
                    child: Text(ratio))),
                DataCell(Container(
                    width: 210,
                    child: Text(checkedInStudents))),
                DataCell(Container(
                    width: 220,
                    child: Text(checkedInStaff))),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
