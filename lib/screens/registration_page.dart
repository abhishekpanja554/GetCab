import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/screens/login_page.dart';
import 'package:uber_clone/screens/main_page.dart';
import 'package:uber_clone/widgets/progress_dialog.dart';
import 'package:uber_clone/widgets/taxi_button.dart';
import 'package:connectivity/connectivity.dart';

class RegistrationPage extends StatefulWidget {
  static String id = 'registration_page';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void registerUser() async {
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Signing you up',
      ),
    );
    UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .catchError((ex) {
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    });

    if (userCredential != null) {
      DatabaseReference dbRef = FirebaseDatabase.instance
          .reference()
          .child('users/${userCredential.user.uid}');

      //creating Map of user data to send
      Map<String, String> userData = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };

      dbRef.set(userData);
      //Navigate to main page after successful registration
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    }
  }

  //creating controllers to access the text of textfield
  var fullNameController = TextEditingController();

  var emailController = TextEditingController();

  var phoneController = TextEditingController();

  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                Image(
                  image: AssetImage('images/logo.png'),
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Create a rider\'s Account',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Brand-Bold',
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      TaxiButton(
                        buttonText: 'SIGN UP',
                        onPressed: () async {
                          //check network availability
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('No internet connectivity');
                            return;
                          }

                          //full name validation
                          if (fullNameController.text.length < 3) {
                            showSnackBar('Please provide a valid Full Name');
                            return;
                          }

                          //email validation
                          if (!emailController.text.contains('@')) {
                            showSnackBar(
                                'Please provide a valid Email address');
                            return;
                          }

                          //phone validation
                          if (phoneController.text.length < 10) {
                            showSnackBar(
                                'Please provide a valid mobile number');
                            return;
                          }

                          //password validation
                          if (passwordController.text.length < 8) {
                            showSnackBar(
                                'The password length should be at least 8 digits');
                            return;
                          }

                          registerUser();
                        },
                        color: BrandColors.colorGreen,
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginPage.id, (route) => false);
                  },
                  child: Text('Already have a RIDER account? SIGN IN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
