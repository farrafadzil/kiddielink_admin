import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ProInfo extends StatefulWidget {
  final String staffId;

  ProInfo({required this.staffId});

  @override
  State<ProInfo> createState() => _ProInfoState();
}

class _ProInfoState extends State<ProInfo> {
  late bool _isEditing;
  late TextEditingController _roleController;
  late TextEditingController _employeeController;
  late TextEditingController _joinedDateController;

  // Define _selectedDate variable
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _roleController = TextEditingController(); // Initialize with empty string
    _employeeController = TextEditingController(); // Initialize with empty string
    _joinedDateController = TextEditingController(); // Initialize with empty string

    // Fetch professional info data when the widget initializes
    FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.staffId)
        .collection('ProfessionalInfo')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _roleController.text = data['role'] ?? '';
            _employeeController.text = data['employeeCode'] ?? '';
            _joinedDateController.text = data['joinedDate'] ?? '';
          });
        } else {
          print('Document does not exist on the database');
        }
      });
    }).catchError((error) {
      print('Error fetching certificate data: $error');
    });

    // Fetch role data when the widget initializes
    FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.staffId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          // Update the role text controller with the fetched role data
          _roleController.text = data['role'] ?? '';
        });
      } else {
        print('Document does not exist on the database');
      }
    }).catchError((error) {
      print('Error fetching role data: $error');
    });
  }

  @override
  void dispose() {
    _roleController.dispose();
    _employeeController.dispose();
    _joinedDateController.dispose();
    super.dispose();
  }

  void _saveProInfoData() {
    // Generate a unique ID using UUID
    String proInfoId = Uuid().v4();

    // Get the document reference using proInfoId
    DocumentReference docRef = FirebaseFirestore.instance.collection('staff').doc(widget.staffId).collection('ProfessionalInfo').doc(proInfoId);

    // Prepare the data to be saved
    Map<String, dynamic> dataToSave = {
      'proInfoId': proInfoId,
      'role': _roleController.text,
      'employeeCode': _employeeController.text,
      'joinedDate': _joinedDateController.text,
    };

    // Save the data using set method
    docRef.set(dataToSave)
        .then((_) {
      print('Professional info data saved successfully!');
    }).catchError((error) {
      print('Error saving professional info data: $error');
    });

    // Prepare a map of fields to update
    Map<String, dynamic> dataToUpdate = {
      'role': _roleController.text,
      'employeeCode': _employeeController.text,
      'joinedDate': _joinedDateController.text,
    };

    // Call the update method
    docRef.update(dataToUpdate)
        .then((_) {
      print('Professional info data updated successfully!');
    })
        .catchError((error) {
      print('Error updating professional info data: $error');
    });
  }


  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Initial date
      firstDate: DateTime(1900), // Earliest selectable date
      lastDate: DateTime(2100), // Latest selectable date
      initialDatePickerMode: DatePickerMode.year, // Set initial mode to year selection
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update selected date
        _joinedDateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!); // Update text field with formatted date
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PROFESSIONAL INFORMATION",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Text(
                                    "Role",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Visibility(
                                  visible: !_isEditing,
                                  child: Expanded(
                                    child: Text(
                                      _roleController.text.isNotEmpty ? _roleController.text : "None",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontStyle: _roleController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _roleController,
                                      decoration: InputDecoration(
                                        hintText: "Role",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                _saveProInfoData();
              }
            },
            child: Text(_isEditing ? 'Save' : 'Edit'),
          ),
        ),
        Positioned(
          top: 10,
          right: 100,
          child: Visibility(
            visible: _isEditing,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              child: Text('Cancel'),
            ),
          ),
        ),
      ],
    );
  }
}
