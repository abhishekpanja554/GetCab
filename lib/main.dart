import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/dataProvider/app_data.dart';
import 'package:uber_clone/screens/login_page.dart';
import 'package:uber_clone/screens/main_page.dart';
import 'package:uber_clone/screens/registration_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
            appId: '1:766136102335:android:0acce4523d3064146ac50a',
            apiKey: 'AIzaSyDu3LOP9fTpiL-Vaa6YECeNDJNb8FFEhqw',
            projectId: 'flutter-firebase-plugins',
            messagingSenderId: '297855924061',
            databaseURL: 'https://geetaxi-5e2be.firebaseio.com',
          )
        : FirebaseOptions(
            appId: '1:766136102335:android:0acce4523d3064146ac50a',
            apiKey: 'AIzaSyDu3LOP9fTpiL-Vaa6YECeNDJNb8FFEhqw',
            messagingSenderId: '297855924061',
            projectId: 'flutter-firebase-plugins',
            databaseURL: 'https://geetaxi-5e2be.firebaseio.com',
          ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Uber Clone',
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: MainPage.id,
        routes: {
          LoginPage.id: (context) => LoginPage(),
          RegistrationPage.id: (context) => RegistrationPage(),
          MainPage.id: (context) => MainPage()
        },
      ),
    );
  }
}
