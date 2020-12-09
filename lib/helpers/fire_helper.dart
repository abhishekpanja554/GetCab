import 'package:uber_clone/dataModels/nearby_driver.dart';

class FireHelper {
  static List<NearByDriver> nearByDriverList = [];

  static void removeFromDrivers(String key) {
    int index = nearByDriverList.indexWhere((element) => element.key == key);
    nearByDriverList.removeAt(index);
  }

  static void updateDriversLocation(NearByDriver driver) {
    int index =
        nearByDriverList.indexWhere((element) => element.key == driver.key);
    nearByDriverList[index].longitude = driver.longitude;
    nearByDriverList[index].latitude = driver.latitude;
  }
}
