/*
게시물 value를 가지는 클래스
 */
class Post {
  //TODO: 게시물 id랑 작성자 id 어케되는지 물어보고 맞추기
  int id; //게시물 id
  String author; //게시물 작성자
  String profile;
  int likes; //좋아요 갯수
  int comments; //댓글 갯수
  String content; //본문
  String scope = 'public'; //public=전체 공개, friend=친구공개, private=비공개
  bool liked = false;
  bool useVisit; //방문날짜 사용 여부
  DateTime startDate; //방문 시작일
  DateTime endDate; //방문 종료일
  DateTime writeDate; //게시물 작성일자
  List tagList; //태그
  List imageList;

  Post() {
    //TODO: 작성자 초기화
    this.content = '';
    this.scope = 'public';
    this.useVisit = true;
    this.startDate = DateTime.now();
    this.endDate = DateTime.now();
    tagList = new List();
    imageList = new List();
  }

  Post.init(
      {this.id,
      this.author,
      this.likes,
      this.comments,
      this.content,
      this.scope,
      this.liked,
      this.useVisit,
      this.startDate,
      this.endDate,
      this.writeDate,
      this.tagList,
      this.imageList});

  Post fromJson(var value) {
    Map result;
    if (value.containsKey('postDetail')) {
      result = value['postDetail'];
    } else {
      result = value;
    }
    this.id = result['postId']; //게시물 id
    this.author = result['author']; //게시물 작성자
    this.likes = result['likes']; //좋아요 갯수
    this.comments = result['comments']; //댓글 갯수
    this.content = result['content']; //본문
    this.scope = result['scope']; //public=전체 공개, friend=친구공개, private=비공개
    this.liked = result['liked'];
    this.writeDate = DateTime.parse(result['createdTime']); //게시물 작성일자
    this.tagList = result['tags']; //태그
    this.imageList = result['imagePaths'];

    //방문날짜
    if (value.containsKey('normalPostInfo')) {
      this.startDate =
          DateTime.parse(value['normalPostInfo']['visitStart']); //방문 시작일
      this.endDate =
          DateTime.parse(value['normalPostInfo']['visitEnd']); //방문 종료일

      if (this.startDate == null || this.endDate == null) {
        this.useVisit = false;
      } else {
        this.useVisit = true;
      }
    } else if (value.containsKey('startDate') && value.containsKey('endDate')) {
      this.startDate = DateTime.parse(value['startDate']); //방문 시작일
      this.endDate = DateTime.parse(value['endDate']); //방문 종료일
      if (this.startDate == null || this.endDate == null) {
        this.useVisit = false;
      } else {
        this.useVisit = true;
      }
    }

    return this;
  }
}
