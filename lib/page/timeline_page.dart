import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/blocs/timeline_bloc.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/paged_image_view.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/page/network_image_view_page.dart';
import 'package:trip_story/page/search_page.dart';
import 'package:trip_story/page/user_page.dart';
import 'package:trip_story/page/view_post_page.dart';
import 'package:trip_story/page/view_trip_page.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage>
    with AutomaticKeepAliveClientMixin {
  final TimelineBloc _bloc = new TimelineBloc();
  final ScrollController _scrollController = new ScrollController();

  @override
  bool wantKeepAlive = true;

  @override
  void initState() {
    super.initState();
    _bloc.fetchStart();
    _scrollController.addListener(_scrollListener);
  }

  void goUserPage(context, String nickName) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UserPage(
                  nickName: nickName,
                  type: 'other',
                )));
  }

  _scrollListener() {
    if (_scrollController.position.extentAfter < 500) {
      _bloc.fetchNext();
    }
  }

  List<Widget> buildTagChip(List tagList) {
    List<Widget> _tags = new List();
    for (String i in tagList) {
      InkWell _chip = new InkWell(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
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
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SearchPage(
                        type: 'sub',
                        keyWord: i,
                      )));
        },
      );
      _tags.add(_chip);
    }
    return _tags;
  }


  Widget postCard(context, Post _post, int index, String type) {
    String visit = '';
    if (_post.useVisit) {
      if (DateFormat('yyyy-MM-dd').format(_post.startDate) ==
          DateFormat('yyyy-MM-dd').format(_post.endDate)) {
        visit = DateFormat('yyyy. MM. dd').format(_post.startDate);
      } else {
        visit = DateFormat('yyyy. MM. dd').format(_post.startDate) +
            " ~ " +
            DateFormat('yyyy. MM. dd').format(_post.endDate);
      }
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: ListTile(
                  leading: InkWell(
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width / 20,
                      backgroundColor: Colors.blueAccent,
                      child: CircleAvatar(
                        radius: (MediaQuery.of(context).size.width / 20) - 2,
                        backgroundImage: NetworkImage(_post.profile),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  NetworkImageViewPage(
                                    url: _post.profile,
                                  )));
                    },
                  ),
                  title: InkWell(
                    child: Text(_post.author),
                    onTap: () => goUserPage(context, _post.author),
                  ),
                  subtitle: Text(visit),
                  trailing: type == 'TRAVEL'
                      ? Icon(Icons.dynamic_feed)
                      : Icon(Icons.airport_shuttle),
                ),
              ),
            ],
          ),
          Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: PagedImageView(
                list: _post.imageList,
                fit: BoxFit.cover,
                zoomAble: false,
              )),

          ///좋아요, 댓글, 작성일자
          ListTile(
            title: Row(
              children: [
                IconButton(
                    icon: _post.liked
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : Icon(Icons.favorite_border),
                    onPressed: () {
                      _bloc.tapLike(index);
                    }),
                Text(
                  _post.likes.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 25.0,
                ),
                Icon(Icons.mode_comment_outlined),
                //TODO: 코멘트 아이콘 누르면 댓글 작성 위치로
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  _post.comments.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Text(
              DateFormat('yy. MM. dd HH:mm').format(_post.writeDate),
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                  fontSize: 12.0),
            ),
          ),

          /// 본문
          _post.content != ''
              ? Container(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Text(
                    _post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : SizedBox(
                  height: 0,
                ),

          ///태그
          Container(
            height: MediaQuery.of(context).size.height / 15,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: buildTagChip(_post.tagList).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: BlankAppbar(),
      body: RefreshIndicator(
        onRefresh: _bloc.fetchStart,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: StreamBuilder(
            stream: _bloc.loadingStream,
            builder: (context, status) {
              return Column(
                children: [
                  StreamBuilder(
                      stream: _bloc.timelineStream,
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.black26,
                                ),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    child: postCard(
                                        context,
                                        snapshot.data[index]['item'],
                                        index,
                                        snapshot.data[index]['type']),
                                    onTap: () {
                                      if (snapshot.data[index]['type'] ==
                                          'NORMAL') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ViewPostPage(
                                                          feedId: snapshot
                                                              .data[index]
                                                                  ['item']
                                                              .id,
                                                          type: 'post',
                                                        )));
                                      }
                                      if (snapshot.data[index]['type'] ==
                                          'TRAVEL') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ViewTripPage(
                                                          feedId: snapshot
                                                              .data[index]
                                                                  ['item']
                                                              .id,
                                                          type: 'trip',
                                                        )));
                                      }
                                    },
                                  );
                                },
                              )
                            : Center(
                                heightFactor: 4,
                                child: LoadingBouncingGrid.square(
                                  inverted: true,
                                  backgroundColor: Colors.blueAccent,
                                  size: 150.0,
                                ),
                              );
                      }),
                  status.data != '-'
                      ? Center(
                          heightFactor: 2,
                          child: LoadingBouncingGrid.square(
                            inverted: true,
                            backgroundColor: Colors.blueAccent,
                            size: 80.0,
                          ),
                        )
                      : SizedBox(
                          height: 0.0,
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
