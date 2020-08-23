import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_lovers_app/Pages/home_page_EID.dart';
import 'package:shop_lovers_app/Pages/post_screen_EID.dart';
import 'package:shop_lovers_app/Pages/profile_page_EID.dart';
import 'package:shop_lovers_app/widgets/circular_progress.dart';
import 'package:shop_lovers_app/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: header(context, titletext:"Notifications"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context,snapshot){
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
  // start get notification
  getActivityFeed()async
  {
    QuerySnapshot snapshot = await activityFeedRef.document(currentUser.id)
        .collection("feedItems").orderBy("timestamp",descending: true).limit(60).getDocuments();

    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((element) {
      feedItems.add(ActivityFeedItem.fromDocument(element));
    });
    return feedItems;
  }
  // end get notification
}

// *********************************************************************
Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget
{
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({this.username, this.userId, this.type, this.mediaUrl,
    this.postId, this.userProfileImg, this.commentData, this.timestamp});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc)
  {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }
  showPost(context)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        PostScreen(postId: postId, userId: userId,)));
  }
  @override
  Widget build(BuildContext context)
  {
    configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.only(bottom:2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: activityItemText,
                  ),
                ]
              ),
            ),
          ),
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
  // start make configure media preview
  configureMediaPreview(BuildContext context)
  {
    if(type == "like" || type == "comment")
    {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    }
    else
    {
      mediaPreview = Text('');
    }


    if(type == "like")
    {
      activityItemText=" liked your post";
    }
    else if(type == "follow")
    {
      activityItemText=" is following you";
    }
    else if(type == "comment")
    {
      activityItemText=" commented on your post '$commentData'";
    }
  }
  // end make configure media preview
}

// *********************************************************************

showProfile(BuildContext context, {String profileId})
{
  Navigator.push(context, MaterialPageRoute(builder: (context) =>
      Profile(profileId:profileId)));
}
