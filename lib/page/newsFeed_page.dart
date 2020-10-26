import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_story/utils/blank_appbar.dart';
import 'package:trip_story/utils/trip.dart';
import 'package:trip_story/utils/user.dart';

class NewsFeed extends StatefulWidget {
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {

  goUserPage() {
    print('해당 유저페이지로 이동');
  }

  List<Widget> buildTagChip(List<String> tagList) {
    List<Widget> _tags = new List();
    for (String i in tagList) {
      Container _chip = new Container(
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
      );
      _tags.add(_chip);
    }
    return _tags;
  }

  Widget type1(){
    Trip _trip = new Trip();
    int _index = 0;
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 15 / 20,
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: ListTile(
                  leading: InkWell(
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width / 20,
                      backgroundColor: Colors.blueAccent,
                      child: CircleAvatar(
                        radius: (MediaQuery.of(context).size.width / 20) - 2,
                        backgroundImage: NetworkImage(User().profile),
                      ),
                    ),
                    onTap: goUserPage,
                  ),
                  title: InkWell(
                    child: Text('User_id'),
                    onTap: goUserPage,
                  ),
                  subtitle: Text('2015. 03. 03 ~ 2021. 02. 27'),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                PageView.builder(
                    onPageChanged: (int index) =>
                        setState(() => _index = index),
                    itemCount: _trip.imageList.length,
                    itemBuilder: (_, i) {
                      return Image.network(
                        _trip.imageList[i],
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
                    icon: _trip.liked
                        ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                        : Icon(Icons.favorite_border),
                    onPressed: () {
                      setState(() {
                        _trip.liked = !_trip.liked;
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
              DateFormat('yy. MM. dd HH:mm').format(_trip.writeDate),
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 12.0),
            ),
          ),

          /// 본문
          _trip.contents != ''
              ? Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Text(_trip.contents, maxLines: 2, overflow: TextOverflow.ellipsis,),
          )
              : SizedBox(
            height: 0,
          ),

          ///태그
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              children: buildTagChip(_trip.tagList).toList(),
            ),
          ),

          SizedBox(height: 10.0,),
          Divider(
            color: Colors.black38,
          ),

        ],
      ),
    );
  }

  Widget type2(){
    Trip _trip = new Trip();
    int _index = 0;
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 15 / 20,
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: ListTile(
                  leading: InkWell(
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width / 20,
                      backgroundColor: Colors.blueAccent,
                      child: CircleAvatar(
                        radius: (MediaQuery.of(context).size.width / 20) - 2,
                        backgroundImage: NetworkImage(User().profile),
                      ),
                    ),
                    onTap: goUserPage,
                  ),
                  title: InkWell(
                    child: Text('User_id'),
                    onTap: goUserPage,
                  ),
                  subtitle: Text('2015. 03. 03 ~ 2021. 02. 27'),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                PageView.builder(
                    onPageChanged: (int index) =>
                        setState(() => _index = index),
                    itemCount: _trip.imageList.length,
                    itemBuilder: (_, i) {
                      return Image.network(
                        _trip.imageList[i],
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
                    icon: _trip.liked
                        ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                        : Icon(Icons.favorite_border),
                    onPressed: () {
                      setState(() {
                        _trip.liked = !_trip.liked;
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
              DateFormat('yy. MM. dd HH:mm').format(_trip.writeDate),
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 12.0),
            ),
          ),

          /// 본문
          _trip.contents != ''
              ? Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Text(_trip.contents, maxLines: 2, overflow: TextOverflow.ellipsis,),
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
              children: buildTagChip(_trip.tagList).toList(),
            ),
          ),

          Divider(
            color: Colors.black26,
          ),
        ],
      ),
    );
  }

  Widget type3(){
    Trip _trip = new Trip();
    int _index = 0;

    return Container(
      //width: MediaQuery.of(context).size.width * 19 / 20,
      //padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        //margin: EdgeInsets.all(8.0),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 3.0,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 15 / 20,
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ListTile(
                    leading: InkWell(
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 20,
                        backgroundColor: Colors.blueAccent,
                        child: CircleAvatar(
                          radius: (MediaQuery.of(context).size.width / 20) - 2,
                          backgroundImage: NetworkImage(User().profile),
                        ),
                      ),
                      onTap: goUserPage,
                    ),
                    title: InkWell(
                      child: Text('User_id'),
                      onTap: goUserPage,
                    ),
                    subtitle: Text('2015. 03. 03 ~ 2021. 02. 27'),
                  ),
                ),
              ],
            ),

            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Stack(
                children: [
                  PageView.builder(
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
                      itemCount: _trip.imageList.length,
                      itemBuilder: (_, i) {
                        return Image.network(
                          _trip.imageList[i],
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
                      icon: _trip.liked
                          ? Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                          : Icon(Icons.favorite_border),
                      onPressed: () {
                        setState(() {
                          _trip.liked = !_trip.liked;
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
                DateFormat('yy. MM. dd HH:mm').format(_trip.writeDate),
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 12.0),
              ),
            ),

            /// 본문
            _trip.contents != ''
                ? Container(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: Text(_trip.contents, maxLines: 2, overflow: TextOverflow.ellipsis,),
            )
                : SizedBox(
              height: 0,
            ),

            ///태그
            Container(
              height: MediaQuery.of(context).size.height / 15,
              //padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: buildTagChip(_trip.tagList).toList(),
              ),
            ),
            SizedBox(height: 10.0,)
          ],
        ),
      ),
    );
  }

  Widget type4(){
    Trip _trip = new Trip();
    int _index = 0;

    return Container(
      //width: MediaQuery.of(context).size.width * 19 / 20,
      //padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.all(8.0),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 3.0,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 19 / 20,
              height: MediaQuery.of(context).size.width * 19 / 20,
              color: Colors.black,
              child: Stack(
                children: [
                  PageView.builder(
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
                      itemCount: _trip.imageList.length,
                      itemBuilder: (_, i) {
                        return Image.network(
                          _trip.imageList[i],
                          fit: BoxFit.contain,
                        );
                      }),
                ],
              ),
            ),

            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 15 / 20,
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ListTile(
                    leading: InkWell(
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 20,
                        backgroundColor: Colors.blueAccent,
                        child: CircleAvatar(
                          radius: (MediaQuery.of(context).size.width / 20) - 2,
                          backgroundImage: NetworkImage(User().profile),
                        ),
                      ),
                      onTap: goUserPage,
                    ),
                    title: InkWell(
                      child: Text('User_id'),
                      onTap: goUserPage,
                    ),
                    subtitle: Text('2015. 03. 03 ~ 2021. 02. 27'),
                  ),
                ),
              ],
            ),

            /// 본문
            _trip.contents != ''
                ? Container(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: Text(_trip.contents, maxLines: 2, overflow: TextOverflow.ellipsis,),
            )
                : SizedBox(
              height: 0,
            ),

            ///좋아요, 댓글, 작성일자
            ListTile(
              title: Row(
                children: [
                  IconButton(
                      icon: _trip.liked
                          ? Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                          : Icon(Icons.favorite_border),
                      onPressed: () {
                        setState(() {
                          _trip.liked = !_trip.liked;
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
                DateFormat('yy. MM. dd HH:mm').format(_trip.writeDate),
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 12.0),
              ),
            ),

            ///태그
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                children: buildTagChip(_trip.tagList).toList(),
              ),
            ),
            SizedBox(height: 5.0,)
          ],
        ),
      ),
    );
  }

  Widget type5(){
    Trip _trip = new Trip();
    int _index = 0;

    return Container(
      //width: MediaQuery.of(context).size.width * 19 / 20,
      //padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.all(8.0),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 3.0,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 15 / 20,
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ListTile(
                    leading: InkWell(
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 20,
                        backgroundColor: Colors.blueAccent,
                        child: CircleAvatar(
                          radius: (MediaQuery.of(context).size.width / 20) - 2,
                          backgroundImage: NetworkImage(User().profile),
                        ),
                      ),
                      onTap: goUserPage,
                    ),
                    title: InkWell(
                      child: Text('User_id'),
                      onTap: goUserPage,
                    ),
                    subtitle: Text('2015. 03. 03 ~ 2021. 02. 27'),
                  ),
                ),
              ],
            ),

            Container(
              width: MediaQuery.of(context).size.width * 19 / 20,
              height: MediaQuery.of(context).size.width * 19 / 20,
              color: Colors.black,
              child: Stack(
                children: [
                  PageView.builder(
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
                      itemCount: _trip.imageList.length,
                      itemBuilder: (_, i) {
                        return Image.network(
                          _trip.imageList[i],
                          fit: BoxFit.contain,
                        );
                      }),
                  Positioned(
                    bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 19 / 20,
                        color: Color.fromRGBO(0, 0, 0, 150),
                        child:
                        ///좋아요, 댓글, 작성일자
                        ListTile(
                          title: Row(
                            children: [
                              IconButton(
                                  icon: _trip.liked
                                      ? Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  )
                                      : Icon(Icons.favorite_border, color: Colors.white38,),
                                  onPressed: () {
                                    setState(() {
                                      _trip.liked = !_trip.liked;
                                      //TODO: 좋아요 추가, 제거 서버에 요청
                                    });
                                  }),
                              Text(
                                '123',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white38,),
                              ),
                              SizedBox(
                                width: 25.0,
                              ),
                              Icon(Icons.mode_comment_outlined, color: Colors.white38,),
                              //TODO: 코멘트 아이콘 누르면 댓글 작성 위치로
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                '123',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white38,),
                              ),
                            ],
                          ),
                          trailing: Text(
                            DateFormat('yy. MM. dd HH:mm').format(_trip.writeDate),
                            style: TextStyle(
                                fontStyle: FontStyle.italic, color: Colors.white38, fontSize: 12.0),
                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ),

            /// 본문
            _trip.contents != ''
                ? Container(
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Text(_trip.contents, maxLines: 2, overflow: TextOverflow.ellipsis,),
            )
                : SizedBox(
              height: 0,
            ),

            ///태그
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                direction: Axis.horizontal,
                children: buildTagChip(_trip.tagList).toList(),
              ),
            ),
            SizedBox(height: 5.0,)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlankAppbar(),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              type2(),
              type2(),
              type2(),
              type2(),
            ],
          ),
        )
      ),
    );
  }
}
