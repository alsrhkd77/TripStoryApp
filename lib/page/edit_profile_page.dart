import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/owner.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/main.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = new GlobalKey<FormState>();
  String nickNameUploadingState = '-';
  String editNickName = '-';
  String _memberNickName;

  void changeProfile(context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Wrap(
            direction: Axis.vertical,
            spacing: 15.0,
            children: [
              InkWell(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  height: 25.0,
                  child: Text('기본 이미지로 설정하기', textAlign: TextAlign.center,),
                ),
                onTap: sendDefaultProfile,
              ),
              InkWell(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  height: 25.0,
                  child: Text('갤러리에서 사진 선택하기', textAlign: TextAlign.center,),
                ),
                onTap: sendChangeProfile,
              ),
            ],
          ),
        );
      },
    );
  }
  
  void sendChangeProfile(){
    Navigator.pop(context);
  }

  void sendDefaultProfile(){
    Navigator.pop(context);
  }

  Future<void> sendChangeNickName() async {
    http.Response nickNameCheckResponse = await http.post(AddressBook.nickNameCheck,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'memberNickName': _memberNickName}));
    var nickNameCheckResult = jsonDecode(nickNameCheckResponse.body);

    if (nickNameCheckResult['result'] == "success") {
      http.Response nickNameChangeResponse = await http.put(AddressBook.changeNickName,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'memberId' : Owner().id, 'memberNickName': _memberNickName}));

      var nickNameChangeResult = jsonDecode(nickNameChangeResponse.body);

      Navigator.pop(context);
      if (nickNameChangeResult['result'] == "success") {
        Owner().nickName = _memberNickName;
        nickNameUploadingState = 'success';
      } else {
        _showDialog('닉네임 변경', nickNameChangeResult['errors']);
      }
    } else if(nickNameCheckResult['result'] == "duplicate"){
      Navigator.pop(context);
      _showDialog('닉네임 변경', '중복된 닉네임 입니다.');
    }else {
      Navigator.pop(context);
      _showDialog('닉네임 변경', nickNameCheckResult['errors']);
    }
  }

  Widget buildEditButton(){
    if(editNickName == 'editing'){
      return Container(
        decoration: new BoxDecoration(
          color: Colors.greenAccent[400],
          borderRadius: new BorderRadius.circular(10.0),
        ),
        child: IconButton(
          icon: Icon(Icons.check, color: Colors.white,),
          onPressed: () async {
            final form = formKey.currentState;
            if(form.validate()){
              form.save();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context){
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                        title: Text('변경 중입니다'),
                        content: Container(
                          padding: EdgeInsets.all(15.0),
                          child: LoadingBouncingGrid.square(
                            backgroundColor: Colors.blueAccent,
                            size: 90.0,
                          ),
                        ),
                      ),
                    );
                  }
              );
              await sendChangeNickName();
              if(nickNameUploadingState == 'success'){
                FocusManager.instance.primaryFocus.unfocus();   //키보드 닫기
                setState(() {
                  editNickName = '-';
                });
              }
            }
          },
        ),
      );
    }
    else{
      return IconButton(
        icon: Icon(Icons.create),
        onPressed: (){
          setState(() {
            editNickName = 'editing';
          });
        },
      );
    }
  }

  void _showDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 프로필'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => MainStatefulWidget()),
                    (route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(25.0),
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 4,
                  backgroundColor: Colors.blueAccent,
                  child: CircleAvatar(
                    radius: (MediaQuery.of(context).size.width / 4) - 2.5,
                    backgroundImage: NetworkImage(Owner().profile),
                  ),
                ),
              )
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 4 / 5,
              child: OutlineButton(
                borderSide: BorderSide(color: Colors.blueAccent),
                child: Text('프로필 사진 변경'),
                onPressed: () => changeProfile(context),
              ),
            ),
            SizedBox(height: 20.0,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(Icons.face),
                title: Text(Owner().name),
                subtitle: Text('이름'),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(Icons.email),
                title: Text(Owner().email),
                subtitle: Text('email'),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                  leading: Icon(Icons.account_circle),
                  title: editNickName == 'editing' ? Form(
                    key: formKey,
                    child: TextFormField(
                      maxLines: 1,
                      initialValue: Owner().nickName,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Nick name can\'t be empty!';
                        } else if (!RegExp(r"^[ㄱ-ㅎ|ㅏ-ㅣ|가-힣A-Za-z0-9+]+$")
                            .hasMatch(value)) {
                          return 'Use only Alphabet and Numbers.';
                        } else if (!RegExp(r"^[ㄱ-ㅎ|ㅏ-ㅣ|가-힣A-Za-z0-9+]{1,10}$")
                            .hasMatch(value)) {
                          return 'Must be between 1 and 10 characters';
                        }
                        return null;
                      },
                      onSaved: (value) => _memberNickName = value,
                    ),
                  ) : Text(Owner().nickName),
                  subtitle: editNickName == 'editing' ? null : Text('닉네임'),
                  trailing: buildEditButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
