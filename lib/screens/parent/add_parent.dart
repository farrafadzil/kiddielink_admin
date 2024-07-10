import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddParent extends StatefulWidget {
  final void Function(String, String, String, String, String) onFormSubmitted;

  AddParent({required this.onFormSubmitted});

  @override
  _AddParentState createState() => _AddParentState();
}

class _AddParentState extends State<AddParent> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isSubmitting = false; // Flag to prevent multiple submissions

  String? selectedRelationshipType;
  bool isFatherChecked = false;
  bool isMotherChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add New Parent/Guardian',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width: 500,
        height: 300,
        child: SingleChildScrollView(
          child: ListBody(
            children: [
              DropdownButtonFormField<String>(
                value: selectedRelationshipType,
                hint: Text('Please select'), // Prompt for the dropdown
                onChanged: (newValue) {
                  setState(() {
                    selectedRelationshipType = newValue;
                  });
                },
                items: ['Please select', 'Parent', 'Guardian']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (selectedRelationshipType == 'Parent')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text('Father'),
                      value: isFatherChecked,
                      onChanged: (value) {
                        setState(() {
                          isFatherChecked = value!;
                          if (value) {
                            isMotherChecked = false;
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Mother'),
                      value: isMotherChecked,
                      onChanged: (value) {
                        setState(() {
                          isMotherChecked = value!;
                          if (value) {
                            isFatherChecked = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
              TextFormField(
                maxLength: 50,
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
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
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
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
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
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
          onPressed: _isSubmitting
              ? null
              : () async {
            if (nameController.text.isNotEmpty &&
                phoneNumberController.text.isNotEmpty &&
                emailController.text.isNotEmpty &&
                selectedRelationshipType != null &&
                selectedRelationshipType != 'Please select') {
              setState(() {
                _isSubmitting = true;
              });
              String parentType = (selectedRelationshipType == 'Parent'
                  ? (isFatherChecked ? 'Father' : 'Mother')
                  : 'Guardian');
              widget.onFormSubmitted(
                nameController.text,
                phoneNumberController.text,
                emailController.text,
                selectedRelationshipType!,
                parentType,
              );
              Navigator.of(context).pop();
            } else {
              // Display a snackbar or some feedback to the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Please fill all fields and select relationship type"),
                ),
              );
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
