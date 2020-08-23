import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shop_lovers_app/Pages/home_page_EID.dart';
import 'package:shop_lovers_app/models/user.dart';
import 'package:shop_lovers_app/widgets/circular_progress.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

List <File> postFiles = [];
List<Show_Image> show_Image =[];

class Upload extends StatefulWidget
{
  User currentUser;
  bool goToCreatePost = false;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
{
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File file;
  int i =0;
  bool isUploading = false;
  String postid = Uuid().v4();
  @override
  Widget build(BuildContext context)
  {
    return !widget.goToCreatePost ? buildSplashScreen() : buildUploadForm();
  }
  // start build splash screen
  Container buildSplashScreen()
  {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center ,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: RaisedButton(
                  color: Colors.deepOrange,
                  onPressed: (){
                    setState(() {
                      if(file != null && postFiles.length > 0)
                      {
                        widget.goToCreatePost = true;
                      }else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('You need to upload a photo'),
                        ));
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Next",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0
                        ),
                      ),
                      SizedBox(width: 3.0,),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.add_photo_alternate,
                color: Colors.grey,
                size: 200,
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: RaisedButton(
                  color: Colors.deepOrange,
                  onPressed: () => SelectImage(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Upload Image"
                        ,style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0
                        ),
                      ),
                      SizedBox(width: 5.0,),
                      Icon(Icons.fastfood),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: show_Image
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  SelectImage(parentContext)
  {
    return showDialog(
      context: parentContext,
      builder: (parentContext){
        return SimpleDialog(
          title: Text("Create Post"),
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
      }
    );
  }

  handleTakePhoto() async
  {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960
    );
    if(file != null)
    {
      setState(() {
        this.file = file;
        Show_Image show_image = Show_Image(file);
        show_Image.add(show_image);
        postFiles.add(file);
      });
    }
  }
  handleChooseFromGallery() async
  {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(file !=null)
    {
      setState(() {
        this.file = file;
        Show_Image show_image = Show_Image(file);
        show_Image.add(show_image);
        postFiles.add(file);


      });
    }
  }
  // end build splash screen

  //***********************************************************

  // start build upload form
  Scaffold buildUploadForm()
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
             Icons.arrow_back,
             color: Colors.black
          ),
          onPressed: clearImage,
        ),
        title: Text(
          "New Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              'Post',
              style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold,fontSize: 20.0),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Padding(
                  padding: EdgeInsets.only(top : 10.0),
                  child: GestureDetector(
                    child: Stack(
                      children: <Widget>[
                        builderPostImage(i),
                        IconButton(
                          icon: Icon(Icons.swap_horizontal_circle,color: Colors.white ,size: 40.0,),
                          onPressed: (){
                            if(i == postFiles.length-1){
                              setState(() {
                                i=0;
                              });
                            }else{
                              setState(() {
                                i++;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0),),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                    hintText: "Write a shop name & recipe ...",
                    border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.orange, size: 35.0,),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                    hintText: "Where have this shop been made ?",
                    border: InputBorder.none
                ),
              ),
            ),

          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: getUserLocation,
              icon: Icon(Icons.my_location, color: Colors.white),
              color: Colors.blue,
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
              ),
            ),
          ),
        ],
      ),
    );
  }
  // start functions for app bar
  clearImage()
  {
    setState(() {
      file = null;
      postFiles.clear();
      show_Image.clear();
    });

  }
  handleSubmit() async
  {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    List <String> imageUrl = [];
    int i=0;
    for(var file in postFiles)
    {
      imageUrl.add(await uploadImage(file,i));
      i++;
    }
    createPostInFirebase(mediaUrl: imageUrl, location: locationController.text, description: captionController.text);
    locationController.clear();
    captionController.clear();
    setState(() {
      isUploading = false;
      postid = Uuid().v4();
    });
  }
  compressImage() async
  {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int i=0;
    for(var file in postFiles) {
      Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());

      final compressedImageFile = File('$path/img_$postid'+'_'+'$i.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

      setState(() {
        file = compressedImageFile;
        postFiles.removeAt(i);
        postFiles.insert(i, file);
      });

      i++;
    }
  }
  Future<String> uploadImage(imageFile,i) async
  {
    StorageUploadTask uploadTask = storageRef.child('post_$postid' + '_' + '$i.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }
  createPostInFirebase({List <String> mediaUrl, String location, String description})
  {
    postsRef.document(widget.currentUser.id)
        .collection("userPosts")
        .document(postid)
        .setData({
      "postId": postid,
      "ownerId":widget.currentUser.id,
      "username":widget.currentUser.username,
      "mediaUrl":mediaUrl,
      "description":description,
      "location":location,
      "timestamp":timestamp,
      "likes":{},
    });
    clearImage();
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => Home()
    ));
  }
  // end functions for app bar
  //****************************
  // start functions for body
  builderPostImage(int i)
  {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: FileImage(postFiles[i]),
          )
        ),
      ),
    );
  }
  getUserLocation() async
  {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String name = placemark.name;
    String subLocality = placemark.subLocality;
    String locality = placemark.locality;
    String administrativeArea = placemark.administrativeArea;
    String postalCode = placemark.postalCode;
    String country = placemark.country;
    String address = "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    String formattedaddress = "${locality}, ${country}";
    print(address);
    locationController.text = formattedaddress;
  }
  // end functions for body
  // end build upload form
}

//*************************************************************
// class show_image
class Show_Image extends StatefulWidget
{
  File file;
  bool deletedfile = false;
  Show_Image(this.file);
  @override
  _Show_ImageState createState() => _Show_ImageState();
}

class _Show_ImageState extends State<Show_Image>
{
  @override
  Widget build(BuildContext context)
  {
    File updatedfile = widget.file;
    return GestureDetector(
      child: !widget.deletedfile ? Container(
        height: 200,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Center(
          child: AspectRatio(
            aspectRatio: 16/11,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: GestureDetector(
                child: Stack(
                  children: <Widget>[
                    !widget.deletedfile ? builderupdateImage(widget.file) : Text(''),
                    !widget.deletedfile ? IconButton(
                      icon: Icon(Icons.delete,color: Colors.white ,size: 30.0,),
                      onPressed: (){
                        setState(() {
                          widget.deletedfile = true;
                          postFiles.remove(widget.file);
                          show_Image.remove(widget.file);
                          widget.file = null;
                        });
                      },
                    ) : Text(''),
                  ],
                ),
              ),
            ),
          ),
        ),
      ) : Text(''),
    );
  }
}

// start build update image
builderupdateImage(File file)
{
  if(file != null)
  {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(file),
            )
        ),
      ),
    );
  }
  else{
    return Text('');
  }
}

