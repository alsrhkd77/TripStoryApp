/*
게시물 value를 가지는 클래스
 */
import 'dart:convert';

import 'package:trip_story/common/address_book.dart';

class Post {
  //TODO: 게시물 id랑 작성자 id 어케되는지 물어보고 맞추기
  int id; //게시물 id
  String author; //게시물 작성자
  int likes; //좋아요 갯수
  int comments; //댓글 갯수
  String content; //본문
  String scope = 'public'; //public=전체 공개, friend=친구공개, private=비공개
  bool liked = false;
  bool useVisit; //방문날짜 사용 여부
  DateTime startDate; //방문 시작일
  DateTime endDate; //방문 종료일
  DateTime writeDate; //게시물 작성일자
  List<String> tagList; //태그
  List<String> imageList;

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

  Post fromJSON(var value){
    Map result = jsonDecode(value);
    this.id = result['id']; //게시물 id
    this.author = result['author']; //게시물 작성자
    this.likes = result['likes']; //좋아요 갯수
    this.comments = result['comments']; //댓글 갯수
    this.content = result['content']; //본문
    this.scope = result['scope']; //public=전체 공개, friend=친구공개, private=비공개
    this.liked = result['liked'];
    this.useVisit = result['useVisit']; //방문날짜 사용 여부
    this.startDate = result['startDate']; //방문 시작일
    this.endDate = result['endDate']; //방문 종료일
    this.writeDate = result['writeDate']; //게시물 작성일자
    this.tagList = result['tags']; //태그
    this.imageList = result['images'];
    return this;
  }

  makeSample(){
    content = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
    //mainText ='';
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
    tagList.add('1');
    tagList.add('2');
    tagList.add('태그별로');
    tagList.add('길이길면 어케되냐');
    tagList.add('5add');
    tagList.add('6번태그');
    tagList.add('7번태그');
    tagList.add('8번태그');
    tagList.add('9번태그');
    writeDate = DateTime.now();
  }
}
