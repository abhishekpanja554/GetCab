import 'package:flutter/foundation.dart';
import 'package:uber_clone/dataModels/address.dart';
import 'package:uber_clone/dataModels/history.dart';
import 'package:uber_clone/dataModels/user.dart';

class AppData extends ChangeNotifier {
  Address pickupAddress;
  Address destAddress;
  User currentUserDetails;
  int tripCount = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistory = [];

  void updateCurrentUser(User newInfo){
    currentUserDetails = newInfo;
    notifyListeners();
  }

  void updateTripCount(int newTripCount) {
    tripCount = newTripCount;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys) {
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistory(History historyItem) {
    if (historyItem == null) {
      tripHistory = [];
    } else {
      tripHistory.add(historyItem);
    }
    notifyListeners();
  }

  void updatePickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestAddress(Address destination) {
    destAddress = destination;
    notifyListeners();
  }
}
