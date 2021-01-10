import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/dataModels/place_prediction.dart';
import 'package:uber_clone/dataProvider/app_data.dart';
import 'package:uber_clone/globalVariables.dart';
import 'package:uber_clone/helpers/network_helper.dart';
import 'package:uber_clone/widgets/brand_divider.dart';
import 'package:uber_clone/widgets/prediction_tile.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController();
  var focusDestination = FocusNode();
  bool isFocused = false;
  List<PlacePrediction> destPredictionList = [];

  void setFocus() {
    if (!isFocused) {
      FocusScope.of(context).requestFocus(focusDestination);
      isFocused = true;
    }
  }

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$apiKey&sessiontoken=1234567890&components=country:in';

      var response = await RequestHelper.getRequest(url);

      if (response == 'Failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictions = response['predictions'];
        var thisList = (predictions as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();

        setState(() {
          destPredictionList = thisList;
          if (destinationController.text.length == 0) {
            destPredictionList.clear();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();
    String address =
        Provider.of<AppData>(context).pickupAddress.placeName ?? '';

    pickupController.text = address;
    return Scaffold(
      backgroundColor: Color(0xFF222B60),
      body: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: BrandColors.colorDarkBlue,
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
              padding: const EdgeInsets.only(
                left: 24,
                top: 48,
                right: 24,
                bottom: 20,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      Center(
                        child: Text(
                          'Set Destination',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Brand-Bold',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'images/pickicon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: BrandColors.colorlightPurple,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: TextField(
                              style: TextStyle(
                                color: Color(0xFF40C1C9),
                              ),
                              controller: pickupController,
                              decoration: InputDecoration(
                                hintText: 'Pickup Location',
                                hintStyle: TextStyle(
                                  color: Color(0xFF40C1C9),
                                ),
                                fillColor: BrandColors.colorlightPurple,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  left: 10,
                                  top: 8,
                                  bottom: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'images/desticon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: BrandColors.colorlightPurple,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: TextField(
                              style: TextStyle(
                                color: Color(0xFF40C1C9),
                              ),
                              focusNode: focusDestination,
                              controller: destinationController,
                              onChanged: (value) => searchPlace(value),
                              decoration: InputDecoration(
                                hintText: 'Where to?',
                                hintStyle: TextStyle(
                                  color: Color(0xFF40C1C9),
                                ),
                                fillColor: BrandColors.colorlightPurple,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  left: 10,
                                  top: 8,
                                  bottom: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          (destPredictionList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        prediction: destPredictionList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        BrandDivider(),
                    itemCount: destPredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
