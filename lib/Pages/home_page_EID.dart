import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shop_lovers_app/Pages/activity_feed_page_EID.dart';
import 'package:shop_lovers_app/Pages/create_acount_EID.dart';
import 'package:shop_lovers_app/Pages/profile_page_EID.dart';
import 'package:shop_lovers_app/Pages/search_page_EID.dart';
import 'package:shop_lovers_app/Pages/time_line_page_EID.dart';
import 'package:shop_lovers_app/Pages/upload_page_EID.dart';
import 'package:shop_lovers_app/models/user.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');

final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget
{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
{
  bool isAuth= false;
  PageController pageController;
  int pageIndex =0;


  @override
  void initState()
  {
    super.initState();

    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((account){
      handleSignIn(account);
    }, onError: (err){
      print("Error signing in: $err");
    });

    googleSignIn.signInSilently(suppressErrors: false).then((account){
      handleSignIn(account);
    }).catchError((err){
      print("Error signing in: $err");
    });

  }
  handleSignIn(GoogleSignInAccount account) async
  {
    if(account != null){
      await createUserInFirestore();
      print('User signed in ! : $account');
      setState(() {
        isAuth = true;
        buildAuthScreen();
      });
    }else{
      setState(() {
        isAuth = false;
        buildUnAuthScreen();
      });
    }
  }
  createUserInFirestore() async
  {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    if(!doc.exists)
    {
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));
      usersRef.document(user.id).setData({
        "id":user.id,
        "username":username,
        "photoUrl":user.photoUrl,
        "email":user.email,
        "displayName":user.displayName,
        "bio":"",
        "timestamp" : timestamp,
      });
      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }
  @override
  void dispose()
  {
    pageController.dispose();
    super.dispose();
  }
  login()
  {
    setState(() {
      googleSignIn.signIn();
      buildAuthScreen();
    });
  }
  Widget buildUnAuthScreen()
  {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor.withOpacity(.2),
              Theme.of(context).primaryColor
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 50,bottom:50),
              child: Text(
                "SHOP LOVERS", style: TextStyle(fontFamily: "Signatra", fontSize: 90,color: Colors.white),
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Scaffold buildAuthScreen()
  {
    return Scaffold(
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size:35.0)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
      body: PageView(
        children: <Widget>[
          Timeline(),
          Search(),
          ActivityFeed(),
          Upload(currentUser: currentUser ),
          Profile(profileId: currentUser.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
  onTap(int pageIndex)
  {
    pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 350),
        curve: Curves.bounceInOut,
    );
  }
  onPageChanged(int pageIndex)
  {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }
  @override
  Widget build(BuildContext context)
  {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen() ;
  }
}
