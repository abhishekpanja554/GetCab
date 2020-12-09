import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:uber_clone/dataModels/user.dart';

String apiKey = 'AIzaSyDu3LOP9fTpiL-Vaa6YECeNDJNb8FFEhqw';

final CameraPosition kGooglePlex = CameraPosition(
  target: LatLng(24, 67),
  zoom: 14.4746,
);

auth.User currentLoggedUser;
User currentUserInfo;
