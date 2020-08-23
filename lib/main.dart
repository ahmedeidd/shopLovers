import 'package:flutter/material.dart';
import 'package:shop_lovers_app/Pages/home_page_EID.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Shop Lovers',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,//primryColor
          accentColor: Colors.orange,
        ),
        home: Home()
    );
  }
}


