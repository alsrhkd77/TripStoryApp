
import 'address_book.dart';

/// 로그인한 유저 정보 + 설정
class Owner{
  /*User information*/
  String type; //google, facebook, us
  String name;
  String nickName;
  String id;
  String email;
  String profile = AddressBook.defaultProfileUrl;

  static final Owner _user = Owner.internal();

  factory Owner(){
    return _user;
  }

  void ClearLogout(){
    this.id='';
    this.type = '';
    this.name = '이름 없음';
    this.nickName = '???';
    this.email = '';
    this.profile = AddressBook.defaultProfileUrl;
  }

  Owner.internal(){
    name = "이름 없음";
  }
}