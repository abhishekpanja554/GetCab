import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:uber_clone/dataModels/user.dart';

String apiKey = 'AIzaSyDu3LOP9fTpiL-Vaa6YECeNDJNb8FFEhqw';

final CameraPosition kGooglePlex = CameraPosition(
  target: LatLng(24, 67),
  zoom: 14.4746,
);

auth.User currentLoggedUser;
Position currentPosition;
User currentUserInfo;
String serverKey =
    'AAAAsmFFLb8:APA91bEbVxH06hiUmFnaghFujacPquJrEovHYZulbeUoc0O5Sk3aM1tXUzH29Zf4inVkXbdjU-DxIeenULRvVgfYxuxA4USZiDmqyGsh3rZSdXsmr_imIjLwgWoToSt7MoPDcO9C4jEl';
