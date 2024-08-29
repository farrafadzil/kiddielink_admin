import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTeacher extends StatefulWidget {
  final void Function(String, String, String, List<String>, String) onFormSubmitted;

  AddTeacher({required this.onFormSubmitted});

  @override
  _AddTeacherState createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  String? selectedRole;
  String? _selectedStatus = 'Active';
  List<String> roles = ['Staff', 'Admin', 'Manager'];
  List<String> selectedClassrooms = [];
  List<String> availableClassrooms = [];
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController classroomController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchClassrooms();
  }

  Future<void> fetchClassrooms() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('rooms').get();
      List<String> classrooms = querySnapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      setState(() {
        availableClassrooms = classrooms;
      });
    } catch (e) {
      print('Error fetching classrooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Text(
            "Staff List",
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
            label: Text("Add Staff"),
          ),
        ],
      ),
    );
  }

  void formData(BuildContext context) async {
    String? firstname;
    String? lastname;
    String? email;
    String? selectedRoleValue;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Staff',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: 500,
            height: 400, // Adjust height as needed
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextFormField(
                    maxLength: 50,
                    controller: firstnameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
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
                    onChanged: (value) {
                      firstname = value;
                    },
                  ),
                  TextFormField(
                    maxLength: 50,
                    controller: lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
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
                    onChanged: (value) {
                      lastname = value;
                    },
                  ),
                  TextFormField(
                    maxLength: 50,
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
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
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue;
                      });
                    },
                    items: roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: SizedBox(
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              role,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: classroomController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: 'Classroom',
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
                    readOnly: true,
                    onTap: () {
                      selectClassrooms(context);
                    },
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
              onPressed: _isSubmitting
                  ? null
                  : () {
                if (firstnameController.text.isNotEmpty &&
                    lastnameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    selectedRole != null) {
                  setState(() {
                    _isSubmitting = true;
                  });
                  widget.onFormSubmitted(
                    firstnameController.text,
                    lastnameController.text,
                    emailController.text,
                    selectedClassrooms,
                    selectedRole!,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please fill all the required fields."),
                    ),
                  );
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
  }

  void selectClassrooms(BuildContext context) async {
    List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Classrooms'),
          content: Wrap(
            children: availableClassrooms.map((String classroom) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: FilterChip(
                  label: Text(classroom),
                  selected: selectedClassrooms.contains(classroom),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedClassrooms.add(classroom);
                      } else {
                        selectedClassrooms.remove(classroom);
                      }
                      classroomController.text = selectedClassrooms.join(', ');
                    });
                  },
                ),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedClassrooms);
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedClassrooms = result;
        classroomController.text = selectedClassrooms.join(', ');
      });
    }
  }
}
