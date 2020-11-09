import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/common/view_appbar.dart';
import 'package:trip_story/models/post.dart';

class ViewPostPage extends StatefulWidget {
  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  TextEditingController commentTextController = new TextEditingController();
  TextEditingController commentEditingController = new TextEditingController();
  Post _post = new Post();
  int _index = 0;

  List<Widget> buildTagChip() {
    List<Widget> _tags = new List();
    for (String i in _post.tagList) {
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

  @override
  Widget build(BuildContext context) {
    _post.makeSample();
    return Scaffold(
      appBar: BlankAppbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ///앱바(작성자, 방문일자, 메뉴)
            ViewAppbar(
              name: '작성자 이름',
              profileUrl: Owner().profile,
              useDate: true,
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              trailer: PopupMenuButton(
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
              ),
            ),

            ///이미지
            Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  PageView.builder(
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
                      itemCount: _post.imageList.length,
                      itemBuilder: (_, i) {
                        return Image.network(
                          _post.imageList[i],
                          fit: BoxFit.contain,
                        );
                      }),
                ],
              ),
            ),

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
                        setState(() {
                          _post.liked = !_post.liked;
                          //TODO: 좋아요 추가, 제거 서버에 요청
                        });
                      }),
                  Text(
                    '123',
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
                    '123',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: Text(
                DateFormat('yy. MM. dd HH:mm').format(_post.writeDate),
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 12.0),
              ),
            ),

            Divider(
              color: Colors.black38,
            ),

            /// 본문
            _post.content != ''
                ? Container(
                    padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                    child: Text(_post.content),
                  )
                : SizedBox(
                    height: 0,
                  ),

            ///태그
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 10.0,
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                children: buildTagChip().toList(),
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
                      radius: (MediaQuery.of(context).size.width / 25) - 1,
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
                            width: (MediaQuery.of(context).size.width * 23 / 25) - 40.0,
                            padding: EdgeInsets.all(8.0),
                            child: Text('이거슨 댓글 내용', overflow: TextOverflow.clip,),
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
                            Navigator.pop(context);
                            setState(() {
                              print('remove comment');
                              //TODO: 댓글 삭제 요청
                            });
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
                  radius: (MediaQuery.of(context).size.width / 25) - 1,
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
      ),
    );
  }
}
