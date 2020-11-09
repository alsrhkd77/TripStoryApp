class Friend{
  String name;
  String nickName;
  String profile;
  int follower = 0;
  int following =0;

  Friend();

  Friend.init(this.name, this.nickName, this.profile);

  fromJson(value){
    this.name = value['name'];
    this.nickName = value['nickName'];
    this.profile = value['profilePath'];
    this.follower = value['follower'];
    this.following = value['following'];
  }
}