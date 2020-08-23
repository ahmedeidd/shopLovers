import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_lovers_app/Pages/users_to_follow_page.dart';
import 'package:shop_lovers_app/models/post.dart';
import 'package:shop_lovers_app/widgets/circular_progress.dart';
import 'package:shop_lovers_app/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'home_page_EID.dart';


class Timeline extends StatefulWidget
{
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
{
  List<Post> usersPosts = [];
  List<dynamic> usersId = [];
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState()
  {
    getUsersPosts();
    super.initState();
  }
  getUsersPosts() async
  {
    usersPosts.clear();
    usersId.clear();
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshotusersId = await followingRef.document(currentUser.id).collection("userFollowing").getDocuments();
    for (int i = 0; i < snapshotusersId.documents.length; i++)
    {
      var a = snapshotusersId.documents[i];
      usersId.add(a.documentID);
    }
    usersId.add(currentUser.id);
    for(var userId in usersId)
    {
      QuerySnapshot snapshotPosts = await postsRef.document(userId.toString())
          .collection("userPosts").orderBy("timestamp",descending: true).getDocuments();

      usersPosts.addAll(snapshotPosts.documents.map((doc) => Post.fromDocument(doc)).toList());
    }
    usersPosts.sort((a,b){
      Timestamp as = a.timestamp;
      Timestamp bs = b.timestamp;
      var adate = timeago.format(as.toDate());
      var bdate = timeago.format(bs.toDate());
      return bdate.compareTo(adate);
    });
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: header(context, isApptitle: true),
      body: RefreshIndicator(
        onRefresh: () =>
            getUsersPosts(),
        child: ListView(
          children: <Widget>[
            buildProfilePosts(context),
          ],
        ),
      ),
    );
  }
  // start build profile posts
  buildProfilePosts(context)
  {
    if (isLoading) {
      return circularProgress();
    }
    else if(usersPosts.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No Posts, try to follow users to show posts"
                , style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: RaisedButton.icon(
                icon: Icon(Icons.group_add) ,
                color: Theme.of(context).primaryColor,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UsersToFollow())),
                label: Text("Users to follow",style: TextStyle(color: Colors.white, fontSize: 16.0)),
              ),
            ),
          ],
        ),
      );
    }
    else{
      return Column(
        children: usersPosts,
      );
    }
  }
  // end build profile posts
}
