import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/dataModels/address.dart';
import 'package:uber_clone/dataModels/place_prediction.dart';
import 'package:uber_clone/dataProvider/app_data.dart';
import 'package:uber_clone/globalVariables.dart';
import 'package:uber_clone/helpers/network_helper.dart';
import 'package:uber_clone/widgets/progress_dialog.dart';

class PredictionTile extends StatelessWidget {
  final PlacePrediction prediction;

  PredictionTile({this.prediction});

  void getPlaceDetails(String placeId, context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Please wait...',
      ),
    );

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'Failed') {
      return;
    }

    if (response['status'] == 'OK') {
      Address thisAddress = Address();
      thisAddress.placeName = response['result']['name'];
      thisAddress.placeId = placeId;
      thisAddress.latitude = response['result']['geometry']['location']['lat'];
      thisAddress.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDestAddress(thisAddress);

      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () => getPlaceDetails(prediction.placeId, context),
      padding: EdgeInsets.all(0),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF8971B2),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.mainText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF40C1C9),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        prediction.secondaryText ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.colorDimText,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
