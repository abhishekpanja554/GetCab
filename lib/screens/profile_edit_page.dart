import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/globalVariables.dart';
import 'package:uber_clone/helpers/helper_methods.dart';
import 'package:uber_clone/widgets/progress_dialog.dart';
import 'package:uber_clone/widgets/taxi_button.dart';

class ProfileEditPage extends StatefulWidget {
  static String id = 'profile_edit_page';
  final BuildContext ancestorContext;
  ProfileEditPage({this.ancestorContext});
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  var fullNameController = TextEditingController();

  var emailController = TextEditingController();

  var phoneController = TextEditingController();

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

  void updateInfo() async {
    FocusScope.of(context).unfocus();
    String uid = currentUserInfo.id;
    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users/$uid');

    userRef.child('fullname').set(fullNameController.text);
    userRef.child('email').set(emailController.text);
    userRef.child('phone').set(phoneController.text);

    HelperMethods.getCurrentUserInfo(widget.ancestorContext);

    showDialog(
      barrierDismissible: false,
      context: scaffoldKey.currentContext,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Updating',
      ),
    );

    await Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context);
    });

    Navigator.pop(context, 'close');
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: mediaQuery.size.height,
          width: mediaQuery.size.width,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                child: Container(
                  alignment: Alignment.center,
                  color: Color(0xFF1F2240),
                  height: mediaQuery.size.height * 0.2,
                  width: mediaQuery.size.width,
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      'Edit Your Profile',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 25,
                        fontFamily: 'Brand-Bold',
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  height: mediaQuery.size.height * 0.85,
                  width: mediaQuery.size.width,
                  decoration: BoxDecoration(
                    color: Color(0xFF3B4254),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(6, 1),
                        blurRadius: 10,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: fullNameController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF40C1C9),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF40C1C9),
                                  ),
                                ),
                                labelText: 'Full Name',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white54,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF40C1C9),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF40C1C9),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF40C1C9),
                                  ),
                                ),
                                labelText: 'Email Address',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white54,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF40C1C9),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF40C1C9),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF40C1C9),
                                  ),
                                ),
                                labelText: 'Mobile Number',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white54,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF40C1C9),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 100,
                            ),
                            TaxiButton(
                              buttonText: 'UPDATE',
                              onPressed: () async {
                                //check network availability
                                var connectivityResult =
                                    await (Connectivity().checkConnectivity());
                                if (connectivityResult !=
                                        ConnectivityResult.mobile &&
                                    connectivityResult !=
                                        ConnectivityResult.wifi) {
                                  showSnackBar('No internet connectivity');
                                  return;
                                }

                                //full name validation
                                if (fullNameController.text.length < 3) {
                                  showSnackBar(
                                      'Please provide a valid Full Name');
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

                                updateInfo();
                              },
                              color: BrandColors.colorlightPurple,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
