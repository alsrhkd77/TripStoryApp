import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trip_story/page/login_page.dart';
import 'package:trip_story/utils/address_book.dart';
import 'package:trip_story/utils/blank_appbar.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final signUpFormKey = new GlobalKey<FormState>();
  final idFormKey = new GlobalKey<FormState>();
  String _memberId;
  String _memberPw;
  String _memberName;
  String _memberEmail;

  ///ID 중복확인
  Future<void> requestCheckId() async {
    final idForm = idFormKey.currentState;
    if (idForm.validate()) {
      idForm.save();
      http.Response response = await http.post(AddressBook.idCheck,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'memberId': _memberId}));
      var resData = jsonDecode(response.body);

      if (resData['result'] == "success") {
        _showDialog('ID 중복확인', '사용가능한 ID입니다.');
      } else if(resData['result'] == "duplicated"){
        _showDialog('ID 중복확인', '중복된 ID입니다.');
      }else {
        _showDialog('ID 중복확인', resData['errors']);
      }
    } else {
      print("id form update err");
    }
  }

  ///회원가입
  Future<void> registration() async {
    final form = signUpFormKey.currentState;
    final idForm = idFormKey.currentState;
    if (form.validate() && idForm.validate()) {
      idForm.save();
      form.save();

      ///중복확인
      http.Response idResponse = await http.post(AddressBook.idCheck,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'memberId': _memberId}));
      var idRes = jsonDecode(idResponse.body);
      if (idRes['result'] == "success") {
        ///회원가입
        http.Response response = await http.post(AddressBook.registration,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'memberId': _memberId,
              'memberPw': _memberPw,
              'memberName': _memberName,
              'memberEmail': _memberEmail
            }));

        var resData = jsonDecode(response.body);

        if (resData['result'] == "success") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
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
      } else if(idRes['result'] == "duplicated"){
        _showDialog('ID 중복확인', '중복된 ID입니다.');
      }else {
        _showDialog('ID 중복확인', idRes['errors']);
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
      appBar: BlankAppbar(),
      resizeToAvoidBottomPadding: false, //키보드 올라올때 안움직이게
      body: Form(
        key: signUpFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 32.0,
            ),
            FlutterLogo(
              size: 140.0,
            ),
            SizedBox(
              height: 22.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: idFormKey,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 3 / 5,
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'ID'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'ID can\'t be empty!';
                        } else if (!RegExp(r"^[A-Za-z0-9+]{4,12}$")
                            .hasMatch(value)) {
                          return 'Please combination of Alphabet and Numbers.';
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
              height: 16.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 7 / 8,
              child: TextFormField(
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
              height: 16.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 7 / 8,
              child: TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Name'),
                validator: (value) =>
                    value.isEmpty ? 'Name can\'t be empty!' : null,
                onSaved: (value) => _memberName = value,
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 7 / 8,
              child: TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Email'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Email can\'t be empty';
                  } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
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
    );
  }
}
