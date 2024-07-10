import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat

class PersonalInfo extends StatefulWidget {
  final String staffId;

  PersonalInfo({required this.staffId});

  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  bool _isEditing = false;
  String _name = '';
  String _email = '';
  String _phone = '';
  String _dateOfBirth = '';
  String _address = '';
  String _room = '';
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _addressController;
  late TextEditingController _roomController;

  // Define _selectedDate variable
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _addressController = TextEditingController();
    _roomController = TextEditingController();

    // Fetch user data when the widget initializes
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      // Query Firestore to get user data by staff ID
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('staff')
          .doc(widget.staffId)
          .get();

      if (docSnapshot.exists) {
        // Get data from the document
        Map<String, dynamic> userData = docSnapshot.data() as Map<String, dynamic>;

        // Extract relevant data
        String firstName = userData['first_name'] ?? '';
        String lastName = userData['last_name'] ?? '';
        String email = userData['email'] ?? '';
        String phone = userData['phone'] ?? '';
        String dateOfBirth = userData['dateOfBirth'] ?? '';
        String address = userData['address'] ?? '';
        List<dynamic> classrooms = userData['classrooms'] ?? [];
        String room = classrooms.join(', ');

        // Update state with fetched data
        setState(() {
          _name = '$firstName $lastName';
          _email = email;
          _phone = phone;
          _dateOfBirth = dateOfBirth;
          _address = address;
          _room = room;
        });

        // Set initial values for text fields if editing
        if (_isEditing) {
          _nameController.text = _name;
          _emailController.text = _email;
          _phoneController.text = _phone;
          _dateOfBirthController.text = _dateOfBirth;
          _addressController.text = _address;
          _roomController.text = _room;
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

  Future<void> _updateUserData() async {
    try {
      // Combine first name and last name into a single string
      List<String> nameParts = _nameController.text.split(" ");
      String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : '';

      // Convert the comma-separated string of classrooms back into a list
      List<String> classrooms = _roomController.text.split(',').map((e) => e.trim()).toList();

      // Update data in Firestore
      await FirebaseFirestore.instance
          .collection('staff')
          .doc(widget.staffId)
          .update({
        'first_name': firstName,
        'last_name': lastName,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'address': _addressController.text,
        'classrooms': classrooms,
      });

      // Fetch updated user data
      await _fetchUserData();
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
                "PERSONAL INFORMATION",
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
                                    "Name",
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
                                  child: Text(
                                    _name,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        hintText: "Full Name",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
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
                                    "Email Address",
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
                                  child: Text(
                                    _email,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        hintText: "Email Address",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
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
                                    "Phone",
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
                                  child: Text(
                                    _phone,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                        hintText: "Phone",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
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
                                  child: Text(
                                    _dateOfBirth,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 15,
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
                                              fontSize: 15,
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
                                  child: Text(
                                    _address,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 15,
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
                                          fontSize: 15,
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
                                    "Rooms",
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
                                  child: Text(
                                    _room,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _roomController,
                                      decoration: InputDecoration(
                                        hintText: "Rooms (comma separated)",
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
            onPressed: () async {
              setState(() {
                _isEditing = !_isEditing;
              });

              // Fetch user data when editing is initiated
              if (!_isEditing) {
                // Update data in Firestore when editing is done
                await _updateUserData();
              } else {
                // Fetch user data when entering editing mode
                await _fetchUserData();
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
