import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tripstory/modules/UtilityModule.dart';
import 'package:tripstory/modules/ImageModule.dart';
import 'package:http/http.dart' as http;
import 'package:tripstory/pages/home.dart';

//단일 게시물 작성 화면
class MakePost extends StatefulWidget {
  final String SelectedTag;

  MakePost({Key key, @required this.SelectedTag}) : super(key: key);

  @override
  _MakePostState createState() => _MakePostState();
}

class _MakePostState extends State<MakePost> {
  final formKey = new GlobalKey<FormState>();
  Size deviceSize;
  String _tag;
  String _contents;
  List<Widget> imgs = [];
  List<String> imgs_path = [];

  String getTag() {
    if (widget.SelectedTag == "새로 만들기") {
      return "";
    } else {
      return widget.SelectedTag;
    }
  }

  List<Widget> getImgList(){
    List<Widget> result = [];
    result.addAll(imgs);
    result.add(new IconButton(icon: Icon(Icons.add, color: Colors.blue,), onPressed: picImg));
    return result;
  }

  Future<void> picImg() async {
    ImageModule picker = new ImageModule();
    var path = await picker.getImage();
    Image img = new Image.file(File(path), width: 10, height: 10,);

    setState(() {
      imgs.add(img);
      imgs_path.add(path);
    });
  }

  Widget makeAsset(String path){
    return Image.file(File(path), width: 10, height: 10,);
  }

  /*
  Widget buildGrid(){
    return new GridView.builder(
      itemCount: imgs.length,
      padding: const EdgeInsets.all(4.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0
      ),
      itemBuilder: (context, i ){
        return new Container(child: imgs[i]);
      },
    );
  }
   */

  void submit() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      UtilityModule ctr = new UtilityModule();
      ctr.uploadPost(_tag, _contents, imgs_path);

      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => HomePage()),
              (route) => false);
    } else {
      print('failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery
        .of(context)
        .size;
    return new Scaffold(
      appBar: AppBar(
        title: Text("게시물 작성"),
      ),
      resizeToAvoidBottomPadding: false,
      body: new SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: new Container(
          padding: EdgeInsets.all(32),
          child: new Form(
            key: formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Text(
                      "태그: ",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 20, /*fontWeight: FontWeight.bold*/
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(5)),
                    new SizedBox(
                      width: deviceSize.width * 3 / 5,
                      height: 35,
                      child: new TextFormField(
                        initialValue: getTag(),
                        validator: (value) {
                          if (value.isEmpty) {
                            return '태그를 입력하세요!';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          //border: InputBorder.none,
                            hintText: 'Insert tag here',),
                        onSaved: (value) => _tag = value,
                      ),
                    ),
                  ],
                ),
                new Padding(padding: EdgeInsets.all(10)),
                new Text(
                  "사진",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20, /*fontWeight: FontWeight.bold*/
                  ),
                ),
                new Padding(padding: EdgeInsets.all(5)),
                new SizedBox(
                  height: deviceSize.height / 4,
                  child: new Card(
                    child: GridView.count(
                      padding: EdgeInsets.all(10),
                      crossAxisCount: 4,
                      children: getImgList(),
                    )
                  )
                ),
                new Padding(padding: EdgeInsets.all(10)),
                new Text(
                  "게시글",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20, /*fontWeight: FontWeight.bold*/
                  ),
                ),
                new Padding(padding: EdgeInsets.all(5)),
                new SizedBox(
                  height: deviceSize.height / 3,
                  child: new Card(
                    child: new Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        maxLines: 99,
                        decoration: InputDecoration(
                          hintText: "내용을 작성하세요",
                          border: OutlineInputBorder()
                        ),
                        onSaved: (value) => _contents = value,
                      ),
                    ),
                  ),
                ),
                new Padding(padding: EdgeInsets.all(10)),
                new SizedBox(
                  width: deviceSize.width * 4 / 5,
                  height: 50,
                  child: new RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0)),
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: new Text(
                      '게시하기',
                      style: new TextStyle(fontSize: 25.0),
                    ),
                    onPressed: submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
