import 'package:flutter/material.dart';

class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  DrawerListTile({
    this.icon,
    this.onTap,
    this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(64, 75, 96, .9),
      elevation: 8.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(64, 75, 96, .9),
          borderRadius: BorderRadius.circular(3),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1.0,
                  color: Colors.white24,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Brand-Regular',
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
