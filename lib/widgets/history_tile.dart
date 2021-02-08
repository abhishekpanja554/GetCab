import 'package:flutter/material.dart';
import 'package:uber_clone/brand_colors.dart';
import 'package:uber_clone/dataModels/history.dart';
import 'package:uber_clone/helpers/helper_methods.dart';

class HistoryTile extends StatefulWidget {
  final History history;
  HistoryTile({this.history});

  @override
  _HistoryTileState createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  var list = [];

  void createList() {
    for (int i = 0; i < int.parse(widget.history.rating); i++) {
      list.add(i);
    }
  }

  @override
  void initState() {
    createList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(64, 75, 96, .9),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
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
                        child: Text(
                  (widget.history.pickup == null) ? '' : widget.history.pickup,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ))),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '₹${(widget.history.fares == null) ? '' : widget.history.fares}',
                  style: TextStyle(
                    fontFamily: 'Brand-Bold',
                    fontSize: 16,
                    color: Color(0xFF40C1C9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Image.asset(
                'images/desticon.png',
                height: 16,
                width: 16,
              ),
              SizedBox(
                width: 18,
              ),
              Text(
                (widget.history.destination == null)
                    ? ''
                    : widget.history.destination,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                HelperMethods.dateFormatter(widget.history.createdAt),
                style: TextStyle(color: BrandColors.colorTextLight),
              ),
              list == null || list.isEmpty
                  ? Text('')
                  : Row(
                      children: [
                        for (var i in list)
                          Icon(
                            Icons.star,
                            color: Colors.yellow[900],
                          ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
