import 'package:firebase_core/firebase_core.dart';
import 'package:kiddielink_admin_panel/screens/teacher/component/personal_info.dart';
import 'package:kiddielink_admin_panel/screens/teacher/view_teacher_details.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiddielink_admin_panel/screens/dashboard.dart';
import 'package:kiddielink_admin_panel/screens/login_page.dart';
import 'package:kiddielink_admin_panel/screens/teacher/teacher_homepage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiddieLink - Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print ("Error");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Dashboard();
          }
          return CircularProgressIndicator();
        },
      ),
      routes: {
        '/HomePage': (context) => Dashboard(), // Register the homepage route
      },
    );
  }
}