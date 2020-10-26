/*
여행 게시물 value를 가지는 클래스
 */
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_story/utils/address_book.dart';
import 'package:trip_story/utils/post.dart';

class Trip extends Post{
  bool useMaps; //경로 표시용 지도 사용 여부
  Map<LatLng, List<DateTime>> points = new Map();
  List<Post> postList = new List();  //포함된 게시물 목록

  Trip(){
    postList.add(new Post());
    postList.add(new Post());
    postList.add(new Post());
    postList.add(new Post());
    postList.add(new Post());
    postList.add(new Post());
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
    imageList.add(AddressBook.getSampleImg());
  }
}