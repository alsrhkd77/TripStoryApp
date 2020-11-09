import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:http/http.dart' as http;
import 'package:trip_story/blocs/edit_trip_bloc.dart';
import 'package:trip_story/common/address_book.dart';
import 'package:trip_story/common/custom_image.dart';
import 'package:trip_story/common/image_data.dart';
import 'package:trip_story/main.dart';
import 'package:trip_story/models/post.dart';
import 'package:trip_story/page/edit_feed_template.dart';

class EditTripPage extends StatefulWidget {
  @override
  _EditTripPageState createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set();
  final EditTripBloc _bloc = new EditTripBloc();
  final EditFeedTemplate _template = new EditFeedTemplate();

  /*flags*/
  bool _openMarkerOption = false; //자동 마커 설정
  bool _autoLocalImgMarker = true; //사진 자동 마커
  bool _autoPostImgMarker = true; //게시물 내 사진 자동 마커
  bool _addingMarker = false;

  static final _gwanghwamun = CameraPosition(
      target: LatLng(37.575929, 126.976849), zoom: 19.151926040649414);

  Widget buildMap() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return Column(
          children: [
            MergeSemantics(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    '여행 경로',
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: snapshot.data.useMaps,
                    onChanged: (bool value) => _bloc.setUseMaps(value),
                  ),
                  onTap: _bloc.switchingUseMaps,
                ),
              ),
            ),
            !snapshot.data.useMaps
                ? SizedBox(
                    height: 0.0,
                  )
                : Container(
                    height: MediaQuery.of(context).copyWith().size.height / 3,
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: Card(
                      child: Stack(
                        children: [
                          StreamBuilder(
                            stream: _bloc.polylineStream,
                            builder: (context, polylineSnapshot) {
                              return GoogleMap(
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
                                markers: _markers,
                                polylines: polylineSnapshot.data,
                                onTap: (LatLng point) async {
                                  //add custom marker
                                  if (_addingMarker) {
                                    var visit;
                                    visit = await pickDateTime();
                                    if (visit != null) {
                                      addMarker(point, visit);
                                    }
                                  }
                                },
                                gestureRecognizers:
                                    <Factory<OneSequenceGestureRecognizer>>[
                                  new Factory<OneSequenceGestureRecognizer>(
                                    () => new EagerGestureRecognizer(),
                                  ),
                                ].toSet(),
                              );
                            },
                          ),
                          _addingMarker
                              ? SizedBox(
                                  width: 0.0,
                                  height: 0.0,
                                )
                              : Positioned(
                                  child: RawMaterialButton(
                                    elevation: 2.0,
                                    fillColor: Colors.lightBlueAccent,
                                    child: Icon(
                                      Icons.add_location_outlined,
                                      size: 15.0,
                                    ),
                                    shape: CircleBorder(),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onPressed: startAddUserCustomMarker,
                                  ),
                                  bottom: 20.0,
                                  right: 0.0,
                                )
                        ],
                      ),
                    ),
                  ),
            // 마커 설정
            !snapshot.data.useMaps
                ? SizedBox(
                    height: 0.0,
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      title: Text(
                        '자동 마커 설정',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      trailing: InkWell(
                        child: _openMarkerOption
                            ? Icon(Icons.arrow_drop_up)
                            : Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () {
                        setState(() {
                          _openMarkerOption = !_openMarkerOption;
                        });
                      },
                    ),
                  ),
            !snapshot.data.useMaps
                ? SizedBox(
                    height: 0.0,
                  )
                : AnimatedContainer(
                    height: !_openMarkerOption ? 0.0 : 130.0,
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    child: Column(
                      children: [
                        MergeSemantics(
                          child: ListTile(
                            title: Text(
                              '사진 위치 자동 추가',
                              style: TextStyle(fontSize: 13.0),
                            ),
                            trailing: Switch(
                              value: _autoLocalImgMarker,
                              onChanged: (bool value) {
                                setState(() {
                                  _autoLocalImgMarker = value;
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                _autoLocalImgMarker = !_autoLocalImgMarker;
                              });
                            },
                          ),
                        ),
                        MergeSemantics(
                          child: ListTile(
                            title: Text(
                              '게시물 내 사진 위치 자동 추가',
                              style: TextStyle(fontSize: 13.0),
                            ),
                            trailing: Switch(
                              value: _autoPostImgMarker,
                              onChanged: (bool value) {
                                setState(() {
                                  _autoPostImgMarker = value;
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                _autoPostImgMarker = !_autoPostImgMarker;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        );
      },
    );
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

  void startAddUserCustomMarker() {
    setState(() {
      _addingMarker = true;
    });
    final snackbar = SnackBar(
      content: Text('지도에 새 위치 추가'),
      action: SnackBarAction(
        label: '취소',
        onPressed: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
          setState(() {
            _addingMarker = false;
          });
        },
      ),
      duration: Duration(days: 1),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void addMarker(LatLng point, DateTime visit) {
    if (_bloc.addPoint(point, visit)) {
      Marker newMarker = Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          onTap: () {
            //TODO: Marker option
            String _place;
            setState(() {
              _scaffoldKey.currentState.hideCurrentSnackBar();
              _addingMarker = false;
            });
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
                      height: MediaQuery.of(context).copyWith().size.height / 3,
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 35.0,
                            child: Text(
                              _place == null ? '위치 정보 없음' : _place,
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          //SizedBox(height: 15.0,),
                          StreamBuilder(
                            builder: (context, snapshot) {
                              return Container(
                                height: MediaQuery.of(context)
                                        .copyWith()
                                        .size
                                        .height /
                                    6,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(15.0),
                                  itemCount: snapshot.data.points[point].length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      title: Wrap(
                                        children: [
                                          InkWell(
                                            child: Text(
                                                DateFormat('yyyy. MM. dd')
                                                    .format(snapshot.data
                                                        .points[point][index])),
                                            onTap: () async {
                                              DateTime date =
                                                  await showDatePicker(
                                                      context: context,
                                                      initialDate: snapshot.data
                                                          .points[point][index],
                                                      firstDate: DateTime(1950),
                                                      lastDate: DateTime.now());
                                              if (date != null) {
                                                DateTime _visit = new DateTime(
                                                    date.year,
                                                    date.month,
                                                    date.day,
                                                    snapshot
                                                        .data
                                                        .points[point][index]
                                                        .hour,
                                                    snapshot
                                                        .data
                                                        .points[point][index]
                                                        .minute);
                                                _bloc.updatePointVisit(
                                                    point, index, visit);
                                              }
                                            },
                                          ),
                                          Text('   '),
                                          InkWell(
                                            child: Text(DateFormat('HH:mm')
                                                .format(snapshot.data
                                                    .points[point][index])),
                                            onTap: () async {
                                              TimeOfDay time =
                                                  await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.now());
                                              if (time != null) {
                                                DateTime visit = new DateTime(
                                                    snapshot
                                                        .data
                                                        .points[point][index]
                                                        .year,
                                                    snapshot
                                                        .data
                                                        .points[point][index]
                                                        .month,
                                                    snapshot
                                                        .data
                                                        .points[point][index]
                                                        .day,
                                                    time.hour,
                                                    time.minute);
                                              }
                                            },
                                          ),
                                          Text(' 에 방문'),
                                        ],
                                      ),
                                      trailing: snapshot
                                                  .data.points[point].length >
                                              1
                                          ? InkWell(
                                              child: Icon(Icons.delete_forever),
                                              onTap: () {
                                                _bloc.removePointVisit(
                                                    point, index);
                                              },
                                            )
                                          : Text(''),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          //SizedBox(height: 15.0,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 2 / 3,
                            child: RaisedButton(
                              color: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Text(
                                '삭     제',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                _bloc.removePoint(point);
                                Navigator.pop(context);
                                _scaffoldKey.currentState.setState(() {
                                  _markers.removeWhere((element) =>
                                      element.markerId ==
                                      MarkerId(point.toString()));
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          });
      _markers.add(newMarker);
    }
    setState(() {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _addingMarker = false;
    });
    //_bloc.updatePolyline();
    _goToTarget(point);
  }

  Widget buildImageList() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Text(
            '여행 사진',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.width / 2,
          width: MediaQuery.of(context).size.width,
          child: makeImageList(),
        ),
      ],
    );
  }

  Widget makeImageList() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.imageList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == snapshot.data.imageList.length) {
              return Container(
                width: MediaQuery.of(context).size.width / 2,
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.blueAccent),
                  borderRadius: BorderRadius.all(Radius.circular(25.0))
                ),
                child: IconButton(
                  //padding: EdgeInsets.symmetric(horizontal: 25.0),
                  icon: Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    await addImage();
                  },
                ),
              );
            } else {
              return Container(
                width: MediaQuery.of(context).size.width / 2,
                margin: EdgeInsets.all(5.0),
                child: InkWell(
                  onLongPress: () => _bloc.removeImage(index),
                  child: Card(
                      color: Colors.black,
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Image.file(File(snapshot.data.imageList[index]),),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget buildPostList() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Text(
            '게시물',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.width / 2,
          width: MediaQuery.of(context).size.width,
          child: makePostList(),
        ),
      ],
    );
  }

  Widget makePostList() {
    return StreamBuilder(
      stream: _bloc.feedStream,
      builder: (context, snapshot) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.postList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == snapshot.data.postList.length) {
              return Container(
                width: MediaQuery.of(context).size.width / 2,
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.blueAccent),
                    borderRadius: BorderRadius.all(Radius.circular(25.0))
                ),
                child: IconButton(
                  //padding: EdgeInsets.symmetric(horizontal: 25.0),
                  icon: Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    await addPost();
                  },
                ),
              );
            } else {
              return Container(
                width: MediaQuery.of(context).size.width / 2,
                margin: EdgeInsets.all(5.0),
                child: InkWell(
                  onLongPress: () => _bloc.removePost(index),
                  child: Card(
                    color: Colors.black,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      children: [
                        Center(
                          child: CustomImage(snapshot.data.postList[index].imageList[0]).image,
                        ),
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.width / 2,
                            width: MediaQuery.of(context).size.width / 2,
                            color: Colors.black.withOpacity(0.65),
                          ),
                        ),
                        Positioned(
                          child: Container(
                            child: Text(
                              snapshot.data.postList[index].content,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          left: 15,
                          right: 15,
                          top: MediaQuery.of(context).size.width * 2 / 12,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> addImage() async {
    setState(() {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _addingMarker = false;
    });
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    Map<String, double> _imgLocation =
        await ImageData.getImageLocation(image.path);
    DateTime _imgDate = await ImageData.getImageDateTime(image.path);

    _bloc.addImage(image.path, _imgDate);

    if (_imgLocation['none'] == 0.0 &&
        _imgDate.compareTo(DateTime.now()) < 0 &&
        _autoLocalImgMarker) {
      addMarker(LatLng(_imgLocation['lat'], _imgLocation['lng']), _imgDate);
    }
  }

  void addPost() {
    setState(() {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _addingMarker = false;
    });
    //TODO: 게시물 선택 화면
    Post _post = new Post();
    _post.makeSample();
    _bloc.addPost(_post);
  }

  Future<DateTime> pickDateTime() async {
    DateTime selected = DateTime.now();
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('방문 일시'),
              content: Wrap(
                children: [
                  Text('경로 설정을 위해\n방문 일시를 선택해주세요.'),
                  SizedBox(
                    height: 5.0,
                  ),
                  ListTile(
                    leading: Text('방문일:'),
                    title: Text(DateFormat('yyyy. MM. dd').format(selected)),
                    trailing: InkWell(
                      child: Icon(Icons.calendar_today_rounded),
                      onTap: () async {
                        DateTime date = await showDatePicker(
                            context: context,
                            initialDate: selected,
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now());
                        if (date != null) {
                          setState(() {
                            {
                              selected = new DateTime(date.year, date.month,
                                  date.day, selected.hour, selected.minute);
                            }
                          });
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Text('방문 시각:'),
                    title: Text(DateFormat('HH:mm').format(selected)),
                    trailing: InkWell(
                      child: Icon(Icons.access_time),
                      onTap: () async {
                        TimeOfDay time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setState(() {
                            {
                              selected = new DateTime(
                                  selected.year,
                                  selected.month,
                                  selected.day,
                                  time.hour,
                                  time.minute);
                            }
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
              actions: [
                FlatButton(
                  color: Colors.white,
                  textColor: Colors.lightBlue,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    Navigator.pop(context);
                    selected = null;
                  },
                  child: Text('취소'),
                ),
                FlatButton(
                  color: Colors.white,
                  textColor: Colors.lightBlue,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('완료'),
                ),
              ],
            );
          });
        });
    return selected;
  }

  Future<void> _goToTarget(LatLng pos) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition targetPosition = CameraPosition(target: pos, zoom: 14.5);
    controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  }

  Future<void> _submit() async {
    if (_bloc.uploadAble()) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('이미지가 1개 이상 필요합니다.'),
      ));
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text('업로드 중입니다'),
              content: Container(
                padding: EdgeInsets.all(15.0),
                child: LoadingBouncingGrid.square(
                  inverted: true,
                  backgroundColor: Colors.blueAccent,
                  size: 90.0,
                ),
              ),
            ),
          );
        });

    await _bloc.submit();
    Navigator.pop(context);
    if (_bloc.uploadState == 'success') {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => MainStatefulWidget()),
          (route) => false);
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('업로드에 실패하였습니다.\n다시 시도해주세요.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('여행 작성'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _template.buildScope(_bloc), //공개 범위 설정
            //buildScope(),
            _template.buildDateTime(_bloc), //방문 시간 설정
            //buildDateTime(),
            buildMap(),
            buildImageList(),
            SizedBox(height: 15.0),
            buildPostList(),
            SizedBox(height: 12.0),
            _template.buildTagView(
              //태그 리스트
              context: context,
              bloc: _bloc,
            ),
            //buildTagView(),
            SizedBox(height: 12.0),
            _template.buildContent(_bloc), //본문 내용
            //buildContent(),
            _template.buildSubmit(
              //작성 완료 버튼
              context: context,
              onPressed: _submit,
            ),
            //buildSubmit(),
            SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}
