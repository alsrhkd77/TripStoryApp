import 'package:trip_story/utils/address_book.dart';

/// 로그인한 유저 정보 + 설정
class User{
  /*User information*/
  String type; //google, facebook, us
  String name;
  String id;
  String email;
  String profile = AddressBook.defaultProfileUrl;

  static final User _user = User.internal();

  factory User(){
    return _user;
  }
  
  void ClearLogout(){
    this.id='';
    this.type = '';
    this.name = '이름 없음';
    this.email = '';
    this.profile = AddressBook.defaultProfileUrl;
  }

  User.internal(){
    name = "이름 없음";
  }
}