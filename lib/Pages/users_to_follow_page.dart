import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_lovers_app/Pages/activity_feed_page_EID.dart';
import 'package:shop_lovers_app/Pages/home_page_EID.dart';
import 'package:shop_lovers_app/models/user.dart';
import 'package:shop_lovers_app/widgets/circular_progress.dart';
import 'package:shop_lovers_app/widgets/header.dart';
class UsersToFollow extends StatefulWidget
{
  List <dynamic> users = [];
  List<UserstofollowResult> users_to_follow_result = [];
  bool isLoading = false;
  @override
  _UsersToFollowState createState() => _UsersToFollowState();
}

class _UsersToFollowState extends State<UsersToFollow>
{
  @override
  void initState()
  {
    handleuserstofollow();
    super.initState();
  }
  handleuserstofollow() async
  {
    widget.users.clear();
    widget.users_to_follow_result.clear();
    setState(() {
      widget.isLoading = true;
    });

    QuerySnapshot snapshotusers = await usersRef.orderBy("timestamp",descending: true).limit(50).getDocuments();
    widget.users.addAll(snapshotusers.documents.map((doc) => User.fromDocument(doc)).toList());
    for(var user in widget.users)
    {
      if(user.id != currentUser.id) {
        UserstofollowResult user_to_follow_result = UserstofollowResult(user);
        widget.users_to_follow_result.add(user_to_follow_result);
      }
    }

    setState(() {
      widget.isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: header(context, titletext: "User to follow"),
      body: buildUsersToFollowResults(context),
    );
  }
  // start build Users to follow results
  buildUsersToFollowResults(context)
  {
    if(widget.isLoading)
    {
      return circularProgress();
    }
    else if (widget.users_to_follow_result.isEmpty)
    {
      return Text("");
    }
    else {
      return ListView(
        children: widget.users_to_follow_result,
      );
    }
  }
  // end build Users to follow results
}

//********************************************************************************

class UserstofollowResult extends StatelessWidget
{
  final User user;
  UserstofollowResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.username,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  user.email,
                  style: TextStyle(color: Colors.white)
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}




