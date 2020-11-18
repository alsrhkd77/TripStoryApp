import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/blocs/view_feed_bloc.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/common/view_appbar.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/page/network_image_view_page.dart';


// ignore: must_be_immutable
class ViewPostPage extends StatelessWidget {
  TextEditingController commentTextController = new TextEditingController();
  TextEditingController commentEditingController = new TextEditingController();
  final ViewFeedBloc bloc = new ViewFeedBloc();

  final feedId;

  ViewPostPage({Key key, this.feedId, type}) {
    if(type != null){
      bloc.fetchPost(feedId, type);
    }
  }

  List<Widget> buildTagChip(Post data) {
    List<Widget> _tags = new List();
    for (String i in data.tagList) {
      Chip _chip = new Chip(
        elevation: 5.0,
        shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
        backgroundColor: Colors.transparent,
        label: Text(
          '# ' + i,
          style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
        ),
      );
      _tags.add(_chip);
    }
    return _tags;
  }

  ///앱바(작성자, 방문일자, 메뉴)
  Widget buildAppBar(Post data) {
    return ViewAppbar(
      name: data.author,
      profileUrl: data.profile,
      useDate: data.useVisit,
      startDate: data.useVisit ? data.startDate : null,
      endDate: data.useVisit ? data.endDate : null,
      trailer: data.author == Owner().nickName
          ? PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text('수정'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text('삭제'),
                ),
              ],
              onSelected: (_value) {
                print(_value);
              },
            )
          : null,
    );
  }

  ///이미지
  Widget buildImageList(Post data, context) {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          PageView.builder(
              itemCount: data.imageList.length,
              itemBuilder: (_, i) {
                return InkWell(
                  child: Image.network(
                    data.imageList[i],
                    fit: BoxFit.contain,
                  ),
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                NetworkImageViewPage(
                                  url: data.imageList[i],
                                )));
                  },
                );
              }),
        ],
      ),
    );
  }

  Widget buildLikeIcon(Post data){
    return Row(
      children: [
        IconButton(
          icon: data.liked
              ? Icon(
            Icons.favorite,
            color: Colors.red,
          )
              : Icon(Icons.favorite_border),
          onPressed: bloc.tapLike,
        ),
        Text(
          data.likes.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  ///댓글 아이콘
  Widget buildCommentIcon(context) {
    return Row(
      children: [
        Icon(Icons.mode_comment_outlined),
        //TODO: 코멘트 아이콘 누르면 댓글 작성 위치로
        SizedBox(
          width: 10.0,
        ),
        Text(
          '123',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  ///본문
  Widget buildContent(Post data) {
    if (data.content.isNotEmpty) {
      return Container(
        padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
        child: Text(data.content),
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlankAppbar(),
      body: StreamBuilder(
        stream: bloc.feedStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ///앱바(작성자, 방문일자, 메뉴)
                      buildAppBar(snapshot.data),

                      ///이미지
                      buildImageList(snapshot.data, context),

                      ///좋아요, 댓글, 작성일자
                      ListTile(
                        title: Row(
                          children: [
                            buildLikeIcon(snapshot.data),
                            SizedBox(
                              width: 25.0,
                            ),
                            buildCommentIcon(context),
                          ],
                        ),
                        trailing: Text(
                          DateFormat('yy. MM. dd HH:mm')
                              .format(snapshot.data.writeDate),
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                              fontSize: 12.0),
                        ),
                      ),

                      Divider(
                        color: Colors.black38,
                      ),

                      /// 본문
                      buildContent(snapshot.data),

                      ///태그
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Wrap(
                          spacing: 10.0,
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children: buildTagChip(snapshot.data).toList(),
                        ),
                      ),
                      Divider(),

                      ///댓글
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: MediaQuery.of(context).size.width / 25,
                              backgroundColor: Colors.blueAccent,
                              child: CircleAvatar(
                                radius:
                                    (MediaQuery.of(context).size.width / 25) -
                                        1,
                                backgroundImage: NetworkImage(Owner().profile),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User_id',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0),
                                  ),
                                  Card(
                                    child: Container(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                                  23 /
                                                  25) -
                                              40.0,
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        '이거슨 댓글 내용',
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('yy.MM.dd HH:mm')
                                        .format(DateTime.now()),
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black38,
                                        fontSize: 12.0),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        onLongPress: () {
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                contentPadding: EdgeInsets.all(16.0),
                                title: Text('댓글 삭제'),
                                content: Text(
                                    '해당 댓글을 삭제하시겠습니까?\n(삭제한 댓글은 복구할 수 없습니다)'),
                                actions: [
                                  FlatButton(
                                    child: Text('취소'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('삭제'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      print('remove comment');
                                    },
                                  )
                                ],
                              ));
                        },
                      ),
                      Divider(),

                      ///댓글 작성
                      ListTile(
                        leading: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 25,
                          backgroundColor: Colors.blueAccent,
                          child: CircleAvatar(
                            radius:
                                (MediaQuery.of(context).size.width / 25) - 1,
                            backgroundImage: NetworkImage(Owner().profile),
                          ),
                        ),
                        title: TextFormField(
                          controller: commentTextController,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: 'Add comment...',
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.send),
                          color: Colors.blueAccent,
                          onPressed: () {
                            print('Add commnet: ${commentTextController.text}');
                          },
                        ),
                      )
                    ],
                  ),
                )
              : Center(
                  child: LoadingBouncingGrid.square(
                    inverted: true,
                    backgroundColor: Colors.blueAccent,
                    size: 150.0,
                  ),
                );
        },
      ),
    );
  }
}
