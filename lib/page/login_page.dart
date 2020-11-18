import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/main.dart';
import 'package:trip_story/page/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginFormKey = new GlobalKey<FormState>();
  String _errorMsg = '';
  TextEditingController _memberIdTextController = new TextEditingController();
  TextEditingController _memberPwTextController = new TextEditingController();
  String _memberId = '';
  String _memberPw = '';
  bool _autoLoginChecked = false;
  String _globalLoginState = '-';


  @override
  void initState() {
    checkAutoLogin(context);
    super.initState();
  }

  //TODO: Delete Force login
  void forceLogin() {
    Owner user = Owner();
    user.name = '송민광';
    Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => MainStatefulWidget()),
        (route) => false);
  }

  Future<bool> getUserInfo() async {
    bool result = false;
    http.Response _response = await http.get(AddressBook.userInfo + _memberId);

    var resData = jsonDecode(_response.body);
    var state = resData['result'];
    if(state == 'success'){
      Owner().id = resData['memberInfo']['memberId'];
      Owner().name = resData['memberInfo']['memberName'];
      Owner().email = resData['memberInfo']['memberEmail'];
      Owner().profile = resData['memberInfo']['memberProfileImagePath'];
      Owner().nickName = resData['memberInfo']['memberNickName'];
      result = true;
    }
    return result;
  }

  Future<void> checkAutoLogin(BuildContext context) async {
    String state = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getKeys().isEmpty){
      return;
    }
    if (prefs.getBool('auto')) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context){
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('로그인 중입니다'),
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

      _autoLoginChecked = true;
      _memberId = prefs.getString('id');
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
          //유저 정보 세팅
          var getUser = await getUserInfo();
          if(getUser){
            Owner().type = 'us';
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => MainStatefulWidget()),
                    (route) => false);
          }
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

  Future<void> login(BuildContext context) async {
    final form = loginFormKey.currentState;
    if(form.validate()){
      form.save();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context){
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('로그인 시도'),
                content: Container(
                  padding: EdgeInsets.all(15.0),
                  child: LoadingBouncingGrid.square(
                    inverted: true,
                    backgroundColor: Colors.blueAccent,
                    size: 80.0,
                  ),
                ),
              ),
            );
          }
      );
      await loginProcess();
      Navigator.pop(context);
      if(_globalLoginState == 'success'){
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => MainStatefulWidget()),
                (route) => false);
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('로그인 실패'),
                content: _errorMsg == '' ? Text('인터넷 상태를 확인해주세요.') : Text(_errorMsg),
                actions: <Widget>[
                  FlatButton(
                    color: Colors.white,
                    textColor: Colors.lightBlue,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(8.0),
                    splashColor: Colors.blueAccent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('확인'),
                  )
                ],
              );
            });
      }
    }
  }

  Future<void> loginProcess() async {
    http.Response response = await http.post(AddressBook.login,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'memberId': _memberId, 'memberPw': _memberPw}));
    var resData = jsonDecode(response.body);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (resData['result'] == "success") {
      var getUser = await getUserInfo();
      if(!getUser){
        return;
      }
      if (_autoLoginChecked) {
        Owner().type = 'us';
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
      setState(() {
        _globalLoginState = 'success';
      });
      print('login success');
    } else {
      _errorMsg = resData['errors'];
      prefs.setBool('auto', false);
      prefs.setString('type', '');
      prefs.setString('id', '');
      prefs.setString('pw', '');
      print('login failed');
    }
  }

  Future<void> login_backup(BuildContext context) async {
    final form = loginFormKey.currentState;
    if (form.validate()) {
      form.save();
      String loginState = '-';
      String state = '';

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
          //사용자 정보 저장
          var getUser = await getUserInfo();
          if(getUser){
            Owner().type = 'us';
            prefs.setBool('auto', true);
            prefs.setString('type', 'us');
            prefs.setString('id', _memberId);
            prefs.setString('pw', _memberPw);
          }
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
              content: loginState == 'success'
                  ? (state == 'success'
                      ? Text('로그인 되었습니다.')
                      : LoadingBouncingGrid.square(
                          backgroundColor: Colors.blueAccent,
                          size: 80.0,
                        ))
                  : Text(resData['errors']),
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
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
                Image.asset('images/logo.png', width: MediaQuery.of(context).size.width / 2, height: MediaQuery.of(context).size.width / 2,),
                SizedBox(
                  height: 22.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextFormField(
                    initialValue: _memberId,
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
                    enableSuggestions: false,
                    autocorrect: false,
                    obscureText: true,
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
                      onPressed: () => login(context),
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
                          "https://facebookbrand.com/wp-content/uploads/2019/04/f_logo_RGB-Hex-Blue_512.png?w=512&h=512",
                          width: 21.0,
                          height: 21.0,
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
