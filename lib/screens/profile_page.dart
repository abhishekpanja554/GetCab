import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/dataProvider/app_data.dart';
import 'package:uber_clone/helpers/helper_methods.dart';
import 'package:uber_clone/screens/profile_edit_page.dart';
import 'package:uber_clone/widgets/brand_divider.dart';

class ProfilePage extends StatefulWidget {
  static String id = 'profile_page';
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var response;
  double editBtnYOffset = 6;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFF3B4254),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        displacement: 80,
        onRefresh: () async {
          setState(() {
            HelperMethods.getCurrentUserInfo(context);
          });
          
          await Future.delayed(Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                color: Color(0xFF3B4254),
                height: mediaQuery.size.height * 0.3,
                child: Stack(
                  children: [
                    Container(
                      height: mediaQuery.size.height * 0.3 - 75,
                      decoration: BoxDecoration(
                        color: Color(0xFF1F2240),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 5),
                            blurRadius: 20,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: (mediaQuery.size.width / 2) - 75,
                      left: (mediaQuery.size.width / 2) - 75,
                      child: PhysicalModel(
                        shape: BoxShape.circle,
                        elevation: 15,
                        color: Colors.black38,
                        child: Hero(
                          tag: 'profile_pic',
                          child: CircleAvatar(
                            radius: 75,
                            child: Image.asset(
                              'images/user_icon.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 160,
                      right: 0,
                      left: 0,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: 50,
                        width: 100,
                        child: Text(
                          'Your Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: 'Brand-Regular',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 30,
                  left: 10,
                  right: 10,
                ),
                height: (mediaQuery.size.height * 0.7) - 30,
                width: mediaQuery.size.width,
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      color: Color.fromRGBO(64, 75, 96, .9),
                      elevation: 5,
                      child: ListTile(
                        leading: Text(
                          'Name :',
                          style: TextStyle(
                            fontFamily: 'Brand-Bold',
                            color: Colors.white70,
                          ),
                        ),
                        title: Text(
                          Provider.of<AppData>(context, listen: false)
                                  .currentUserDetails
                                  .fullName ??
                              'Name',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Brand-Regular',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    BrandDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      color: Color.fromRGBO(64, 75, 96, .9),
                      elevation: 5,
                      child: ListTile(
                        leading: Text(
                          'Email :',
                          style: TextStyle(
                            fontFamily: 'Brand-Bold',
                            color: Colors.white70,
                          ),
                        ),
                        title: Text(
                          Provider.of<AppData>(context, listen: false)
                                  .currentUserDetails
                                  .email ??
                              'Email',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Brand-Regular',
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    BrandDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      color: Color.fromRGBO(64, 75, 96, .9),
                      elevation: 5,
                      child: ListTile(
                        leading: Text(
                          'Phone :',
                          style: TextStyle(
                            fontFamily: 'Brand-Bold',
                            color: Colors.white70,
                          ),
                        ),
                        title: Text(
                          Provider.of<AppData>(context, listen: false)
                                  .currentUserDetails
                                  .phone ??
                              'Phone',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Brand-Regular',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: 147,
                      decoration: BoxDecoration(
                        color: BrandColors.colorVeryLightPurple,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(1, editBtnYOffset),
                            blurRadius: 5,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTapDown: (val) {
                          setState(() {
                            editBtnYOffset = 2;
                          });
                        },
                        onTapUp: (val) {
                          setState(() {
                            editBtnYOffset = 6;
                          });
                        },
                        onTap: () async {
                          response = await Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return ProfileEditPage(
                              ancestorContext: _scaffoldKey.currentContext,
                            );
                          }));

                          if(response == 'close'){
                            _refreshIndicatorKey.currentState.show();
                          }
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              backgroundColor: BrandColors.colorlightPurple,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Brand-Regular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
