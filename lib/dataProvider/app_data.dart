import 'package:flutter/foundation.dart';
import 'package:uber_clone/dataModels/address.dart';

class AppData extends ChangeNotifier {
  Address pickupAddress;
  Address destAddress;

  void updatePickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestAddress(Address destination) {
    destAddress = destination;
    notifyListeners();
  }
}
