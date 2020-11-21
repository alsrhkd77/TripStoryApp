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

  @override
  Trip fromJson(var value) {
    super.fromJson(value);
    Map result = value['travelPostInfo'];

    //마커 좌표
    for (var point in result['courses']) {
      LatLng latLng = new LatLng(point['lat'], point['lng']);
      if (!points.containsKey(latLng)) {
        points[latLng] = new List<DateTime>();
      }
      points[latLng].add(DateTime.parse(point['passDate']));
    }

    for (var posts in result['posts']) {
      Post temp = new Post();
      temp.id = posts['postId'];
      temp.comments = posts['comments'];
      temp.liked = posts['liked'];
      temp.likes = posts['likes'];
      temp.imageList.add(posts['thumbnailImagePath']);
      this.postList.add(temp);
    }

    //방문날짜
    this.startDate = DateTime.parse(result['travelStart']); //방문 시작일
    this.endDate = DateTime.parse(result['travelEnd']); //방문 종료일

    if (this.startDate == null || this.endDate == null) {
      this.useVisit = false;
    } else {
      this.useVisit = true;
    }

    return this;
  }
}
