/*
게시물 value를 가지는 클래스
 */
import 'package:trip_story/main.dart';

import 'address_book.dart';

class Post {
  //TODO: 게시물 id랑 작성자 id 어케되는지 물어보고 맞추기
  int id; //게시물 id
  int author; //게시물 작성자
  int likes;  //좋아요 갯수
  int comments; //댓글 갯수
  String contents;  //본문
  bool liked = false;
  bool useVisit;  //방문날짜 사용 여부
  DateTime startDate; //방문 시작일
  DateTime endDate; //방문 종료일
  DateTime writeDate; //게시물 작성일자
  List<String> tagList = new List();
  List<String> imageList = new List(); //게시물 이미지 url 목록

  Post(){
    //TODO: testData 지우기
    contents = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
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
