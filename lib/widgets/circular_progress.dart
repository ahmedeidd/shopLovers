import 'package:flutter/material.dart';

Container circularProgress()
{
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
    ),
  );
}

Container linearProgress()
{
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(bottom: 10),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
    ),
  );
}