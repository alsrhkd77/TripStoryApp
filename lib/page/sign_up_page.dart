import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/page/login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final signUpFormKey = new GlobalKey<FormState>();
  final idFormKey = new GlobalKey<FormState>();
  final nicknameFormKey = new GlobalKey<FormState>();
  bool idCheck = false;
  bool nickNameCheck = false;
  String _memberId;
  String _memberNickName;
  String _memberPw;
  String _memberName;
  String _memberEmail;

  ///ID 중복확인
  Future<void> requestCheckId() async {
    final idForm = idFormKey.currentState;
    if (idForm.validate()) {
      idForm.save();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                //this right here
                title: Text('잠시만 기다려주세요...'),
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

      http.Response response = await http.post(AddressBook.idCheck,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'memberId': _memberId}));
      var resData = jsonDecode(response.body);

      Navigator.pop(context);
      if (resData['result'] == "success") {
        setState(() {
          idCheck = true;
        });
        _showDialog('ID 중복확인', '사용가능한 ID입니다.');
      } else if (resData['result'] == "duplicate") {
        _showDialog('ID 중복확인', '중복된 ID입니다.');
      } else {
        _showDialog('ID 중복확인', resData['errors']);
      }
    } else {
      print("id form update err");
    }
  }

  ///닉네임 중복 확인
  Future<void> requestCheckNickName() async {
    final nickNameForm = nicknameFormKey.currentState;
    if (nickNameForm.validate()) {
      nickNameForm.save();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                //this right here
                title: Text('잠시만 기다려주세요...'),
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

      http.Response response = await http.post(AddressBook.nickNameCheck,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'memberNickName': _memberNickName}));
      var resData = jsonDecode(response.body);

      Navigator.pop(context);
      if (resData['result'] == "success") {
        setState(() {
          nickNameCheck = true;
        });
        _showDialog('닉네임 중복확인', '사용가능한 닉네임 입니다.');
      } else if (resData['result'] == "duplicate") {
        _showDialog('닉네임 중복확인', '중복된 닉네임 입니다.');
      } else {
        _showDialog('닉네임 중복확인', resData['errors']);
      }
    } else {
      print("nickname form update err");
    }
  }

  ///회원가입
  Future<void> registration() async {
    final form = signUpFormKey.currentState;

    if (!idCheck) {
      _showDialog('회원가입', '회원가입에 실패하였습니다.\nID 중복체크를 먼저 진행하세요');
      return;
    }

    if (!nickNameCheck) {
      _showDialog('회원가입', '회원가입에 실패하였습니다.\n닉네임 중복체크를 먼저 진행하세요');
      return;
    }

    if (form.validate()) {
      form.save();

      http.Response response = await http.post(AddressBook.registration,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'memberId': _memberId,
            'memberPw': _memberPw,
            'memberNickName': _memberNickName,
            'memberName': _memberName,
            'memberEmail': _memberEmail
          }));

      var resData = jsonDecode(response.body);

      Navigator.pop(context);
      if (resData['result'] == "success") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              title: new Text('회원가입'),
              content: new Text('회원가입이 완료되었습니다.'),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("확인"),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage()));
                  },
                ),
              ],
            );
          },
        );
      } else {
        _showDialog('회원가입', '회원가입에 실패하였습니다.\n${resData['errors']}');
      }
    } else {
      print("form update err");
    }
  }

  void _showDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
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
        title: Text('회원가입'),
      ),
      body: Form(
        key: signUpFormKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 32.0,
              ),
              Image.asset(
                'images/logo.png',
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2,
              ),
              SizedBox(
                height: 22.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Form(
                    key: idFormKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 3 / 5,
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            idCheck = false;
                          });
                        },
                        maxLength: 12,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ID',
                            hintText: '6~12 Alphabet and Numbers.'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'ID can\'t be empty!';
                          } else if (!RegExp(r"^[A-Za-z0-9+]{6,12}$")
                              .hasMatch(value)) {
                            return 'Use only Alphabet and Numbers.';
                          }
                          return null;
                        },
                        onSaved: (value) => _memberId = value,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 22.0,
                  ),
                  OutlineButton(
                    child: Text('중복확인'),
                    onPressed: requestCheckId,
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Form(
                    key: nicknameFormKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 3 / 5,
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            nickNameCheck = false;
                          });
                        },
                        maxLength: 10,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nick Name',
                            hintText: 'Use only Alphabet, Numbers, 한글.'),
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
                    ),
                  ),
                  SizedBox(
                    width: 22.0,
                  ),
                  OutlineButton(
                    child: Text('중복확인'),
                    onPressed: requestCheckNickName,
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 7 / 8,
                child: TextFormField(
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: true,
                  maxLength: 18,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'PW'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password can\'t be empty!';
                    } else if (!RegExp(r"^[A-Za-z0-9+]{6,18}$")
                        .hasMatch(value)) {
                      return 'Please combination of Alphabet and Numbers.';
                    }
                    return null;
                  },
                  onSaved: (value) => _memberPw = value,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 7 / 8,
                child: TextFormField(
                  maxLength: 40,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Name'),
                  validator: (value) =>
                      value.isEmpty ? 'Name can\'t be empty!' : null,
                  onSaved: (value) => _memberName = value,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 7 / 8,
                child: TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Email'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Email can\'t be empty';
                    } else if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Please write in the correct email format.';
                    }
                    return null;
                  },
                  onSaved: (value) => _memberEmail = value,
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 7 / 8,
                child: OutlineButton(
                  child: Text('회 원 가 입'),
                  onPressed: registration,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
