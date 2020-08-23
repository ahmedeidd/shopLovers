import 'package:flutter/material.dart';
import 'package:shop_lovers_app/Pages/post_screen_EID.dart';
import 'package:shop_lovers_app/models/post.dart';

import 'custom_image.dart';
class PostTile extends StatelessWidget
{
  final Post post;
  PostTile(this.post);
  showPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        PostScreen(postId: post.postId, userId: post.ownerId,)));
  }
  @override
  Widget build(BuildContext context)
  {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImageEID(post.mediaUrl[0]),
    );
  }
}
