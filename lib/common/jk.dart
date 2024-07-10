import 'package:flutter/material.dart';

class ChildDashboard extends StatelessWidget {
  final String email;
  final Map<String, dynamic> parentData;
  final Map<String, dynamic> childInfo;

  const ChildDashboard({
    Key? key,
    required this.email,
    required this.parentData,
    required this.childInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          childInfo['full_name'] ?? 'Child',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE040FB),
                Color(0xFF7C4DFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle profile button press
            },
            child: Text(
              'Profile',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      childInfo['background_image_url'] ??
                          'https://via.placeholder.com/300',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    childInfo['image_url'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 60), // Space for the circular avatar
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16.0),
              children: List.generate(8, (index) {
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cleaning_services), // Replace with your icon
                      SizedBox(height: 8),
                      Text(
                        'Service ${index + 1}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
