/*
여행 게시물 value를 가지는 클래스
 */
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_story/models/post.dart';

class Trip extends Post {
  bool useMaps = true; //경로 표시용 지도 사용 여부
  Map<LatLng, List<DateTime>> points = new Map();
  List<Post> postList = new List(); //포함된 게시물 목록

  Trip() : super() {
    this.useMaps = true;
  }

  Trip.init(
      {id,
      author,
      likes,
      comments,
      content,
      scope,
      liked,
      useVisit,
      startDate,
      endDate,
      writeDate,
      tagList,
      imageList,
      this.useMaps,
      this.points,
      this.postList})
      : super.init(
            id: id,
            author: author,
            likes: likes,
            comments: comments,
            content: content,
            scope: scope,
            liked: liked,
            useVisit: useVisit,
            startDate: startDate,
            endDate: endDate,
            writeDate: writeDate,
            tagList: tagList,
            imageList: imageList);

  makeSample(){
    super.makeSample();
    for(int i = 0; i< 5; i++){
      Post t = new Post();
      t.makeSample();
      postList.add(t);
    }
  }
}
