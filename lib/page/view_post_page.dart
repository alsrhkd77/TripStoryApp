import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/blocs/comment_bloc.dart';
import 'package:trip_story/blocs/view_feed_bloc.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/common/paged_image_view.dart';
import 'package:trip_story/common/view_appbar.dart';
import 'package:trip_story/main.dart';
import 'package:trip_story/models/comment.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/page/network_image_view_page.dart';
import 'package:trip_story/page/search_page.dart';

// ignore: must_be_immutable
class ViewPostPage extends StatelessWidget {
  TextEditingController commentTextController = new TextEditingController();
  TextEditingController commentEditingController = new TextEditingController();
  final ViewFeedBloc feedBloc = new ViewFeedBloc();
  final CommentBloc commentBloc = new CommentBloc();

  final feedId;

  ViewPostPage({Key key, this.feedId, type}) {
    if (type != null) {
      feedBloc.fetchPost(feedId, type);
      commentBloc.fetchAllComment(feedId);
    }
  }

  Future<void> removeFeed(context) async {
    var check = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('삭제'),
            content: Text('정말 삭제하시겠습니까?\n삭제한 데이터는 복구할 수 없습니다.'),
            actions: [
              FlatButton(
                child: Text('취소'),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  },
              ),
              FlatButton(
                child: Text('삭제'),
                onPressed: () {
                  Navigator.pop(context, 'Ok');
                },
              ),
            ],
          );
        });

    if(check == 'Cancel'){
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text('게시물 삭제 중입니다'),
              content: Container(
                padding: EdgeInsets.all(15.0),
                child: LoadingBouncingGrid.square(
                  inverted: true,
                  backgroundColor: Colors.blueAccent,
                  size: 90.0,
                ),
              ),
            ),
          );
        });

    var result = await feedBloc.removeFeed();
    Navigator.pop(context);
    if (result == 'success') {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => MainStatefulWidget()),
          (route) => false);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('삭제 실패'),
              content: Text(result),
              actions: [
                FlatButton(
                  child: Text('확인'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }

  List<Widget> buildTagChip(context, Post data) {
    List<Widget> _tags = new List();
    for (String i in data.tagList) {
      InkWell _chip = new InkWell(
        child: Chip(
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
        ),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SearchPage(type: 'sub', keyWord: i,)));
        },
      );
      _tags.add(_chip);
    }
    return _tags;
  }

  ///앱바(작성자, 방문일자, 메뉴)
  Widget buildAppBar(context, Post data) {
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
                  child: Text('삭제'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text('수정'),
                ),
              ],
              onSelected: (_value) {
                print(_value);
                if (_value == 1) {
                  removeFeed(context);
                }
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
      child: PagedImageView(
        list: data.imageList,
        zoomAble: true,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildLikeIcon(Post data) {
    return Row(
      children: [
        IconButton(
          icon: data.liked
              ? Icon(
                  Icons.favorite,
                  color: Colors.red,
                )
              : Icon(Icons.favorite_border),
          onPressed: feedBloc.tapLike,
        ),
        Text(
          data.likes.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  ///댓글 아이콘
  Widget buildCommentIcon(context, Post data) {
    return Row(
      children: [
        Icon(Icons.mode_comment_outlined),
        //TODO: 코멘트 아이콘 누르면 댓글 작성 위치로
        SizedBox(
          width: 10.0,
        ),
        Text(
          data.comments.toString(),
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

  Widget buildComment() {
    return StreamBuilder(
        stream: commentBloc.commentStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              heightFactor: 2,
              child: LoadingBouncingGrid.square(
                inverted: true,
                backgroundColor: Colors.blueAccent,
                size: 50.0,
              ),
            );
          }
          return snapshot.data.isNotEmpty
              ? ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                        color: Colors.black26,
                      ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return commentTemplate(
                        context, snapshot.data[index], index);
                  })
              : Text(
                  '아직 댓글이 없네요 ㅠ.ㅠ\n첫 댓글을 작성해보세요~!',
                  style: TextStyle(
                      color: Colors.black38, fontStyle: FontStyle.italic),
                );
        });
  }

  Widget commentTemplate(context, Comment data, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: MediaQuery.of(context).size.width / 25,
          backgroundColor: Colors.blueAccent,
          child: CircleAvatar(
            radius: (MediaQuery.of(context).size.width / 25) - 1,
            backgroundImage: NetworkImage(data.profile),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.author,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
              ),
              Card(
                child: Container(
                  width: (MediaQuery.of(context).size.width * 20 / 25) - 40.0,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    data.content,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              Text(
                DateFormat('yy.MM.dd HH:mm').format(data.writeDate),
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black38,
                    fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data.author == Owner().nickName
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text('댓글 삭제'),
                        content: Text('해당 댓글을 삭제하시겠습니까?\n(삭제한 댓글은 복구할 수 없습니다)'),
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
                              commentBloc.removeComment(index);
                              feedBloc.removeComment();
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ));
                })
            : IconButton(
                icon: Icon(
                  Icons.public,
                  color: Colors.white.withOpacity(0.0),
                ),
                onPressed: null),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlankAppbar(),
      body: StreamBuilder(
        stream: feedBloc.feedStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ///앱바(작성자, 방문일자, 메뉴)
                      buildAppBar(context, snapshot.data),

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
                            buildCommentIcon(context, snapshot.data),
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
                          children: buildTagChip(context, snapshot.data).toList(),
                        ),
                      ),
                      Divider(),

                      ///댓글
                      buildComment(),
                      //Divider(),

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
                          maxLength: 50,
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
                            commentBloc.addComment(commentTextController.text);
                            commentTextController.text = '';
                            feedBloc.addComment();
                            FocusManager.instance.primaryFocus
                                .unfocus(); //키보드 닫기
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
