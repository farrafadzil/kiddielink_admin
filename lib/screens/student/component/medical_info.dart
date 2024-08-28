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
  bool _isUpdating = false; // To track if we are updating an existing document
  late TextEditingController _allergiesController;
  late TextEditingController _medicCondiController;
  late TextEditingController _medicineController;
  String? _medicalInfoId; // To store the ID of the document being edited

  @override
  void initState() {
    super.initState();
    _allergiesController = TextEditingController();
    _medicCondiController = TextEditingController();
    _medicineController = TextEditingController();

    // Fetch medical info data when the widget initializes
    _fetchMedicalInfo();
  }

  void _fetchMedicalInfo() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('student')
          .doc(widget.studentId)
          .collection('medical_info')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _medicalInfoId = documentSnapshot.id;
          _allergiesController.text = data['allergies'] ?? '';
          _medicCondiController.text = data['medical_condition'] ?? '';
          _medicineController.text = data['medicine'] ?? '';
          _isUpdating = true;
        });
      } else {
        print('No medical info document found. You can add new data.');
        _isUpdating = false;
      }
    } catch (error) {
      print('Error fetching medical info data: $error');
    }
  }

  void _saveOrUpdateCertificateData() {
    final data = {
      'allergies': _allergiesController.text,
      'medical_condition': _medicCondiController.text,
      'medicine': _medicineController.text,
    };

    if (_isUpdating && _medicalInfoId != null) {
      // Update existing document
      FirebaseFirestore.instance
          .collection('student')
          .doc(widget.studentId)
          .collection('medical_info')
          .doc(_medicalInfoId)
          .update(data)
          .then((_) {
        print('Medical info data updated successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medical info details updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        print('Error updating medical info data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update medical info.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      // Add new document
      FirebaseFirestore.instance
          .collection('student')
          .doc(widget.studentId)
          .collection('medical_info')
          .add(data)
          .then((docRef) {
        setState(() {
          _medicalInfoId = docRef.id; // Save the document ID for future updates
          _isUpdating = true;
        });
        print('Medical info data saved successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medical info details saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        print('Error saving medical info data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save medical info.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _medicCondiController.dispose();
    _medicineController.dispose();
    super.dispose();
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
                                  replacement: Text(
                                    _allergiesController.text.isNotEmpty ? _allergiesController.text : "None",
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
                                        hintText: "Enter Medications",
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
                if (!_isEditing && (_allergiesController.text.isNotEmpty || _medicCondiController.text.isNotEmpty || _medicineController.text.isNotEmpty)) {
                  _saveOrUpdateCertificateData();
                }
              });
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
