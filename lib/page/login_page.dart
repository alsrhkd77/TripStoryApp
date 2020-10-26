import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_story/main.dart';
import 'package:trip_story/page/sign_up_page.dart';
import 'package:trip_story/utils/address_book.dart';
import 'package:trip_story/utils/blank_appbar.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/utils/user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginFormKey = new GlobalKey<FormState>();
  String _memberId;
  String _memberPw;
  bool _autoLoginChecked = false;

  void forceLogin() {
    User user = User();
    user.name = '송민광';
    Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => MainStatefulWidget()),
        (route) => false);
  }

  Future<void> checkAutoLogin(BuildContext context) async {
    String state = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('auto'));
    if (prefs.getBool('auto')) {
      if (prefs.getString('type') == "us") {
        http.Response response = await http.post(AddressBook.login,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'memberId': prefs.getString('id'),
              'memberPw': prefs.getString('pw')
            }));

        var resData = jsonDecode(response.body);
        state = resData['result'];

        if (state == 'success') {
          //TODO: 유저 정보 세팅
          Navigator.pushAndRemoveUntil(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => MainStatefulWidget()),
              (route) => false);
        } else {
          prefs.setBool('auto', false);
          prefs.setString('type', '');
          prefs.setString('id', '');
          prefs.setString('pw', '');
        }
      } else {
        //TODO: 다른 로그인 방식
      }
    }
  }

  Future<void> login() async {
    final form = loginFormKey.currentState;
    if (form.validate()) {
      form.save();
      String loginState = '-';
      String state = '';

      //TODO: 사용자 정보 저장하기
      http.Response response = await http.post(AddressBook.login,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'memberId': _memberId, 'memberPw': _memberPw}));
      var resData = jsonDecode(response.body);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      state = resData['result'];

      if (state == "success") {
        if (_autoLoginChecked) {
          prefs.setBool('auto', true);
          prefs.setString('type', 'us');
          prefs.setString('id', _memberId);
          prefs.setString('pw', _memberPw);
        } else {
          prefs.setBool('auto', false);
          prefs.setString('type', '');
          prefs.setString('id', '');
          prefs.setString('pw', '');
        }
        //TODO: 나머지 값들 저장해주기
        setState(() {
          loginState = 'success';
        });
        print('login success');
        print(resData);
      } else {
        prefs.setBool('auto', false);
        prefs.setString('type', '');
        prefs.setString('id', '');
        prefs.setString('pw', '');
        print('login failed');
      }

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: loginState == 'success' ? Text('로그인 성공') : Text('로그인 실패'),
              content: loginState == '-'
                  ? LoadingBouncingGrid.square(
                      backgroundColor: Colors.blueAccent,
                      size: 80.0,
                    )
                  : (loginState == 'success'
                      ? Text('로그인 되었습니다.')
                      : Text(resData['errors'])),
              actions: <Widget>[
                FlatButton(
                  color: Colors.white,
                  textColor: Colors.lightBlue,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    if (loginState == 'success') {
                      Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  MainStatefulWidget()),
                          (route) => false);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: loginState == '-' ? Text('취소') : Text('확인'),
                )
              ],
            );
          });
    }
  }

  void registration() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlankAppbar(),
      resizeToAvoidBottomPadding: false, //키보드 올라올때 안움직이게
      body: Form(
          key: loginFormKey,
          child: SingleChildScrollView(
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'ID'),
                    validator: (value) =>
                        value.isEmpty ? 'ID can\'t be empty' : null,
                    onSaved: (value) => _memberId = value,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'PW'),
                    validator: (value) =>
                        value.isEmpty ? 'PW can\'t be empty' : null,
                    onSaved: (value) => _memberPw = value,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _autoLoginChecked,
                        onChanged: (bool value) {
                          setState(() {
                            _autoLoginChecked = value;
                          });
                        },
                      ),
                      Text('자동 로그인'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlineButton(child: Text('회원가입'), onPressed: registration),
                    OutlineButton(
                      child: Text('로그인'),
                      onPressed: forceLogin, //TODO: Change to login
                    )
                  ],
                ),
                SizedBox(
                  height: 32.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.blue),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://storage.googleapis.com/gweb-uniblog-publish-prod/images/Search_GSA.max-2800x2800.png",
                          width: 22.0,
                          height: 22.0,
                        ),
                        Text('   Sign in with Google')
                      ],
                    ),
                    onPressed: () {
                      //TODO: google login
                    },
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.blue),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://scontent-gmp1-1.xx.fbcdn.net/v/t1.0-9/119568341_200337161527884_7846459746434232698_n.png?_nc_cat=1&_nc_sid=85a577&_nc_ohc=UI9fwKptC54AX90BHW0&_nc_ht=scontent-gmp1-1.xx&oh=12db9af00bc94abb0096a534611a2a00&oe=5F9E1CE0",
                          width: 22.0,
                          height: 22.0,
                        ),
                        Text('   Sign in with Facebook')
                      ],
                    ),
                    onPressed: () {
                      //TODO: facebook login
                    },
                  ),
                )
              ],
            ),
          )),
    );
  }
}
