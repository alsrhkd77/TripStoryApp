import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:tripstory/modules/UserInfo.dart';
import 'package:tripstory/pages/makePost.dart';


//단일 게시물 작성 전 태그 선택 화면
class TagSelect extends StatefulWidget {
  @override
  _TagSelectState createState() => _TagSelectState();
}

class _TagSelectState extends State<TagSelect> {
  List<String> tags = ["새로 만들기"];
  Size deviceSize;
  int selectedValue;

  _TagSelectState() {
    getTags();
  }

  Widget tagBuilder(BuildContext ctxt, int Index) {
    String tagValue = tags[Index];
    return ListTile(
      title: Text(tags[Index]),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text(tagValue),
              content: new Text("해당 태그로 작성하시겠습니까?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("확인"),
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MakePost(SelectedTag:tagValue)));
                  },
                ),
                CupertinoDialogAction(
                  child: Text("취소"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
      },
    );
  }

  Future<void> getTags() async {
    List<String> _tags = [];
    String _requestUrl = 'https://tripstory.ga/tags';

    Map<String, dynamic> value = {'id': UserInfo().getUserId().toString()};

    http.Response response = await http.post(_requestUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));
    Map<String, dynamic> resData = jsonDecode(response.body);
    //var resData = response.body;
    //var resData = jsonDecode(response.body);
    //tags.add();

    resData.entries.forEach((element) {
      _tags.add(element.value);
    });
    setState(() {
      tags.addAll(_tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text("태그 선택"),),
      body: Material(
          child: ListView.separated(
              itemBuilder: tagBuilder,
              separatorBuilder: (context, index) => Divider(
                color: Colors.black,
                thickness: 1.5,
              ),
              itemCount: tags.length)),
    );
  }
}
//new ListView.builder(itemCount: tags.length, itemBuilder: tagBuilder),
