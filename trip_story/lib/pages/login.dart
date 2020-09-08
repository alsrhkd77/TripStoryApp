import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripstory/modules/FacebookLogin.dart';
import 'package:tripstory/modules/GoogleSignIn.dart';
import 'package:tripstory/modules/UserInfo.dart';
import 'package:tripstory/modules/blank_appbar.dart';
import 'package:tripstory/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:tripstory/pages/regist.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  final facebookLogin = FacebookLogin();
  GoogleSignInAccount _googleCurrentUser;

  GoogleSignInState google = GoogleSignInState();
  String _id;
  String _password;
  String _loginURL = "https://tripstory.ga/login-social";
  String _defaultLoginURL = "https://tripstory.ga/login";
  bool boxCheck = false;

  Future<void> checkAutoLogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('auto'));
    if(prefs.getBool('auto')){
      if(prefs.getString('type') == "us"){
        UserInfo().setUserId(prefs.getString('id'));
        UserInfo().setUserName(prefs.getString('name'));
        prefs.getString('pw');
      }
      else{
        UserInfo().setUserId(prefs.getString('id'));
        UserInfo().setUserName(prefs.getString('name'));
        UserInfo().setUserEmail(prefs.getString('email'));
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void toggleBox() {
    if (boxCheck == false) {
      // Put your code here which you want to execute on CheckBox Checked event.
      setState(() {
        boxCheck = true;
      });
    } else {
      // Put your code here which you want to execute on CheckBox Un-Checked event.
      setState(() {
        boxCheck = false;
      });
    }
  }

  Future<void> signIn() async {
    final form = formKey.currentState;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (form.validate()) {
      form.save();
      //TODO: send login request
      if(boxCheck){
        prefs.setBool('auto', true);
        prefs.setString('type', "us");
        prefs.setString('id', "id");
        prefs.setString('pw', "pw");
      }
      else{
        prefs.setBool('auto', false);
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      print('failed');
    }
  }

  void signUp() {
    //TODO: go sign up page
    print('sign up');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Regist()),
    );
  }

  void findPWD() {
    //TODO: find password
    print('find password');
  }

  void signInGoogle() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _googleCurrentUser = await google.startSignIn() as GoogleSignInAccount;
    UserInfo().setLoginType("google");
    UserInfo().setUserName(_googleCurrentUser.displayName);
    UserInfo().setUserId(_googleCurrentUser.id);
    UserInfo().setUserEmail(_googleCurrentUser.email);

    Map<String, dynamic> value = {'id': UserInfo().getUserId(), 'name': UserInfo().getUserName()};

    http.Response response = await http.post(_loginURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));

    //resData = jsonDecode(response.body);

    if(response.body == "login-success"){
      //save login option
      prefs.setBool('auto', true);
      prefs.setString('type', "google");
      prefs.setString('id', UserInfo().getUserId());
      prefs.setString('name', UserInfo().getUserName());
      prefs.setString('email', UserInfo().getUserEmail());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
    else if(response.body == "login-failed"){
      prefs.setBool('auto', false);
      UserInfo().clearLogout();
    }
    else{
      prefs.setBool('auto', false);
      UserInfo().clearLogout();
    }
  }

  void logout(){
    //google.templogout();
    facebookLogin.logOut();
  }

  void signInFacebook() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FacebookLoginResult facebookLoginResult = await facebookLogin.logIn(['email']);
    var graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult
            .accessToken.token}');

    var profile = json.decode(graphResponse.body);
    UserInfo().setUserId(profile['id']);
    UserInfo().setUserName(profile['name']);
    UserInfo().setUserEmail("");
    UserInfo().setLoginType("facebook");

    Map<String, dynamic> value = {'id': UserInfo().getUserId(), 'name': UserInfo().getUserName()};

    http.Response response = await http.post(_loginURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(value));

    //resData = jsonDecode(response.body);

    if(response.body == "login-success"){
      //save login option
      prefs.setBool('auto', true);
      prefs.setString('type', "google");
      prefs.setString('id', UserInfo().getUserId());
      prefs.setString('name', UserInfo().getUserName());
      prefs.setString('email', UserInfo().getUserEmail());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
    else if(response.body == "login-failed"){
      prefs.setBool('auto', false);
      UserInfo().clearLogout();
    }
    else{
      prefs.setBool('auto', false);
      UserInfo().clearLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    checkAutoLogin(context);
    return new Scaffold(
      appBar: /*new AppBar(title: new Text('login demo'),),*/ new BlankAppbar(),
      resizeToAvoidBottomPadding: false,
      body: new Container(
        padding: EdgeInsets.all(32),
        child: new Form(
          key: formKey,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text('Sign in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30, /*fontWeight: FontWeight.bold*/
                      )),
                  new Icon(Icons.assistant_photo)
                ],
              ),
              new Padding(padding: EdgeInsets.all(10)),
              new TextFormField(
                decoration: new InputDecoration(
                    border: OutlineInputBorder(), labelText: 'ID'),
                validator: (value) =>
                value.isEmpty ? 'ID can\'t be empty' : null,
                onSaved: (value) => _id = value,
              ),
              new Padding(padding: EdgeInsets.all(10)),
              new TextFormField(
                obscureText: true,
                decoration: new InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Password'),
                validator: (value) =>
                value.isEmpty ? 'Password can\'t be empty' : null,
                onSaved: (value) => _password = value,
              ),
              new Padding(padding: EdgeInsets.all(5)),
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    child: Text(
                      'Forget Your Password?',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                    onTap: logout,
                  ),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Checkbox(
                    value: boxCheck,
                    onChanged: (value) {
                      toggleBox();
                    },
                    activeColor: Colors.pinkAccent,
                    checkColor: Colors.white,
                    tristate: false,
                  ),
                  new Text('Remember Me')
                ],
              ),
              new Padding(padding: EdgeInsets.all(20)),
              new SizedBox(
                height: 50,
                child: new RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0)),
                  color: Colors.red,
                  textColor: Colors.white,
                  child: new Text(
                    'Sign in',
                    style: new TextStyle(fontSize: 20.0),
                  ),
                  onPressed: signIn,
                ),
              ),
              new Padding(padding: EdgeInsets.all(20)),
              new Text(
                'OR',
                style:
                new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              new Padding(padding: EdgeInsets.all(20)),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new SizedBox(
                    width: 150,
                    height: 50,
                    child: new RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0)),
                      color: Colors.red,
                      textColor: Colors.white,
                      child: new Text(
                        'Google',
                        style: new TextStyle(fontSize: 20.0),
                      ),
                      onPressed: signInGoogle,
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(20)),
                  new SizedBox(
                    width: 150,
                    height: 50,
                    child: new RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0)),
                      color: Colors.indigo,
                      textColor: Colors.white,
                      child: new Text(
                        'FaceBook',
                        style: new TextStyle(fontSize: 20.0),
                      ),
                      onPressed: signInFacebook,
                    ),
                  ),
                ],
              ),
              new Padding(padding: EdgeInsets.all(20)),
              new Row(
                children: <Widget>[
                  new Text('Need an account? '),
                  InkWell(
                    child: Text(
                      'Sign up',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                    onTap: signUp,
                  ),
                ],
              ),
              new Padding(padding: EdgeInsets.all(5)),
              new Row(
                children: <Widget>[
                  new Text('Forgot your password? '),
                  InkWell(
                    child: Text(
                      'Retrive',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                    onTap: findPWD,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
