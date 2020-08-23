import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop_lovers_app/widgets/header.dart';
class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount>
{
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _formkey = GlobalKey<FormState>();
  String username;
  submit()
  {
    final form = _formkey.currentState;
    setState(() {
      if(form.validate())
      {
        form.save();
        SnackBar snackbar = SnackBar(content: Text('welcome $username'),);
        _scaffoldkey.currentState.showSnackBar(snackbar);
        Timer(Duration(seconds:2),(){
          Navigator.pop(context,username);
        });
      }
    });
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      key: _scaffoldkey,
      appBar: header(context, titletext: "Set up your profile",removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.only(top: 25.0) ,
                  child: Center(
                    child: Text("Create a username", style: TextStyle(fontSize: 25.0),),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    child: Form(
                      key: _formkey,
                      autovalidate: true,
                      child: TextFormField(
                        validator: (value){
                          if(value.trim().length < 3 || value.isEmpty)
                          {
                            return 'user name short change your user name';
                          }else{
                            return null;
                          }
                        },
                        onSaved: (value)=> username = value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'user name',
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: 'must be at least 3 characters'
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    width: 350,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.white, fontSize: 15.0,fontWeight: FontWeight.bold),
                        )
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
