import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/blocs/friend_bloc.dart';
import 'package:trip_story/page/user_page.dart';

class FriendsPage extends StatelessWidget {
  final FriendBloc _bloc = FriendBloc();
  final String nickName;
  final String type;

  FriendsPage(this.nickName, this.type) {
    _bloc.fetchAllData(this.nickName, this.type);
  }

  ///검색 위젯
  Widget buildSearchBox(context) {
    return StreamBuilder(
        stream: _bloc.textStream,
        builder: (context, snapshot) {
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(15.0),
            child: TextFormField(
              onChanged: _bloc.searchFriend,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Search'),
            ),
          );
        });
  }

  Widget buildFriendList(context) {
    return StreamBuilder(
        stream: _bloc.listStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Center(
                child: Text('검색 결과가 없습니다.'),
              );
            } else {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return friendTile(context, snapshot.data.toList()[index]);
                  });
            }
          } else {
            return Center(
              child: LoadingBouncingGrid.square(
                inverted: true,
                backgroundColor: Colors.blueAccent,
                size: 150.0,
              ),
            );
          }
        });
  }

  Widget friendTile(context, friend) {
    return InkWell(
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(18.0, 8.0, 8.0, 0.0),
        leading: CircleAvatar(
          radius: MediaQuery.of(context).size.width / 15,
          backgroundColor: Colors.blueAccent,
          child: CircleAvatar(
            radius: (MediaQuery.of(context).size.width / 15) - 1,
            backgroundImage: NetworkImage(friend.profile),
          ),
        ),
        title: Text(friend.nickName),
        subtitle: Text(friend.name),
        trailing: _bloc.owner
            ? IconButton(
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5.0),
                          child: InkWell(
                            child: ListTile(
                              title: Text('팔로우 취소'),
                              trailing: Icon(
                                Icons.person_remove_outlined,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () {
                              _bloc.unfollow(friend);
                            },
                          ),
                        );
                      });
                },
              )
            : SizedBox(
                height: 0.0,
              ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => UserPage(
                      nickName: friend.nickName,
                      type: 'other',
                    )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
        title: StreamBuilder(
          stream: _bloc.titleStream,
          builder: (context, snapshot) {
            return Text(
              snapshot.data,
              style: TextStyle(color: Colors.black87),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchAllData(nickName, type),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              buildSearchBox(context),
              buildFriendList(context),
            ],
          ),
        ),
      ),
    );
  }
}
