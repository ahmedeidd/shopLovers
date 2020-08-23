import 'package:flutter/material.dart';

AppBar header(context, {bool isApptitle = false , String titletext
  , removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(

      isApptitle ? "SHOP LOVERS" : titletext,
      style: TextStyle(fontFamily: isApptitle ? "Signatra" : ""
          , fontSize: isApptitle ? 50.0 : 22.0
          ,color: Colors.white),

      overflow: TextOverflow.ellipsis,

    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
