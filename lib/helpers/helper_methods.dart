import 'dart:convert';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone/dataModels/address.dart';
import 'package:uber_clone/dataModels/direction_details.dart';
import 'package:uber_clone/dataModels/user.dart';
import 'package:uber_clone/dataProvider/app_data.dart';
import 'package:uber_clone/helpers/network_helper.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../globalVariables.dart';

class HelperMethods {
  static Future<String> findCoordinateAddress(
      Position position, context) async {
    String placeAddress = '';
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    var response = await RequestHelper.getRequest(url);
    if (response != 'Failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address();
      pickupAddress.latitude = position.latitude;
      pickupAddress.longitude = position.longitude;
      pickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }

  static void sendPushNotificationToDriver(
      String token, BuildContext context, String rideId) async {
    var destination = Provider.of<AppData>(context, listen: false).destAddress;
    var response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Destination, ${destination.placeName}',
            'title': 'NEW TRIP REQUEST'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'ride_id': rideId
          },
          'to': token,
        },
      ),
    );
  }

  static Future<DirectionDetails> getDirectionDetails(
      LatLng startPos, LatLng endPos) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPos.latitude},${startPos.longitude}&destination=${endPos.latitude},${endPos.longitude}&mode=driving&key=$apiKey';

    var response = await RequestHelper.getRequest(url);

    if (response == 'Failed') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static int estimateFairs(DirectionDetails details) {
    double baseFare = 80;
    double distanceFare = (details.distanceValue / 1000) * 8;
    double timeFare = (details.durationValue / 60) * 5;

    double totalFare = baseFare + distanceFare + timeFare;

    return totalFare.truncate();
  }

  static void getCurrentUserInfo() async {
    String uid;
    currentLoggedUser = auth.FirebaseAuth.instance.currentUser;
    if (currentLoggedUser != null) {
      uid = currentLoggedUser.uid;
    }
    DatabaseReference dbRef =
        FirebaseDatabase.instance.reference().child('users/$uid');

    dbRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentUserInfo = User.fromSnapshot(snapshot);
      }
    });
  }

  static double randomNumberGenerator(int max) {
    var randonGen = Random();
    int rand = randonGen.nextInt(max);
    return rand.toDouble();
  }
}
