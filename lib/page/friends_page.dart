import 'package:flutter/material.dart';
import 'package:trip_story/utils/blank_appbar.dart';
import 'package:trip_story/utils/user.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  TextEditingController _searchController = new TextEditingController();

  Widget sampleTile() {
    //TODO: 본인 팔로잉에서만 수정버튼 보이기
    return InkWell(
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(18.0, 8.0, 8.0, 0.0),
        leading: CircleAvatar(
          radius: MediaQuery.of(context).size.width / 15,
          backgroundColor: Colors.blueAccent,
          child: CircleAvatar(
            radius: (MediaQuery.of(context).size.width / 15) - 1,
            backgroundImage: NetworkImage(User().profile),
          ),
        ),
        title: Text('user_id'),
        subtitle: Text('nickname'),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
          ),
          onPressed: () {
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0)),
                ),
                context: context,
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                    child: InkWell(
                      child: ListTile(
                        title: Text('팔로우 취소'),
                        trailing: Icon(
                          Icons.person_remove_outlined,
                          color: Colors.red,
                        ),
                      ),
                      onTap: (){
                        print('unfollow');
                      },
                    ),
                  );
                });
          },
        ),
      ),
      onTap: () {
        print('view user page');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text('199 팔로워', style: TextStyle(color: Colors.black87),)
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(15.0),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Search'),
              ),
            ),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
            sampleTile(),
          ],
        ),
      ),
    );
  }
}
