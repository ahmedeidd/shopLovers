import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_lovers_app/Pages/activity_feed_page_EID.dart';
import 'package:shop_lovers_app/models/user.dart';
import 'package:shop_lovers_app/widgets/circular_progress.dart';

final usersRef = Firestore.instance.collection("users");
class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
{
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
  AppBar buildSearchField()
  {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "search for a user",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon : Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }
  clearSearch ()
  {
    searchController.clear();
  }
  handleSearch(String query)
  {
    Future<QuerySnapshot> users = usersRef.where("username",isGreaterThanOrEqualTo: query).getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  Container buildNoContent()
  {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.group,
              color: Colors.white,
              size: 200,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            )
          ],
        ),
      ),
    );
  }
  buildSearchResults()
  {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }
}


class UserResult extends StatelessWidget
{
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context)
  {
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
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}

