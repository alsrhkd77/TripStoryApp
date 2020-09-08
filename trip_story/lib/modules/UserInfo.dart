import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripstory/modules/GoogleSignIn.dart';

class UserInfo {
  String _type; //google, facebook, us
  String _name;
  String _id;
  String _email;
  String _profile;

  static final UserInfo _userInfo = UserInfo._internal();

  factory UserInfo() {
    return _userInfo;
  }

  UserInfo._internal() {
    _name = "이름 없음";
  }

  void setLoginType(String type){
    this._type = type;
  }

  void setUserName(String name) {
    this._name = name;
  }

  void setUserId(String id) {
    this._id = id;
  }

  void setUserEmail(String email) {
    this._email = email;
  }

  void setUserProfile(String profile){
    this._profile = profile;
  }

  String getLoginType(){
    return this._type;
  }

  String getUserEmail() {
    return this._email;
  }

  String getUserId() {
    return this._id;
  }

  String getUserName() {
    return this._name;
  }

  String getUserProfile(){
    return this._profile;
  }

  void clearExit(){
    /*
    final facebookLogin = FacebookLogin();
    GoogleSignInState google = GoogleSignInState();

    facebookLogin.logOut();
    google.templogout();
    exit(0);
     */
  }

  Future<void> clearLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auto', false);
    /*
    final facebookLogin = FacebookLogin();
    GoogleSignInState google = GoogleSignInState();

    facebookLogin.logOut();
    google.templogout();
     */
  }
}
