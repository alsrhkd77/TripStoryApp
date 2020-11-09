import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/image_data.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/main.dart';

class UploadPostPageBackup extends StatefulWidget {
  @override
  _UploadPostPageBackupState createState() => _UploadPostPageBackupState();
}

class _UploadPostPageBackupState extends State<UploadPostPageBackup> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController _pageController =
      PageController(viewportFraction: 1, keepPage: true);
  TextEditingController _mainTextController = new TextEditingController();
  int scope = 0; //0=전체 공개, 1=친구공개, 2=비공개
  String _uploadState = '-';
  List<String> tagList = [];
  List<String> imgPath = [];
  List<DateTime> imgDate = [];
  var currentPageValue = 0.0;
  int _index = 0;
  bool _useDate = false;
  DateTime startDate;
  DateTime endDate;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPageValue = _pageController.page;
      });
    });
  }

  void autoDate() {
    if (imgDate.isEmpty) {
      return;
    } else {
      imgDate.sort();
      if (imgDate[0].compareTo(DateTime.now()) < 0) {
        setState(() {
          startDate = imgDate[0];
        });
        for (DateTime d in imgDate.reversed) {
          if (d.compareTo(DateTime.now()) < 0) {
            setState(() {
              endDate = d;
            });
            break;
          }
        }
      }
    }
  }

  Future<void> upload() async {
    var request =
        new http.MultipartRequest("POST", Uri.parse(AddressBook.uploadPost));
    request.fields['author'] = Owner().id;
    request.fields['content'] = _mainTextController.text;
    if (_useDate) {
      request.fields['visitStart'] = DateFormat('yyyy-MM-dd').format(startDate);
      request.fields['visitEnd'] = DateFormat('yyyy-MM-dd').format(endDate);
    } else {
      //request.fields['visitStart'] = '';
      //request.fields['visitEnd'] = '';
      request.fields['visitStart'] =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      request.fields['visitEnd'] =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    for (String i in imgPath) {
      //var image = await ImagePicker().getImage(source: ImageSource.gallery);
      request.files.add(await http.MultipartFile.fromPath('images', i));
    }
    for (String t in tagList) {
      request.files.add(http.MultipartFile.fromString('tags', t));
    }
    //request.fields['postTags'] = formData['memberEmail'];
    /*
    request.files.add(http.MultipartFile.fromString('postTags', 'value1'));
    request.files.add(http.MultipartFile.fromString('postTags', 'value2'));
    request.files.add(http.MultipartFile.fromString('postTags', 'value3'));
     */

    var response = await (await request.send()).stream.bytesToString();
    var resData = jsonDecode(response);
    print(resData);
    _uploadState = resData['result'];
  }

  Widget makeBottomList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imgPath.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == imgPath.length) {
          return new IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.blue,
              ),
              onPressed: addImage);
        } else {
          return InkWell(
            onTap: () {
              setState(() {
                _index = index;
                _pageController.animateToPage(_index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.decelerate);
              });
            },
            onLongPress: () {
              setState(() {
                imgPath.removeAt(index);
                imgDate.removeAt(index);
              });
            },
            child: Image.file(
              File(imgPath[index]),
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width / 7,
              height: MediaQuery.of(context).size.width / 7,
            ),
          );
        }
      },
    );
  }

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
        ),
    );
  }

  Future<void> addImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    DateTime _imgDate = await ImageData.getImageDateTime(image.path);
    setState(() {
      imgPath.add(image.path);
      imgDate.add(_imgDate);
      _pageController.animateToPage(imgPath.length - 1,
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 12.0,
            ),

            ///공개범위 설정
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  child: ListTile(
                    title: Text(
                      '공개 범위',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    trailing: Wrap(
                      children: [
                        Text(
                          scope == 0
                              ? '전체 공개  '
                              : (scope == 1 ? '친구 공개  ' : '비 공개  '),
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black45),
                        ),
                        Icon(scope == 0
                            ? Icons.public
                            : (scope == 1 ? Icons.group : Icons.lock)),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    '공개 범위 설정',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
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
                                    trailing: scope == 0
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                        : SizedBox(),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      scope = 0;
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
                                    trailing: scope == 1
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                        : SizedBox(),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      scope = 1;
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
                                    trailing: scope == 2
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                        : SizedBox(),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      scope = 2;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  },
                )),

            ///방문 날짜
            MergeSemantics(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    '방문 날짜',
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: _useDate,
                    onChanged: (bool value) {
                      setState(() {
                        _useDate = value;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _useDate = !_useDate;
                    });
                  },
                ),
              ),
            ),
            AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              height: !_useDate ? 0.0 : 60.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              child: MergeSemantics(
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
                                    initialDateTime: endDate == null
                                        ? DateTime.now()
                                        : endDate,
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

            /// 이미지 리스트
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              height: MediaQuery.of(context).size.width,
              child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemCount: imgPath.length,
                  itemBuilder: (_, i) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25.0),
                        image: DecorationImage(
                          image: Image.file(
                            File(imgPath[i]),
                          ).image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }),
            ),

            SizedBox(
              height: 15.0,
            ),

            /// 태그
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

            /// 내용 작성란
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
              child: TextField(
                maxLines: 5,
                maxLength: 25,
                maxLengthEnforced: true,
                controller: _mainTextController,
                decoration: InputDecoration(
                    hintText: '여행의 느낌을 알려주세요!', border: OutlineInputBorder()),
              ),
            ),

            /// 작성완료 버튼
            SizedBox(
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
                  if (imgPath.isEmpty) {
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

                  await upload();
                  Navigator.pop(context);
                  if (_uploadState == 'success') {
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
            ),

            SizedBox(
              height: 12.0,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: MediaQuery.of(context).size.width / 7,
          child: makeBottomList(),
        ),
      ),
    );
  }
}
