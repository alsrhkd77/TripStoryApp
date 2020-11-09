import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/main.dart';

class UploadTemplate extends StatefulWidget {
  @override
  UploadTemplateState createState() => UploadTemplateState();
}

class UploadTemplateState extends State<UploadTemplate> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController mainTextController = new TextEditingController();
  String scope; //public=전체 공개, friend=친구공개, private=비공개
  String uploadState = '-';
  List<String> tagList = [];
  bool useDate = false;
  DateTime startDate;
  DateTime endDate;

  @override
  void initState() {
    super.initState();
  }

  void autoDate() {}

  Future<void> addImage() async {}

  Future<void> upload() async {}

  Widget makeTagList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tagList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == tagList.length) {
          return new IconButton(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              icon: Icon(
                Icons.add,
                color: Colors.blue,
              ),
              onPressed: addTag);
        } else {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Chip(
              backgroundColor: Colors.lightBlueAccent,
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  tagList.removeAt(index);
                });
              },
              label: Text('# ' + tagList[index]),
            ),
          );
        }
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
                Navigator.pop(context);
                setState(() {
                  tagList.add(textEditingController.text);
                });
              },
            )
          ],
        ));
  }

  ///공개범위 설정
  Widget buildScope() {
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
                  scope == 'public'
                      ? '전체 공개  '
                      : (scope == 'friend' ? '친구 공개  ' : '비 공개  '),
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.black45),
                ),
                Icon(scope == 'public'
                    ? Icons.public
                    : (scope == 'friend' ? Icons.group : Icons.lock)),
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
                            trailing: scope == 'public'
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : SizedBox(),
                          ),
                          onTap: () {
                            setState(() {
                              scope = 'public';
                            });
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
                            trailing: scope == 'friend'
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : SizedBox(),
                          ),
                          onTap: () {
                            setState(() {
                              scope = 'friend';
                            });
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
                            trailing: scope == 'private'
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : SizedBox(),
                          ),
                          onTap: () {
                            setState(() {
                              scope = 'private';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                });
          },
        ));
  }

  ///방문 날짜
  Widget buildDateTime() {
    return Wrap(
      direction: Axis.vertical,
      children: [
        MergeSemantics(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              title: Text(
                '방문 날짜',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              trailing: Switch(
                value: useDate,
                onChanged: (bool value) {
                  setState(() {
                    useDate = value;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  useDate = !useDate;
                });
              },
            ),
          ),
        ),
        AnimatedContainer(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          width: MediaQuery.of(context).size.width,
          height: !useDate ? 0.0 : 60.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: MergeSemantics(
            child: ListTile(
              //contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Wrap(
                children: [
                  InkWell(
                    child: Text(startDate == null
                        ? DateFormat("yyyy. MM. dd").format(DateTime.now())
                        : DateFormat("yyyy. MM. dd").format(startDate)),
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
                                initialDateTime: startDate == null
                                    ? DateTime.now()
                                    : startDate,
                                onDateTimeChanged: (DateTime picked) {
                                  setState(() {
                                    startDate = picked;
                                  });
                                },
                                maximumDate: DateTime.now(),
                                minimumYear: 1950,
                                mode: CupertinoDatePickerMode.date,
                              ),
                            );
                          });
                    },
                  ),
                  Text('  ~  '),
                  InkWell(
                    child: Text(endDate == null
                        ? DateFormat("yyyy. MM. dd").format(DateTime.now())
                        : DateFormat("yyyy. MM. dd").format(endDate)),
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
                                initialDateTime:
                                    endDate == null ? DateTime.now() : endDate,
                                onDateTimeChanged: (DateTime picked) {
                                  setState(() {
                                    endDate = picked;
                                  });
                                },
                                maximumDate: DateTime.now(),
                                minimumYear: 1950,
                                mode: CupertinoDatePickerMode.date,
                              ),
                            );
                          });
                    },
                  )
                ],
              ),
              trailing: InkWell(
                child: Text(
                  'Auto',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: autoDate,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///태그
  Widget buildTag() {
    return Wrap(
      direction: Axis.vertical,
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
        SizedBox(
          height: 12.0,
        ),
      ],
    );
  }

  ///본문 내용
  Widget buildContents() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: TextField(
        maxLines: 5,
        maxLength: 25,
        maxLengthEnforced: true,
        controller: mainTextController,
        decoration: InputDecoration(
            hintText: '여행의 느낌을 알려주세요!', border: OutlineInputBorder()),
      ),
    );
  }

  ///작성완료 버튼
  Widget buildSubmit(bool empty) {
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
          if (empty) {
            scaffoldKey.currentState.showSnackBar(SnackBar(
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

          await upload();
          Navigator.pop(context);
          if (uploadState == 'success') {
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => MainStatefulWidget()),
                (route) => false);
          } else {
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('업로드에 실패하였습니다.\n다시 시도해주세요.'),
            ));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('게시물 작성'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 12.0,
            ),

            ///공개범위 설정
            buildScope(),

            ///방문 날짜
            buildDateTime(),

            ///태그
            buildTag(),

            ///내용 작성란
            buildContents(),

            ///작성완료 버튼
            buildSubmit(true),

            SizedBox(
              height: 12.0,
            ),
          ],
        ),
      ),
    );
  }
}
