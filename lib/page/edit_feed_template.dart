import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_story/common/common_table.dart';

class EditFeedTemplate {
  ///공개범위 설정
  Widget buildScope(bloc) {
    return StreamBuilder(
      stream: bloc.feedStream,
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
                            bloc.setScopePublic();
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
                            bloc.setScopeFriend();
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
                            bloc.setScopePrivate();
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
  Widget buildDateTime(bloc) {
    return StreamBuilder(
      stream: bloc.feedStream,
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
                      bloc.setUseVisit(value);
                    },
                  ),
                  onTap: bloc.switchingUseVisit,
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
                                    bloc.setStartDate(picked);
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
                                    bloc.setEndDate(picked);
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
                  trailing: IconButton(
                    icon: Icon(
                      Icons.update,
                      color: Colors.blue,
                    ),
                    onPressed: bloc.autoDate,
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
  Widget buildTagView({context, bloc}) {
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
          child: makeTagList(bloc),
        ),
      ],
    );
  }

  Widget makeTagList(bloc) {
    return StreamBuilder(
      stream: bloc.feedStream,
      builder: (context, snapshot) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.tagList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == snapshot.data.tagList.length) {
              return new IconButton(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                icon: Icon(
                  Icons.add_link,
                  color: Colors.blue,
                ),
                onPressed: () => _addTag(context: context, bloc: bloc),
              );
            } else {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                child: Chip(
                  backgroundColor: Colors.lightBlueAccent,
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    bloc.removeTag(index);
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

  void _addTag({context, bloc}) {
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
              bloc.addTag(textEditingController.text);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  ///본문 내용
  Widget buildContent(bloc) {
    return StreamBuilder(
      stream: bloc.feedStream,
      builder: (context, snapshot) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
          child: TextField(
            maxLines: 5,
            maxLength: 25,
            maxLengthEnforced: true,
            onChanged: bloc.changeContent,
            decoration: InputDecoration(
                hintText: '여행의 느낌을 알려주세요!', border: OutlineInputBorder()),
          ),
        );
      },
    );
  }

  ///업로드 버튼
  Widget buildSubmit({context, onPressed}) {
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
        onPressed: onPressed,
      ),
    );
  }
}
