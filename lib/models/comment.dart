class Comment{
  int id;
  String author;
  String profile;
  String content ='';
  DateTime writeDate;

  Comment fromJson(var value){
    this.id = value['commentId'];
    this.author = value['authorProfile']['author'];
    this.profile = value['authorProfile']['profileImagePath'];
    this.content = value['content'];
    this.writeDate = DateTime.parse(value['createdTime']);
    return this;
  }
}