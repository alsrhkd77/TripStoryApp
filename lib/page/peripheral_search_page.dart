import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/models/trip.dart';
import 'package:trip_story/page/view_trip_page.dart';
import 'package:trip_story/provider/trip_provider.dart';

class PeripheralSearchPage extends StatefulWidget {
  @override
  _PeripheralSearchPageState createState() => _PeripheralSearchPageState();
}

class _PeripheralSearchPageState extends State<PeripheralSearchPage> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _position =
      new CameraPosition(target: LatLng(37.575929, 126.976849), zoom: 11.5);
  Set<Marker> _markers = new Set();
  Map<LatLng, Set> _feedList = new Map();

  @override
  void initState() {
    super.initState();
    getPeripheralFeed();
  }

  Future<String> getPlaceName(LatLng point) async {
    final response = await http.get(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${point.latitude},${point.longitude}&key=${AddressBook.googleMapsKey}&result_type=political|sublocality|sublocality_level_1&language=ko');
    String result;
    if (response.statusCode == 200) {
      var resData = jsonDecode(response.body);
      result = resData['results'][0]['formatted_address'];
    } else {
      result = '${point.latitude},${point.longitude}';
    }
    return result;
  }

  Future<void> getPeripheralFeed() async {
    http.Response _response = await http.get(AddressBook.searchPeripheralFeed +
        '${_position.target.latitude}/${_position.target.longitude}/0.3');
    if (_response.statusCode == 200) {
      var resData = jsonDecode(_response.body);
      if (resData['result'] == 'success') {
        for (var data in resData['travels']) {
          Marker temp = makeMarker(LatLng(data['lat'], data['lng']));
          setState(() {
            if (!_feedList.containsKey(LatLng(data['lat'], data['lng']))) {
              _feedList[LatLng(data['lat'], data['lng'])] = new Set();
            }
            _feedList[LatLng(data['lat'], data['lng'])].add(data['postId']);
            _markers.add(temp);
          });
        }
      } else if (resData['errors'] != null) {
        throw Exception(
            'Failed to search peripheral feed value\n${resData['errors']}');
      } else {
        throw Exception('Failed to search peripheral feed value');
      }
    } else {
      throw Exception('Failed to connect server');
    }
  }

  Future<List<Trip>> getTripList(LatLng point) async {
    List<Trip> _list = new List();
    TripProvider tripProvider = new TripProvider();
    for (var id in _feedList[point]) {
      Trip temp = await tripProvider.fetchTripView(id);
      _list.add(temp);
    }
    return _list;
  }

  Marker makeMarker(LatLng point) {
    return Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        onTap: () {
          String _place;
          List<Trip> _tripList;
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
                  if (_tripList == null) {
                    getTripList(point).then((value) {
                      setState(() {
                        _tripList = value;
                      });
                    });
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.0),
                          height: (MediaQuery.of(context).size.height / 2) / 6,
                          child: Text(
                            _place == null ? '위치 정보 없음' : _place,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          height:
                              (MediaQuery.of(context).size.height / 2) * 5 / 6,
                          child: _tripList != null
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _tripList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return feedTemplate(_tripList[index]);
                                  },
                                )
                              : Center(
                                  child: LoadingBouncingGrid.square(
                                    backgroundColor: Colors.blueAccent,
                                    size: 50.0,
                                  ),
                                ),
                        )
                      ],
                    ),
                  );
                });
              });
        });
  }

  Widget feedTemplate(Trip _trip) {
    return Container(
      width: (MediaQuery.of(context).size.height / 2) * 4 / 6,
      margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 15.0),
      child: InkWell(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: EdgeInsets.all(8.0),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 3.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                width: (MediaQuery.of(context).size.height / 2) * 4 / 6,
                height: (MediaQuery.of(context).size.height / 4) * 5 / 6,
                color: Colors.black,
                child: Stack(
                  children: [
                    Image.network(
                      _trip.imageList[0],
                      fit: BoxFit.cover,
                    ),

                    ///좋아요, 댓글, 작성일자
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 8.0),
                        width: MediaQuery.of(context).size.width,
                        color: Color.fromRGBO(0, 0, 0, 150),
                        child: Row(
                          children: [
                            _trip.liked
                                ? Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    color: Colors.white38,
                                  ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              _trip.likes.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white38,
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Icon(
                              Icons.mode_comment_outlined,
                              color: Colors.white38,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              _trip.comments.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 본문
              _trip.content != ''
                  ? Container(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: Text(
                        _trip.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),

              ///태그
              Container(
                padding: EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: buildTagChip(_trip.tagList).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ViewTripPage(
                        feedId: _trip.id,
                        type: 'trip',
                      )));
        },
      ),
    );
  }

  List<Widget> buildTagChip(List tagList) {
    List<Widget> _tags = new List();
    for (String i in tagList) {
      Container _chip = new Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Chip(
          elevation: 5.0,
          shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
          backgroundColor: Colors.transparent,
          label: Text(
            '# ' + i,
            style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
        ),
      );
      _tags.add(_chip);
    }
    return _tags;
  }

  static final _gwanghwamun =
      CameraPosition(target: LatLng(37.575929, 126.976849), zoom: 11.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GoogleMap(
          mapType: MapType.normal,
          markers: _markers,
          initialCameraPosition: _gwanghwamun,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapToolbarEnabled: false,
          onCameraMove: (position) => _position = position,
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(15.0),
        child: FloatingActionButton.extended(
          heroTag: 'search peripheral',
          elevation: 8.0,
          backgroundColor: Colors.black.withOpacity(0.4),
          icon: Icon(Icons.search),
          label: Text('현재 위치에서 검색'),
          onPressed: () async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      //this right here
                      title: Text('주변 게시물 검색 중'),
                      content: Container(
                        padding: EdgeInsets.all(15.0),
                        child: LoadingBouncingGrid.square(
                          backgroundColor: Colors.blueAccent,
                          size: 90.0,
                        ),
                      ),
                    ),
                  );
                });
            await getPeripheralFeed();
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }
}
