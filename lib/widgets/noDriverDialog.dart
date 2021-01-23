import 'package:flutter/material.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/widgets/TaxiOutlineButton.dart';

class NoDriverDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: BrandColors.colorlightPurple,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: BrandColors.colorlightPurple,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'No driver found',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'Brand-Bold',
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No available driver close by, we suggest you try again shortly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: 200,
                  child: TaxiOutlineButton(
                    title: 'CLOSE',
                    color: Color(0xFF40C1C9),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
