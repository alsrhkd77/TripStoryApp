import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/blocs/edit_post_bloc.dart';
import 'package:trip_story/common/image_data.dart';
import 'package:trip_story/main.dart';
import 'package:trip_story/page/edit_feed_template.dart';

class EditPostPage extends StatefulWidget {
  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  PageController _pageController =
      PageController(viewportFraction: 1, keepPage: true);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _pageIndex = 0;
  final EditPostBloc _bloc = new EditPostBloc();
  final EditFeedTemplate _template = new EditFeedTemplate();

  /*
  ///공개범위 설정
  Widget buildScope() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            child: ListTile(
              title: Text(
                '공개 범위',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              trailing: Wrap(
                children: [
                  Text(
                    CommonTable.scope[snapshot.data.scope][0],
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black45),
                  ),
                  Icon(CommonTable.scope[snapshot.data.scope][1]),
                ],
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0)),
                ),
                context: context,
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 3,
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            '공개 범위 설정',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        InkWell(
                          child: ListTile(
                            title: Wrap(
                              spacing: 8.0,
                              children: [
                                Icon(Icons.public),
                                Text('전체 공개'),
                              ],
                            ),
                            trailing: snapshot.data.scope == 'public'
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : SizedBox(),
                          ),
                          onTap: () {
                            _bloc.setScopePublic();
                            Navigator.pop(context);
                          },
                        ),
                        InkWell(
                          child: ListTile(
                            title: Wrap(
                              spacing: 8.0,
                              children: [
                                Icon(Icons.group),
                                Text('친구 공개'),
                              ],
                            ),
                            trailing: snapshot.data.scope == 'friend'
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : SizedBox(),
                          ),
                          onTap: () {
                            _bloc.setScopeFriend();
                            Navigator.pop(context);
                          },
                        ),
                        InkWell(
                          child: ListTile(
                            title: Wrap(
                              spacing: 8.0,
                              children: [
                                Icon(Icons.lock),
                                Text('비공개'),
                              ],
                            ),
                            trailing: snapshot.data.scope == 'private'
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : SizedBox(),
                          ),
                          onTap: () {
                            _bloc.setScopePrivate();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  ///방문 날짜 설정
  Widget buildDateTime() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return Column(
          children: [
            MergeSemantics(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    '방문 날짜',
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: snapshot.data.useVisit,
                    onChanged: (bool value) {
                      _bloc.setUseVisit(value);
                    },
                  ),
                  onTap: _bloc.switchingUseVisit,
                ),
              ),
            ),
            AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              width: MediaQuery.of(context).size.width,
              height: !snapshot.data.useVisit ? 0.0 : 60.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              child: MergeSemantics(
                child: ListTile(
                  //contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  title: Wrap(
                    children: [
                      InkWell(
                        child: Text(DateFormat('yyyy. MM. dd')
                            .format(snapshot.data.startDate)),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: MediaQuery.of(context)
                                        .copyWith()
                                        .size
                                        .height /
                                    3,
                                child: CupertinoDatePicker(
                                  initialDateTime: snapshot.data.startDate,
                                  onDateTimeChanged: (DateTime picked) {
                                    _bloc.setStartDate(picked);
                                  },
                                  maximumDate: snapshot.data.startDate
                                              .compareTo(
                                                  snapshot.data.endDate) >
                                          0
                                      ? DateTime.now()
                                      : snapshot.data.endDate,
                                  minimumYear: 1950,
                                  mode: CupertinoDatePickerMode.date,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Text('  ~  '),
                      InkWell(
                        child: Text(DateFormat('yyyy. MM. dd')
                            .format(snapshot.data.endDate)),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: MediaQuery.of(context)
                                        .copyWith()
                                        .size
                                        .height /
                                    3,
                                child: CupertinoDatePicker(
                                  initialDateTime: snapshot.data.startDate,
                                  onDateTimeChanged: (DateTime picked) {
                                    _bloc.setEndDate(picked);
                                  },
                                  maximumDate: DateTime.now(),
                                  minimumDate: snapshot.data.startDate,
                                  mode: CupertinoDatePickerMode.date,
                                ),
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                  trailing: InkWell(
                    child: Text(
                      'Auto',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: _bloc.autoDate,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ///태그 리스트
  Widget buildTagView() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Text(
            '# 태그',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.width / 10,
          child: makeTagList(),
        ),
      ],
    );
  }

  Widget makeTagList() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.tagList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == snapshot.data.tagList.length) {
              return new IconButton(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                icon: Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                onPressed: addTag,
              );
            } else {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                child: Chip(
                  backgroundColor: Colors.lightBlueAccent,
                  deleteIcon: Icon(Icons.close),
                  onDeleted: (){
                    _bloc.removeTag(index);
                  },
                  label: Text('# ' + snapshot.data.tagList[index]),
                ),
              );
            }
          },
        );
      },
    );
  }

  void addTag() {
    TextEditingController textEditingController = new TextEditingController();
    showDialog(
      context: context,
      child: AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textEditingController,
                autofocus: true,
                maxLength: 15,
                decoration:
                InputDecoration(labelText: '새 태그', hintText: '새 태그'),
              ),
            )
          ],
        ),
        actions: [
          FlatButton(
            child: Text('취소'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('추가'),
            onPressed: () {
              _bloc.addTag(textEditingController.text);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  ///본문 내용
  Widget buildContent(){
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot){
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
          child: TextField(
            maxLines: 5,
            maxLength: 25,
            maxLengthEnforced: true,
            onChanged: _bloc.changeContent,
            decoration: InputDecoration(
                hintText: '여행의 느낌을 알려주세요!', border: OutlineInputBorder()),
          ),
        );
      },
    );
  }

  ///업로드 버튼
  Widget buildSubmit(){
    return SizedBox(
      width: MediaQuery.of(context).size.width * 4 / 5,
      child: RaisedButton(
        color: Colors.lightBlueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Text(
          '작성 완료',
        ),
        onPressed: () async {
          if (_bloc.uploadAble()) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('태그와 이미지가 1개 이상 필요합니다.'),
            ));
            return;
          }
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: Text('업로드 중입니다'),
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

          await _bloc.submit();
          Navigator.pop(context);
          if (_bloc.getUploadState() == 'success') {
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        MainStatefulWidget()),
                    (route) => false);
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('업로드에 실패하였습니다.\n다시 시도해주세요.'),
            ));
          }
        },
      ),
    );
  }
   */

  ///이미지 리스트
  Widget buildImageView() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              height: MediaQuery.of(context).size.width,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int index) =>
                    setState(() => _pageIndex = index),
                itemCount: snapshot.data.imageList.length,
                itemBuilder: (_, i) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25.0),
                      image: DecorationImage(
                        image: Image.file(
                          File(snapshot.data.imageList[i]),
                        ).image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_bloc.uploadAble()) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('이미지가 1개 이상 필요합니다.'),
      ));
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text('업로드 중입니다'),
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

    await _bloc.submit();
    Navigator.pop(context);
    if (_bloc.uploadState == 'success') {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => MainStatefulWidget()),
          (route) => false);
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('업로드에 실패하였습니다.\n다시 시도해주세요.'),
      ));
    }
  }

  Widget buildBottomList() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.imageList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == snapshot.data.imageList.length) {
              return new IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                onPressed: () => addImage(snapshot),
              );
            } else {
              return InkWell(
                onTap: () {
                  setState(() {
                    _pageIndex = index;
                    _pageController.animateToPage(_pageIndex,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.decelerate);
                  });
                },
                onLongPress: () => _bloc.removeImage(index),
                child: Image.file(
                  File(snapshot.data.imageList[index]),
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width / 7,
                  height: MediaQuery.of(context).size.width / 7,
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> addImage(snapshot) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    DateTime _imgDate = await ImageData.getImageDateTime(image.path);
    _bloc.addImage(image.path, _imgDate);
    setState(() {
      _pageController.animateToPage(snapshot.data.imageList.length - 1,
          duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('게시물 작성'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _template.buildScope(_bloc),
            //buildScope(),
            _template.buildDateTime(_bloc),
            //buildDateTime(),
            buildImageView(),
            SizedBox(height: 15.0),
            _template.buildTagView(
              context: context,
              bloc: _bloc,
            ),
            //buildTagView(),
            SizedBox(height: 12.0),
            _template.buildContent(_bloc),
            //buildContent(),
            _template.buildSubmit(
              context: context,
              onPressed: _submit,
            ),
            //buildSubmit(),
            SizedBox(height: 12.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: MediaQuery.of(context).size.width / 7,
          child: buildBottomList(),
        ),
      ),
    );
  }
}
