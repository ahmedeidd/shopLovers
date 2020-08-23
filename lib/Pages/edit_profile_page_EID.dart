import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shop_lovers_app/Pages/home_page_EID.dart';
import 'package:shop_lovers_app/models/user.dart';
import 'package:shop_lovers_app/widgets/circular_progress.dart';
import 'package:image/image.dart' as Im;

class EditProfile extends StatefulWidget
{
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
{
  final _scaffolfkey = GlobalKey <ScaffoldState> ();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  File file;

  bool _displayNameValid = true;
  bool _bioValid = true;

  @override
  void initState()
  {
    super.initState();
    getUser();
  }
  getUser() async
  {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text=user.bio;

    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffolfkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            onPressed:() => Navigator.pop(context),
            icon:Icon(Icons.done,size: 30.0,color: Colors.green),
          )
        ],
      ),
      body: isLoading ? circularProgress() : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0 ),
                  child: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40.0,
                        backgroundImage: file == null ? CachedNetworkImageProvider(user.photoUrl) : FileImage(file),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(45.0),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt,size: 30.0,color: Colors.grey[400],),
                          onPressed: (){
                            setState(() {
                              SelectImage(context);
                            });
                          },),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0 ),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildBioField(),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: handlesubmitfile,
                  child: Text(
                    "Update Profile",
                    style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 22.0,fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0 ),
                  child: FlatButton.icon(
                      onPressed: logout,
                      icon: Icon(Icons.cancel,color: Colors.red,),
                      label: Text("Log out",style: TextStyle(color: Colors.red,fontSize: 20.0,),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  //*************************************************
  // start select image
  SelectImage(parentContext)
  {
    return showDialog(
        context: parentContext ,
        builder: (parentContext){
          return SimpleDialog(
            title: Text("Change your profile photo"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],

          );

        });
  }
  handleTakePhoto() async
  {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 675,
        maxWidth: 960,
    );
    if(file !=null) {
      setState(() {
        this.file = file;
      });
    }
  }
  handleChooseFromGallery() async
  {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(file !=null) {
      setState(() {
        this.file = file;
      });
    }
  }
  // start select image
  //***************************************************
  // start build Displsy Name Field && build Bio field
  Column buildDisplayNameField()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "DisplayName too short",
          ),
        ),
      ],
    );
  }
  Column buildBioField()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
  }
  // end build Displsy Name Field && build Bio field
  //***************************************************
  // start handle submit file
  handlesubmitfile() async
  {
    String photoUrl;
    if(file == null){
      photoUrl = user.photoUrl;
    }else{
      await compressImage();
      photoUrl = await uploadImage(file);
    }
    updateProfileData(photoUrl);
  }
  compressImage() async
  {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    String currentUserId = currentUser.id;
    final compressedImageFile = File('$path/img_$currentUserId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

    setState(() {
      file = compressedImageFile;
    });
  }
  Future<String> uploadImage(imageFile) async
  {
    String currentUserId = currentUser.id;
    StorageUploadTask uploadTask = storageRef.child('profile_$currentUserId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }
  updateProfileData(String photoUrl)
  {
    setState(() {
      if(displayNameController.text.trim().length < 3 || displayNameController.text.trim().isEmpty ) {
        _displayNameValid = false;
      } else{
        _displayNameValid = true;
      }

      if(bioController.text.trim().length > 200){
        _bioValid = false;
      }else{
        _bioValid = true;
      }

      if(file != null)
      {
        usersRef.document(widget.currentUserId).updateData({
          "photoUrl": photoUrl,
        });

        SnackBar snackBar = SnackBar(content: Text("Profile updated!"),);
        _scaffolfkey.currentState.showSnackBar(snackBar);
      }

      if(_displayNameValid && _bioValid)
      {
        usersRef.document(widget.currentUserId).updateData({
          "displayName":displayNameController.text,
          "bio":bioController.text,
        });

        SnackBar snackBar = SnackBar(content: Text("Profile updated!"),);
        _scaffolfkey.currentState.showSnackBar(snackBar);
      }

    });
  }
  // end handle submit file
  //***************************************************
  // log out
  logout() async
  {
    await googleSignIn.signOut();
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => Home()
    ));
  }
}
