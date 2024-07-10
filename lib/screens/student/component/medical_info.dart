import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicInfo extends StatefulWidget {
  final String studentId;

  MedicInfo({required this.studentId});

  @override
  _MedicInfoState createState() => _MedicInfoState();
}

class _MedicInfoState extends State<MedicInfo> {
  bool _isEditing = false;
  late TextEditingController _allergiesController;
  late TextEditingController _medicCondiController;
  late TextEditingController _medicineController;

  @override
  void initState() {
    super.initState();
    _allergiesController = TextEditingController();
    _medicCondiController = TextEditingController();
    _medicineController = TextEditingController();

    // Fetch certificate data when the widget initializes
    FirebaseFirestore.instance
        .collection('student')
        .doc(widget.studentId)
        .collection('medical_info')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            // Here you can access certId and other fields from the document
            _allergiesController.text = data['allergies'] ?? '';
            _medicCondiController.text = data['medical_condition'] ?? '';
            _medicineController.text = data['medicine'] ?? '';
          });
        } else {
          print('Document does not exist on the database');
        }
      });
    }).catchError((error) {
      print('Error fetching certificate data: $error');
    });
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _medicCondiController.dispose();
    _medicineController.dispose();
    super.dispose();
  }

  void _saveCertificateData() {

    FirebaseFirestore.instance.collection('student').doc(widget.studentId).collection('medical_info').doc().set({
      'allergies': _allergiesController.text,
      'medical_info': _medicCondiController.text,
      'medicine': _medicineController.text,
    }).then((_) {
      print('Certificate data saved successfully!');
    }).catchError((error) {
      print('Error saving certificate data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                "MEDICAL INFORMATION",
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
                                    "Allergies",
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
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _allergiesController,
                                      decoration: InputDecoration(
                                        hintText: "Allergies",
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  replacement: Text( _allergiesController.text.isNotEmpty ? _allergiesController.text : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _allergiesController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
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
                                    "Medical Condition",
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
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _medicCondiController,
                                      decoration: InputDecoration(
                                        hintText: "Medical Condition",
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _medicCondiController.text.isNotEmpty ? _medicCondiController.text : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _medicCondiController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
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
                                    "Medications",
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
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _medicineController,
                                      decoration: InputDecoration(
                                        hintText: "Enter Credit",
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _medicineController.text.isNotEmpty ? _medicineController.text : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: _medicineController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
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
                _saveCertificateData();
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
