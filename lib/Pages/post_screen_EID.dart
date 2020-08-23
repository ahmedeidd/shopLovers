import 'package:flutter/material.dart';
import 'package:shop_lovers_app/Pages/home_page_EID.dart';
import 'package:shop_lovers_app/models/post.dart';
import 'package:shop_lovers_app/widgets/circular_progress.dart';
import 'package:shop_lovers_app/widgets/header.dart';
class PostScreen extends StatefulWidget
{
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
{
  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder(
      future: postsRef.document(currentUser.id).collection('userPosts').document(widget.postId).get(),
      builder: (context,snapshot){
        if (!snapshot.hasData || snapshot.data == null)
        {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, titletext: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
