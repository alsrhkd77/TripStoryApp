import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/blocs/view_feed_bloc.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/blank_appbar.dart';
import 'package:trip_story/common/owner.dart';
import 'package:trip_story/common/paged_image_view.dart';
import 'package:trip_story/common/view_appbar.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/models/trip.dart';
import 'package:trip_story/page/network_image_view_page.dart';
import 'package:trip_story/page/view_post_page.dart';

// ignore: must_be_immutable
class ViewTripPage extends ViewPostPage {
  Completer<GoogleMapController> _controller = Completer();

  final feedId;

  ViewTripPage({Key key, this.feedId, type})
      : super(key: key, feedId: feedId, type: type);

  static final _gwanghwamun = CameraPosition(
      target: LatLng(37.575929, 126.976849), zoom: 11.151926040649414);

  Future<void> _goToTarget(LatLng pos) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition targetPosition = CameraPosition(target: pos, zoom: 11.5);
    controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  }

  Future<String> getPlaceName(LatLng point) async {
    final response = await http.get(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${point.latitude},${point.longitude}&key=${AddressBook.googleMapsKey}&result_type=political|sublocality|sublocality_level_1&language=ko');
    String result;
    if (response.statusCode == 200) {
      var resData = jsonDecode(response.body);
      result = resData['results'][0]['formatted_address'];
    } else {
      result = '${point.latitude}, ${point.longitude}';
    }
    return result;
  }

  //마커 생성
  Set<Marker> addMarkers(context, Map<LatLng, List<DateTime>> points) {
    Set<Marker> _markers = Set();
    for (LatLng point in points.keys) {
      Marker newMarker = new Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        //marker option
        onTap: () {
          String _place;
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  if (_place == null)
                    getPlaceName(point).then((value) {
                      setState(() {
                        _place = value;
                      });
                    });
                  return Container(
                    height: MediaQuery.of(context).copyWith().size.height / 2,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.0),
                          height:
                              (MediaQuery.of(context).copyWith().size.height /
                                      2) /
                                  6,
                          child: Text(
                            _place == null ? '위치 정보 없음' : _place,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(12.0),
                          height:
                              (MediaQuery.of(context).copyWith().size.height /
                                      2) *
                                  5 /
                                  6,
                          child: ListView.builder(
                            itemCount: points[point].length,
                            itemBuilder: (BuildContext context, int index) {
                              return Text(DateFormat('yyyy. MM. dd HH:mm')
                                      .format(points[point][index]) +
                                  ' 에 방문했습니다.');
                            },
                          ),
                        )
                      ],
                    ),
                  );
                });
              });
        },
      );
      _markers.add(newMarker);
      _goToTarget(point);
    }
    return _markers;
  }

  ///경로
  Set<Polyline> updatePolyline(Trip data) {
    if (data.points.length < 2) {
      return null;
    }
    Set<Polyline> _polylines = Set();
    List<DateTime> date = [];
    List<LatLng> list = [];
    for (List<DateTime> d in data.points.values) {
      date = date + d;
    }
    date.sort();
    for (DateTime t in date) {
      for (LatLng key in data.points.keys) {
        if (data.points[key].contains(t)) {
          list.add(key);
        }
      }
    }
    Polyline polyline = new Polyline(
        polylineId: PolylineId("route"),
        visible: true,
        color: Colors.blue,
        width: 4,
        points: list);
    _polylines.add(polyline);
    return _polylines;
  }

  @override
  Widget buildCommentIcon(context, data) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.mode_comment_outlined),
          onPressed: () => buildCommentView(context),
        ),
        Text(
          data.comments.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void buildCommentView(context) {
    TextEditingController _commentTextController = new TextEditingController();

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 2,
            child: Column(
              children: [
                ///댓글 작성
                Container(
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                  height:
                      (MediaQuery.of(context).copyWith().size.height / 2) / 6,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: MediaQuery.of(context).size.width / 25,
                      backgroundColor: Colors.blueAccent,
                      child: CircleAvatar(
                        radius: (MediaQuery.of(context).size.width / 25) - 1,
                        backgroundImage: NetworkImage(Owner().profile),
                      ),
                    ),
                    title: TextFormField(
                      controller: _commentTextController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Add comment...',
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.send),
                      color: Colors.blueAccent,
                      onPressed: () {
                        commentBloc.addComment(_commentTextController.text);
                        _commentTextController.text = '';
                        feedBloc.addComment();
                        FocusManager.instance.primaryFocus.unfocus(); //키보드 닫기
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0.0),
                  height: (MediaQuery.of(context).copyWith().size.height / 2) *
                      5 /
                      6,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 12.0,
                        ),
                        buildComment(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget buildPostView() {
    return StreamBuilder(
        stream: feedBloc.feedStream,
        builder: (context, snapshot) {
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.postList.length,
              itemBuilder: (context, index) {
                return postCard(context, snapshot.data.postList[index], index);
              });
        });
  }

  Widget postCard(context, Post _post, index) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 4 / 5,
          height: MediaQuery.of(context).size.width * 4 / 5,
          child: InkWell(
            child: Card(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 2.0,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  PagedImageView(
                    list: _post.imageList,
                    fit: BoxFit.cover,
                    zoomAble: false,
                  ),
                  Positioned(
                    child: Container(
                      color: Color.fromRGBO(0, 0, 0, 80),
                      width: MediaQuery.of(context).size.width * 4 / 5,
                      child: ListTile(
                        title: Row(
                          children: [
                            IconButton(
                              icon: _post.liked
                                  ? Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    )
                                  : Icon(
                                      Icons.favorite_border,
                                      color: Colors.white54,
                                    ),
                              onPressed: () => feedBloc
                                  .tapPostLike(index), //TODO: tap post like
                            ),
                            Text(
                              _post.likes.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                            SizedBox(
                              width: 25.0,
                            ),
                            Icon(
                              Icons.mode_comment_outlined,
                              color: Colors.white54,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              _post.comments.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottom: 0,
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ViewPostPage(
                            feedId: _post.id,
                            type: 'post',
                          )));
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlankAppbar(),
      body: StreamBuilder(
        stream: feedBloc.feedStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ///앱바(작성자, 방문일자, 메뉴)
                      buildAppBar(context, snapshot.data),

                      ///이미지
                      buildImageList(snapshot.data, context),

                      ///좋아요, 댓글, 작성일자
                      ListTile(
                        title: Row(
                          children: [
                            buildLikeIcon(snapshot.data),
                            SizedBox(
                              width: 25.0,
                            ),
                            buildCommentIcon(context, snapshot.data),
                          ],
                        ),
                        trailing: Text(
                          DateFormat('yy. MM. dd HH:mm')
                              .format(snapshot.data.writeDate),
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                              fontSize: 12.0),
                        ),
                      ),

                      Divider(
                        color: Colors.black38,
                      ),

                      /// 본문
                      buildContent(snapshot.data),

                      ///여행 경로
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 2 / 3,
                        child: Stack(
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: _gwanghwamun,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                              zoomControlsEnabled: false,
                              zoomGesturesEnabled: true,
                              buildingsEnabled: true,
                              scrollGesturesEnabled: true,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                              mapToolbarEnabled: false,
                              markers:
                                  addMarkers(context, snapshot.data.points),
                              polylines: updatePolyline(snapshot.data),
                              gestureRecognizers:
                                  <Factory<OneSequenceGestureRecognizer>>[
                                new Factory<OneSequenceGestureRecognizer>(
                                  () => new EagerGestureRecognizer(),
                                ),
                              ].toSet(),
                            ),
                          ],
                        ),
                      ),

                      ///태그
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 10.0,
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children:
                              buildTagChip(context, snapshot.data).toList(),
                        ),
                      ),
                      Divider(),

                      buildPostView(),
                    ],
                  ),
                )
              : Center(
                  child: LoadingBouncingGrid.square(
                    inverted: true,
                    backgroundColor: Colors.blueAccent,
                    size: 150.0,
                  ),
                );
        },
      ),
    );
  }
}
