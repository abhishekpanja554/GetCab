import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/dataProvider/app_data.dart';
import 'package:uber_clone/widgets/brand_divider.dart';
import 'package:uber_clone/widgets/history_tile.dart';

class HistoryPage extends StatefulWidget {
  static String id = 'historyPage';

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1F2240),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trips History',
            ),
            Icon(
              Icons.history,
            ),
          ],
        ),
        leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: (Provider.of<AppData>(context, listen: false).tripHistory.length <=
                  0 ||
              Provider.of<AppData>(context, listen: false).tripHistory[0] ==
                  null)
          ? Container(
              height: mediaQuery.size.height,
              width: mediaQuery.size.width,
              color: Color(0xFF3B4254),
              child: Center(
                child: Text(
                  'You have no ride history',
                  style: TextStyle(
                    fontFamily: 'Brand-Bold',
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : Container(
              height: mediaQuery.size.height,
              width: mediaQuery.size.width,
              color: Color(0xFF3B4254),
              padding: EdgeInsets.symmetric(horizontal: 10,),
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Color.fromRGBO(64, 75, 96, .9),
                    elevation: 3,
                    child: HistoryTile(
                      history: Provider.of<AppData>(context, listen: false)
                          .tripHistory[index],
                    ),
                  );
                },
                itemCount: Provider.of<AppData>(context).tripHistory.length,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
              ),
            ),
    );
  }
}
