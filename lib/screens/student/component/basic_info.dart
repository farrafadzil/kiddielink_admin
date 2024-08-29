import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat

class BasicInfo extends StatefulWidget {
  final String studentId;

  BasicInfo({required this.studentId});

  @override
  _BasicInfoState createState() => _BasicInfoState();
}

class _BasicInfoState extends State<BasicInfo> {
  bool _isEditing = false;
  String _error = '';
  String _fullName = '';
  String _age = '';
  String _gender = '';
  String _dateOfBirth = '';
  String _address = '';
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _addressController;

  // Define _selectedDate variable
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _ageController = TextEditingController();
    _genderController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _addressController = TextEditingController();
    // Fetch user data when the widget initializes
    _fetchStudentData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudentData() async {
    try {
      // Query Firestore to get user data by staff ID
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('student')
          .doc(widget.studentId)
          .get();

      if (docSnapshot.exists) {
        // Get data from the document
        Map<String, dynamic> userData = docSnapshot.data() as Map<String, dynamic>;

        // Extract relevant data
        String fullName = userData['full_name'] ?? '';
        String age = userData['age'] ?? '';
        String gender = userData['gender'] ?? '';
        String dateOfBirth = userData['dateOfBirth'] ?? '';
        String address = userData['address'] ?? '';

        // Update state with fetched data
        setState(() {
          _fullName = fullName;
          _age = age;
          _gender = gender;
          _dateOfBirth = dateOfBirth;
          _address = address;
        });

        // Set initial values for text fields if editing
        if (_isEditing) {
          _fullNameController.text = _fullName;
          _ageController.text = _age;
          _genderController.text = _gender;
          _dateOfBirthController.text = _dateOfBirth;
          _addressController.text = _address;
        }
      }
    } catch (error) {
      // Handle any errors
      print('Error retrieving user data: $error');
    }
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
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!); // Update text field with formatted date
      });
    }
  }

  Future<void> _updateStudentData() async {
    try {

      // Update data in Firestore
      await FirebaseFirestore.instance
          .collection('student')
          .doc(widget.studentId)
          .update({
        'full_name': _fullNameController.text,
        'age': _ageController.text,
        'gender': _genderController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'address': _addressController.text,
      });

      // Fetch updated user data
      await _fetchStudentData();
      // Show Snackbar indicating success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Personal Information Updated Successfully')),
      );
    } catch (error) {
      // Handle any errors
      print('Error updating user data: $error');
      // Show Snackbar indicating error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_error.isNotEmpty)
          Container(
            alignment: Alignment.center,
            child: Text(_error, style: TextStyle(color: Colors.black),),
          ),
        Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 1.0, top: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BASIC INFORMATION",
                style: TextStyle(
                  fontSize: 15,
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
                                    "Full Name",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Visibility(
                                  visible: !_isEditing,
                                  child: Text(
                                    _fullName,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _fullNameController,
                                      decoration: InputDecoration(
                                        hintText: "Full Name",
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Text(
                                    "Age",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Visibility(
                                  visible: !_isEditing,
                                  child: Text(
                                    _age,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _ageController,
                                      decoration: InputDecoration(
                                        hintText: "Age",
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Text(
                                    "Gender",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Visibility(
                                  visible: !_isEditing,
                                  child: Text(
                                    _gender,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _genderController,
                                      decoration: InputDecoration(
                                        hintText: "Gender",
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Text(
                                    "Date of Birth",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Visibility(
                                  visible: !_isEditing,
                                  child: Text(
                                    _dateOfBirth,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _selectDate(context); // Show the date picker when tapped
                                      },
                                      child: AbsorbPointer(
                                        child: TextFormField(
                                          controller: _dateOfBirthController,
                                          decoration: InputDecoration(
                                            hintText: "Date of Birth",
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                            ),
                                            suffixIcon: GestureDetector(
                                              onTap: () {
                                                _selectDate(context); // Show the date picker when icon is tapped
                                              },
                                              child: Icon(Icons.calendar_today),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Text(
                                    "Address",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Visibility(
                                  visible: !_isEditing,
                                  child: Text(
                                    _address,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _addressController,
                                      decoration: InputDecoration(
                                        hintText: "Address",
                                        hintStyle: TextStyle(
                                          fontSize: 12,
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
            onPressed: () async {
              setState(() {
                _isEditing = !_isEditing;
              });

              // Fetch user data when editing is initiated
              if (!_isEditing) {
                // Update data in Firestore when editing is done
                await _updateStudentData();
              } else {
                // Fetch user data when entering editing mode
                await _fetchStudentData();
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
            child: TextButton(
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
