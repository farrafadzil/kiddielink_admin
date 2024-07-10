import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddStudent extends StatefulWidget {
  final void Function(String, String, String, String) onFormSubmitted;

  AddStudent({required this.onFormSubmitted});

  @override
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  String? _selectedGender;
  String? _selectedStatus = 'Active'; // Default value for status
  TextEditingController fullnameController = TextEditingController();
  TextEditingController preferredNameController = TextEditingController();
  bool _isSubmitting = false; // Flag to prevent multiple submissions

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Text(
            "Student List",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              formData(context);
            },
            icon: Icon(Icons.add),
            label: Text("Add Student"),
          ),
        ],
      ),
    );
  }

  void formData(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Add New Student',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: 500,
                height: 400, // Increased height to accommodate new dropdown
                child: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      TextFormField(
                        maxLength: 50,
                        controller: fullnameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 13,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        maxLength: 50,
                        controller: preferredNameController,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Name',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 13,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        items: <String>['Male', 'Female']
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 13,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        },
                        items: <String>['Active', 'Inactive']
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 13,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: _isSubmitting ? null : () async {
                    if (fullnameController.text.isNotEmpty &&
                        preferredNameController.text.isNotEmpty &&
                        _selectedGender != null) {
                      setState(() {
                        _isSubmitting = true;
                      });
                      widget.onFormSubmitted(
                        fullnameController.text,
                        preferredNameController.text,
                        _selectedGender!,
                        _selectedStatus!,
                      );
                      Navigator.of(context).pop();
                    } else {
                      // Display a snackbar or some feedback to the user
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please fill all fields"),
                      ));
                    }
                    setState(() {
                      _isSubmitting = false;
                    });
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
