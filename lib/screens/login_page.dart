import 'package:flutter/material.dart';
import '../common/app_color.dart';
import '../common/app_icon.dart';
import '../common/app_style.dart';

// 1. Authentication Service
class AuthService {
  Future<bool> signIn({required String email, required String password}) async {
    // Simulate authentication process
    // In a real application, this would involve calling an API
    // and verifying the credentials
    if (email == 'admin@gmail.com' && password == 'abc123') {
      // Authentication successful
      return true;
    } else {
      // Authentication failed
      return false;
    }
  }
}

// 2. Handle Login Button Tap
void handleSignIn(BuildContext context, String email, String password) async {
  // Create an instance of the authentication service
  AuthService authService = AuthService();

  // Call the signIn method with entered credentials
  bool isAuthenticated = await authService.signIn(email: email, password: password);

  if (isAuthenticated) {
    // Navigate to the next screen (e.g., dashboard)
    Navigator.pushReplacementNamed(context, '/HomePage');
  } else {
    // Show an error message or dialog to indicate authentication failure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invalid email or password'),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor.backColor,
      body: SizedBox(
        height: height,
        width: width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: height,
                color: AppColor.mainPurpleColor,
                child: Center(
                  child: Text(
                    'Admin Panel',
                    style: ralewayStyle.copyWith(
                      fontSize: 48.0,
                      color: AppColor.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: height,
                margin: EdgeInsets.symmetric(horizontal: height * 0.12),
                color: AppColor.backColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.2),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'KiddieLink',
                          style: ralewayStyle.copyWith(
                            fontSize: 40.0,
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ]),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      'ChildCare Management System',
                      style: ralewayStyle.copyWith(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: AppColor.textColor,
                      ),
                    ),
                    SizedBox(height: height * 0.064),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Email',
                        style: ralewayStyle.copyWith(
                          fontSize: 20.0,
                          color: AppColor.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Container(
                      height: 50.0,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: AppColor.white,
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        style: ralewayStyle.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColor.black,
                          fontSize: 14.0,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              AppIcons.emailIcon,
                              height: 20,
                              width: 20,
                            ),
                          ),
                          hintText: 'Enter Email',
                          hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColor.greyColor,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Password',
                        style: ralewayStyle.copyWith(
                          fontSize: 20.0,
                          color: AppColor.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Container(
                      height: 50.0,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: AppColor.white,
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        style: ralewayStyle.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColor.black,
                          fontSize: 14.0,
                        ),

                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              AppIcons.eyeIcon,
                              height: 20,
                              width: 20,
                            ),
                          ),
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              AppIcons.lockIcon,
                              height: 20,
                              width: 20,
                            ),
                          ),
                          hintText: 'Enter Password',
                          hintStyle: ralewayStyle.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColor.greyColor,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: ralewayStyle.copyWith(
                            fontSize: 12.0,
                            color: AppColor.darkPurpleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (){
                          // 3. Inside your SignIn button onPressed callback
                          String email = _emailController.text; // Get email from TextFormField
                          String password = _passwordController.text; // Get password from TextFormField
                          handleSignIn(context, email, password);
                        },
                        borderRadius: BorderRadius.circular(16.0),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 18.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: AppColor.mainPurpleColor,
                          ),
                          child: Text(
                            'Sign In',
                            style: ralewayStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColor.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
