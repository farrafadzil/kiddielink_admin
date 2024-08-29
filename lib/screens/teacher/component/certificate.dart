import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Certificate extends StatefulWidget {
  final String staffId;

  Certificate({required this.staffId});

  @override
  _CertificateState createState() => _CertificateState();
}

class _CertificateState extends State<Certificate> {
  bool _isEditing = false;
  late TextEditingController _degreeController;
  late TextEditingController _certificationController;
  late TextEditingController _educationCreditsController;

  @override
  void initState() {
    super.initState();
    _degreeController = TextEditingController();
    _certificationController = TextEditingController();
    _educationCreditsController = TextEditingController();

    // Fetch certificate data when the widget initializes
    FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.staffId)
        .collection('certificates')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            // Here you can access certId and other fields from the document
            _degreeController.text = data['degree'] ?? '';
            _certificationController.text = data['certification'] ?? '';
            _educationCreditsController.text = data['educationCredits'] ?? '';
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
    _degreeController.dispose();
    _certificationController.dispose();
    _educationCreditsController.dispose();
    super.dispose();
  }

  void _saveCertificateData() {

    FirebaseFirestore.instance.collection('staff').doc(widget.staffId).collection('certificates').doc().set({
      'degree': _degreeController.text,
      'certification': _certificationController.text,
      'educationCredits': _educationCreditsController.text,
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
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CERTIFICATIONS",
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
                                    "Degree",
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
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _degreeController,
                                      decoration: InputDecoration(
                                        hintText: "Degree",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  replacement: Text( _degreeController.text.isNotEmpty ? _degreeController.text : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontStyle: _degreeController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
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
                                    "Certification",
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
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _certificationController,
                                      decoration: InputDecoration(
                                        hintText: "Certification",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _certificationController.text.isNotEmpty ? _certificationController.text : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontStyle: _certificationController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
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
                                    "Early Childhood education credits",
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
                                  visible: _isEditing,
                                  child: Expanded(
                                    child: TextFormField(
                                      controller: _educationCreditsController,
                                      decoration: InputDecoration(
                                        hintText: "Enter Credit",
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  replacement: Text(
                                    _educationCreditsController.text.isNotEmpty ? _educationCreditsController.text : "None",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontStyle: _educationCreditsController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
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
