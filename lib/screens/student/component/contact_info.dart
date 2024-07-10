import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactInfo extends StatefulWidget {
  final String studentId;

  ContactInfo({required this.studentId});

  @override
  _ContactInfoState createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  bool _isEditingMother = false;
  bool _isEditingFather = false;
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;
  late TextEditingController _fatherNumberController;
  late TextEditingController _motherNumberController;
  late TextEditingController _fatherEmailController;
  late TextEditingController _motherEmailController;

  @override
  void initState() {
    super.initState();
    _fatherNameController = TextEditingController();
    _motherNameController = TextEditingController();
    _fatherNumberController = TextEditingController();
    _motherNumberController = TextEditingController();
    _fatherEmailController = TextEditingController();
    _motherEmailController = TextEditingController();
    fetchParentDetails(widget.studentId);
  }

  @override
  void dispose() {
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _fatherNumberController.dispose();
    _motherNumberController.dispose();
    _fatherEmailController.dispose();
    _motherEmailController.dispose();
    super.dispose();
  }

  Future<void> fetchParentDetails(String studentId) async {
    try {
      QuerySnapshot parentSnapshot = await FirebaseFirestore.instance
          .collection('student')
          .doc(studentId)
          .collection('parents')
          .get();

      parentSnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String parentType = data['parent_type'];

        if (parentType == 'Mother') {
          setState(() {
            _motherNameController.text = data['name'] ?? '';
            _motherNumberController.text = data['phone_number'] ?? '';
            _motherEmailController.text = data['email'] ?? '';
          });
        } else if (parentType == 'Father') {
          setState(() {
            _fatherNameController.text = data['name'] ?? '';
            _fatherNumberController.text = data['phone_number'] ?? '';
            _fatherEmailController.text = data['email'] ?? '';
          });
        }
      });
    } catch (error) {
      print('Error fetching parent contact information: $error');
    }
  }

  void _saveContactData() {
    FirebaseFirestore.instance
        .collection('student')
        .doc(widget.studentId)
        .collection('parents')
        .where('parent_type', whereIn: ['Mother', 'Father'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String parentType = data['parent_type'];
        String parentId = document.id;

        // Update the parent document based on the parent type
        if (parentType == 'Mother') {
          FirebaseFirestore.instance
              .collection('student')
              .doc(widget.studentId)
              .collection('parents')
              .doc(parentId)
              .update({
            'name': _motherNameController.text,
            'phone_number': _motherNumberController.text,
            'email': _motherEmailController.text,
          }).then((_) {
            print('Mother\'s information updated successfully!');
          }).catchError((error) {
            print('Error updating mother\'s information: $error');
          });
        } else if (parentType == 'Father') {
          FirebaseFirestore.instance
              .collection('student')
              .doc(widget.studentId)
              .collection('parents')
              .doc(parentId)
              .update({
            'name': _fatherNameController.text,
            'phone_number': _fatherNumberController.text,
            'email': _fatherEmailController.text,
          }).then((_) {
            print('Father\'s information updated successfully!');
          }).catchError((error) {
            print('Error updating father\'s information: $error');
          });
        }
      });
    }).catchError((error) {
      print('Error fetching parent documents: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFFF3E5F5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MOTHER DETAILS",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(thickness: 2),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Name",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Visibility(
                                  visible: _isEditingMother,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _motherNameController,
                                      decoration: InputDecoration(
                                        hintText: "Mother's Name",
                                        hintStyle: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _motherNameController.text.isNotEmpty
                                        ? _motherNameController.text
                                        : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _motherNameController.text.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "Phone Number",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Visibility(
                                  visible: _isEditingMother,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _motherNumberController,
                                      decoration: InputDecoration(
                                        hintText: "Mother's Phone Number",
                                        hintStyle: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _motherNumberController.text.isNotEmpty
                                        ? _motherNumberController.text
                                        : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _motherNumberController.text.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Visibility(
                                  visible: _isEditingMother,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _motherEmailController,
                                      decoration: InputDecoration(
                                        hintText: "Mother's Email",
                                        hintStyle: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _motherEmailController.text.isNotEmpty
                                        ? _motherEmailController.text
                                        : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _motherEmailController.text.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditingMother = !_isEditingMother;
                        });
                        if (!_isEditingMother) {
                          _saveContactData();
                        }
                      },
                      child: Text(_isEditingMother ? 'Save' : 'Edit'),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 70,
                    child: Visibility(
                      visible: _isEditingMother,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditingMother = false;
                          });
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20), // Add some spacing between the
            // Add some spacing between the two containers
            Expanded(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFFF3E5F5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FATHER DETAILS",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(thickness: 2),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Name",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Visibility(
                                  visible: _isEditingFather,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _fatherNameController,
                                      decoration: InputDecoration(
                                        hintText: "Father's Name",
                                        hintStyle: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _fatherNameController.text.isNotEmpty
                                        ? _fatherNameController.text
                                        : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _fatherNameController.text.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "Phone Number",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Visibility(
                                  visible: _isEditingFather,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _fatherNumberController,
                                      decoration: InputDecoration(
                                        hintText: "Father's Phone Number",
                                        hintStyle: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _fatherNumberController.text.isNotEmpty
                                        ? _fatherNumberController.text
                                        : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _fatherNumberController.text.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Visibility(
                                  visible: _isEditingFather,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _fatherEmailController,
                                      decoration: InputDecoration(
                                        hintText: "Email",
                                        hintStyle: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _fatherEmailController.text.isNotEmpty
                                        ? _fatherEmailController.text
                                        : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _fatherEmailController.text.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditingFather = !_isEditingFather;
                        });
                        if (!_isEditingFather) {
                          _saveContactData();
                        }
                      },
                      child: Text(_isEditingFather ? 'Save' : 'Edit'),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 70,
                    child: Visibility(
                      visible: _isEditingFather,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditingFather = false;
                          });
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
