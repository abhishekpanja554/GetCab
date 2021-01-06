import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/dataModels/address.dart';
import 'package:uber_clone/dataModels/direction_details.dart';
import 'package:uber_clone/dataModels/nearby_driver.dart';
import 'package:uber_clone/dataProvider/app_data.dart';
import 'package:uber_clone/globalVariables.dart';
import 'package:uber_clone/helpers/fire_helper.dart';
import 'package:uber_clone/helpers/helper_methods.dart';
import 'package:uber_clone/helpers/map_toolkit_helper.dart';
import 'package:uber_clone/rideVariables.dart';
import 'package:uber_clone/screens/search_page.dart';
import 'package:uber_clone/styles/styles.dart';
import 'package:uber_clone/widgets/noDriverDialog.dart';
import 'package:uber_clone/widgets/brand_divider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_clone/widgets/paymentDialog.dart';
import 'package:uber_clone/widgets/progress_dialog.dart';
import 'package:uber_clone/widgets/taxi_button.dart';

class MainPage extends StatefulWidget {
  static String id = 'main_page';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();

  GoogleMapController mapController;

  double mapBottomPadding = 0;

  var geoLocator = Geolocator();

  List<LatLng> polyLineCoordinates = [];

  Set<Polyline> _polylines = {};

  Set<Marker> _markers = {};

  Set<Circle> _circles = {};

  double searchSheetHeight = 295;

  double rideDetailsHeight = 0;

  double requestSheetHeight = 0;

  double tripInfoSheetHeight = 0;

  bool drawerCanOpen = true;

  BitmapDescriptor nearByIcon;

  DirectionDetails tripDirectionDetails;

  DatabaseReference rideRef;

  bool nearbyDriversKeyLoaded = false;

  List<NearByDriver> availableDrivers;

  int driverRequestTimeOut = 0;

  String appStateVariable = 'NORMAL';

  StreamSubscription<Event> rideSubscription;

  bool isRequestingLocDetails = false;

  Position carPosition;

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    // confirm location
    await HelperMethods.findCoordinateAddress(position, context);

    startGeoFireListener();
  }

  void showRequestSheet() {
    setState(() {
      rideDetailsHeight = 0;
      requestSheetHeight = 260;
      mapBottomPadding = 260;
      drawerCanOpen = true;
    });

    createRideRequest();
  }

  void createMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );

      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'images/car_android.png')
          .then((icon) {
        nearByIcon = icon;
      });
    }
  }

  void startGeoFireListener() {
    Geofire.initialize('driversAvailable');
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 5000)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearByDriver driver = NearByDriver();
            driver.key = map['key'];
            driver.latitude = map['latitude'];
            driver.longitude = map['longitude'];

            FireHelper.nearByDriverList.add(driver);

            if (nearbyDriversKeyLoaded) {
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromDrivers(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearByDriver driver = NearByDriver();
            driver.key = map['key'];
            driver.latitude = map['latitude'];
            driver.longitude = map['longitude'];

            FireHelper.updateDriversLocation(driver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyDriversKeyLoaded = true;
            updateDriversOnMap();
            break;
        }
      }
    });
  }

  void showTripSheet() {
    setState(() {
      requestSheetHeight = 0;
      tripInfoSheetHeight = 260;
      mapBottomPadding = 260;
    });
  }

  void updateDriversOnMap() {
    setState(() {
      _markers.clear();
    });

    Set<Marker> tempMarkers = Set<Marker>();
    for (NearByDriver nearByDriver in FireHelper.nearByDriverList) {
      LatLng driverPos = LatLng(nearByDriver.latitude, nearByDriver.longitude);
      Marker thisMarker = Marker(
        markerId: MarkerId('driver${nearByDriver.key}'),
        position: driverPos,
        icon: nearByIcon,
        rotation: HelperMethods.randomNumberGenerator(360),
      );
      tempMarkers.add(thisMarker);
    }

    setState(() {
      _markers = tempMarkers;
    });
  }

  void showDetailSheet() async {
    await getDirection();
    setState(() {
      searchSheetHeight = 0;
      rideDetailsHeight = 260;
      mapBottomPadding = 260;
      drawerCanOpen = false;
    });
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    String address =
        await HelperMethods.findCoordinateAddress(position, context);
    print(address);
  }

  void sentRequestToDriver() {
    if (availableDrivers.length == 0) {
      cancelRequest();
      resetApp();
      //No driver found
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog(),
      );
      return;
    }

    var driver = availableDrivers[0];
    sendNotificationToDriver(driver);
    availableDrivers.removeAt(0);
  }

  void sendNotificationToDriver(NearByDriver driver) {
    DatabaseReference newTripRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/newTrip');

    newTripRef.set(rideRef.key);

    //get token to notify the driver
    DatabaseReference driverTokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/token');

    driverTokenRef.once().then((DataSnapshot snapshot) {
      if (snapshot != null) {
        String token = snapshot.value.toString();

        //send push notification to nearby driver
        HelperMethods.sendPushNotificationToDriver(token, context, rideRef.key);
      } else {
        return;
      }

      const oneSecond = Duration(seconds: 1);
      Timer timer = Timer.periodic(oneSecond, (timer) {
        //stop timer when ride is cancelled
        if (appStateVariable != 'REQUESTING') {
          newTripRef.set('cancelled');
          newTripRef.onDisconnect();
          driverRequestTimeOut = 0;
          timer.cancel();
        }
        driverRequestTimeOut++;

        //a value event listener for driver accepting the ride
        newTripRef.onValue.listen((event) {
          //confirming acceptance of trip
          if (event.snapshot.value.toString() == 'accepted') {
            newTripRef.onDisconnect();
            driverRequestTimeOut = 0;
            timer.cancel();
          }
        });

        if (driverRequestTimeOut == 30) {
          //inform driver of timeOut
          newTripRef.set('time_out');
          newTripRef.onDisconnect();
          driverRequestTimeOut = 0;
          timer.cancel();

          //send request to next closest driver
          sentRequestToDriver();
        }
      });
    });
  }

  void cancelRequest() async {
    rideRef.remove();
    setState(() {
      appStateVariable = 'NORMAL';
    });
  }

  @override
  void initState() {
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }

  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destAddress;

    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };

    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.fullName,
      'rider_phone': currentUserInfo.phone,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'pickup': pickupMap,
      'destination': destinationMap,
      'payment_method': 'cash',
      'driver_id': 'waiting',
    };

    rideRef.set(rideMap);

    rideSubscription = rideRef.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }

      if (event.snapshot.value['driver_name'] != null) {
        setState(() {
          driverName = event.snapshot.value['driver_name'].toString();
        });
      }

      if (event.snapshot.value['phone'] != null) {
        setState(() {
          driverPhone = event.snapshot.value['phone'].toString();
        });
      }

      if (event.snapshot.value['car_color'] != null) {
        setState(() {
          carColor = event.snapshot.value['car_color'].toString();
        });
      }

      if (event.snapshot.value['car_model'] != null) {
        setState(() {
          carModel = event.snapshot.value['car_model'].toString();
        });
      }

      if (event.snapshot.value['driver_location'] != null) {
        double driverLat = double.parse(
            event.snapshot.value['driver_location']['latitude'].toString());

        double driverLng = double.parse(
            event.snapshot.value['driver_location']['longitude'].toString());

        LatLng driverLocation = LatLng(driverLat, driverLng);

        if (statusOfRide == 'accepted') {
          updateDriverArrival(driverLocation);
        } else if (statusOfRide == 'on_trip') {
          updateDestinationReach(driverLocation);
          getLocationUpdates(driverLocation);
        } else if (statusOfRide == 'arrived') {
          setState(() {
            tripStatusDisplay = 'Driver has arrived';
          });
        }
      }

      if (event.snapshot.value['status'] != null) {
        statusOfRide = event.snapshot.value['status'].toString();
      }

      if (statusOfRide == 'accepted') {
        showTripSheet();
        Geofire.stopListener();
        removeMarkers();
      }

      if (statusOfRide == 'completed') {
        if (event.snapshot.value['fare'] != null) {
          int fares = int.parse(event.snapshot.value['fare'].toString());
          var response = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => PaymentDialog(
              paymentMethod: 'CASH',
              fares: fares,
            ),
          );

          if (response == 'close') {
            rideRef.onDisconnect();
            rideRef = null;
            rideSubscription.cancel();
            rideSubscription = null;
            resetApp();
          }
        }
      }
    });
  }

  void getLocationUpdates(LatLng driverLoc) {
    LatLng oldPos = LatLng(0, 0);

    // carPositionStream = Geolocator.getPositionStream(
    //   desiredAccuracy: LocationAccuracy.bestForNavigation,
    //   distanceFilter: 4,
    //   timeInterval: 200,
    // ).listen((Position position) {
    //   currentPosition = position;
    //   carPosition = position;
    LatLng pos = LatLng(driverLoc.latitude, driverLoc.longitude);

    double rotation = MapToolkitHelper.getMarkerRotation(
      oldPos.latitude,
      oldPos.longitude,
      pos.latitude,
      pos.longitude,
    );

    Marker carMarker = Marker(
      markerId: MarkerId('moving'),
      position: pos,
      icon: nearByIcon,
      infoWindow: InfoWindow(title: 'Current Location'),
      rotation: rotation,
    );

    setState(() {
      CameraPosition cp = new CameraPosition(
        target: pos,
        zoom: 17,
      );
      mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
      _markers.removeWhere((element) => element.markerId.value == 'moving');
      _markers.add(carMarker);
    });

    oldPos = pos;
  }

  void updateDriverArrival(LatLng driverLocation) async {
    if (!isRequestingLocDetails) {
      isRequestingLocDetails = true;
      LatLng myPosition =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      var thisDetails =
          await HelperMethods.getDirectionDetails(driverLocation, myPosition);

      if (thisDetails == null) {
        return;
      }
      setState(() {
        tripStatusDisplay =
            'Driver is Arriving - ${thisDetails.durationText} away';
      });

      isRequestingLocDetails = false;
    }
  }

  void updateDestinationReach(LatLng driverLocation) async {
    if (!isRequestingLocDetails) {
      isRequestingLocDetails = true;
      Address destination =
          Provider.of<AppData>(context, listen: false).destAddress;
      LatLng destLatLng = LatLng(destination.latitude, destination.longitude);
      var thisDetails =
          await HelperMethods.getDirectionDetails(driverLocation, destLatLng);

      if (thisDetails == null) {
        return;
      }
      setState(() {
        tripStatusDisplay =
            'Driving to Destination - ${thisDetails.durationText}';
      });

      isRequestingLocDetails = false;
    }
  }

  void removeMarkers() {
    setState(() {
      _markers
          .removeWhere((element) => element.markerId.value.contains('driver'));
    });
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  child: Row(
                    children: [
                      Image.asset(
                        'images/user_icon.png',
                        height: 60,
                        width: 60,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Abhishek',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Brand-Bold',
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('View Profile'),
                        ],
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
              BrandDivider(),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(
                  Icons.card_giftcard,
                ),
                title: Text(
                  'Free Rides',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.credit_card,
                ),
                title: Text(
                  'Payments',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                ),
                title: Text(
                  'Ride History',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.contact_support_outlined,
                ),
                title: Text(
                  'Support',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                  'Free Rides',
                  style: kDrawerItemStyle,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // google map
          GoogleMap(
            padding: EdgeInsets.only(
              bottom: mapBottomPadding,
              top: 40,
            ),
            initialCameraPosition: kGooglePlex,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottomPadding = 295;
              });
              // getCurrentLocation();
              setupPositionLocator();
            },
          ),
          //menu button
          Positioned(
            top: 57,
            left: 20,
            child: GestureDetector(
              onTap: () {
                if (drawerCanOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          //search sheet
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(
                milliseconds: 150,
              ),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Nice to see you!',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Where are you going?',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Brand-Bold',
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var response = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(),
                            ),
                          );

                          if (response == 'getDirection') {
                            showDetailSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                spreadRadius: 0.5,
                                offset: Offset(
                                  0.7,
                                  0.7,
                                ),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Search Destination',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Home'),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                'Your residential address',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.colorDimText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      BrandDivider(),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                'Your office address',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.colorDimText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //Ride Details sheet
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(
                milliseconds: 150,
              ),
              curve: Curves.easeIn,
              child: Container(
                height: rideDetailsHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: BrandColors.colorAccent1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'images/taxi.png',
                                height: 70,
                                width: 70,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Taxi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Brand-Bold',
                                    ),
                                  ),
                                  Text(
                                    (tripDirectionDetails != null)
                                        ? tripDirectionDetails.distanceText
                                        : '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: BrandColors.colorTextLight,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Text(
                                (tripDirectionDetails != null)
                                    ? '\u20B9${HelperMethods.estimateFairs(tripDirectionDetails)}'
                                    : '',
                                style: TextStyle(
                                  fontFamily: 'Brand-Bold',
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyBillAlt,
                              size: 18,
                              color: BrandColors.colorTextLight,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text('Cash'),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: BrandColors.colorTextLight,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: TaxiButton(
                          buttonText: 'REQUEST CAB',
                          color: BrandColors.colorGreen,
                          onPressed: () {
                            setState(() {
                              appStateVariable = 'REQUESTING';
                            });
                            showRequestSheet();
                            availableDrivers = FireHelper.nearByDriverList;
                            sentRequestToDriver();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //request sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(
                microseconds: 150,
              ),
              curve: Curves.easeIn,
              child: Container(
                height: requestSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      LinearProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Requesting a Ride...',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: BrandColors.colorTextSemiLight,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          cancelRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              width: 1,
                              color: BrandColors.colorLightGrayFair,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel Ride',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //trip info sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(
                microseconds: 150,
              ),
              curve: Curves.easeIn,
              child: Container(
                height: tripInfoSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tripStatusDisplay,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Brand-Bold',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      BrandDivider(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '$carColor - $carModel',
                        style: TextStyle(color: BrandColors.colorTextLight),
                      ),
                      Text(
                        driverName,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      BrandDivider(),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    width: 1,
                                    color: BrandColors.colorTextLight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.call,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Call'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    width: 1,
                                    color: BrandColors.colorTextLight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.list,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Details'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    width: 1,
                                    color: BrandColors.colorTextLight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.cancel_outlined,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Cancel'),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Please wait...',
      ),
    );

    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destLatLng);
    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polyLineCoordinates.clear();

    if (results.isNotEmpty) {
      // loop through all pointLatLng points and convert them
      // to a list of LatLng, required by the Polyline

      results.forEach((PointLatLng points) {
        polyLineCoordinates.add(LatLng(points.latitude, points.longitude));
      });

      _polylines.clear();

      setState(() {
        Polyline polyline = Polyline(
          polylineId: PolylineId('polyId'),
          color: Color.fromARGB(255, 95, 109, 237),
          points: polyLineCoordinates,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );

        _polylines.add(polyline);
      });

      LatLngBounds bounds;

      if (pickLatLng.latitude > destLatLng.latitude &&
          pickLatLng.longitude > destLatLng.longitude) {
        bounds = LatLngBounds(
          southwest: destLatLng,
          northeast: pickLatLng,
        );
      } else if (pickLatLng.longitude > destLatLng.longitude) {
        bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destLatLng.longitude),
          northeast: LatLng(destLatLng.latitude, pickLatLng.longitude),
        );
      } else if (pickLatLng.latitude > destLatLng.latitude) {
        bounds = LatLngBounds(
          southwest: LatLng(destLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destLatLng.longitude),
        );
      } else {
        bounds = LatLngBounds(
          southwest: pickLatLng,
          northeast: destLatLng,
        );
      }

      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

      Marker pickupMarker = Marker(
        markerId: MarkerId('pickUp'),
        position: pickLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: pickup.placeName,
          snippet: 'My Location',
        ),
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId('destination'),
        position: destLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: destination.placeName,
          snippet: 'Destination Location',
        ),
      );

      setState(() {
        _markers.add(pickupMarker);
        _markers.add(destinationMarker);
      });

      Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.green,
        strokeWidth: 3,
        radius: 12,
        center: pickLatLng,
        fillColor: BrandColors.colorGreen,
      );

      Circle destinationCircle = Circle(
        circleId: CircleId('destination'),
        strokeColor: BrandColors.colorAccentPurple,
        strokeWidth: 3,
        radius: 12,
        center: destLatLng,
        fillColor: BrandColors.colorAccentPurple,
      );

      setState(() {
        _circles.add(pickupCircle);
        _circles.add(destinationCircle);
      });
    }
  }

  void resetApp() {
    setState(() {
      polyLineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
      rideDetailsHeight = 0;
      requestSheetHeight = 0;
      searchSheetHeight = 295;
      mapBottomPadding = 295;
      drawerCanOpen = true;
      statusOfRide = '';
      driverName = '';
      driverPhone = '';
      carModel = '';
      carColor = '';
      tripStatusDisplay = 'Driver is Arriving';
    });

    setupPositionLocator();
  }
}
