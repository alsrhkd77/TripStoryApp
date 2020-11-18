import 'package:trip_story/common/address_book.dart';

class Friend{
  String name = '';
  String nickName = '';
  String profile = AddressBook.defaultProfileUrl;
  int follower = 0;
  int following = 0;
  bool followed = false;

  Friend();

  Friend.init(this.name, this.nickName, this.profile);

  Friend fromJson(value){
    this.name = value['name'];
    this.nickName = value['nickName'];
    this.profile = value['profileImagePath'];
    this.follower = value['followers'];
    this.following = value['followings'];
    this.followed = value['followed'];
    return this;
  }
}