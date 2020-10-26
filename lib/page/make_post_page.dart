import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trip_story/utils/image_data.dart';
import 'package:http/http.dart' as http;

class MakePost extends StatefulWidget {
  @override
  _MakePostState createState() => _MakePostState();
}

class _MakePostState extends State<MakePost> {
  PageController _pageController =
      PageController(viewportFraction: 1, keepPage: true);
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

  Future<void> addImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    DateTime _imgDate = await ImageData.getLocalImageDateTime(image.path);
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
      appBar: AppBar(
        title: Text('게시물 작성'),
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ///방문 날짜
            MergeSemantics(
              child: ListTile(
                title: Text(
                  '방문 날짜',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
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
            !_useDate
                ? SizedBox(
                    height: 0.0,
                  )
                : MergeSemantics(
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      title: Wrap(
                        children: [
                          InkWell(
                            child: Text(startDate == null
                                ? DateFormat("yyyy. MM. dd")
                                    .format(DateTime.now())
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
                                ? DateFormat("yyyy. MM. dd")
                                    .format(DateTime.now())
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

            /// 이미지 리스트
            Container(
              margin: EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.width - 20,
              child: imgPath.length > 0
                  ? PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
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
                      })
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
            ),

            /// 태그
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '# 태그',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width / 10,
              padding: EdgeInsets.all(5.0),
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
                onPressed: () {},
              ),
            ),

            SizedBox(
              height: 12.0,
            ),
          ],
        ),
      )),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: MediaQuery.of(context).size.width / 7,
          child: makeBottomList(),
        ),
      ),
    );
  }
}
