import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trip_story/utils/address_book.dart';
import 'package:trip_story/utils/blank_appbar.dart';
import 'package:trip_story/utils/image_data.dart';
import 'package:http/http.dart' as http;

class MakeTripPage extends StatefulWidget {
  @override
  _MakeTripPageState createState() => _MakeTripPageState();
}

class _MakeTripPageState extends State<MakeTripPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  int scope = 0; //0=전체 공개, 1=친구공개, 2=비공개
  Set<Marker> _markers = Set();
  Set<Polyline> _polylines = Set();
  Map points = new Map<LatLng, List<DateTime>>();
  List selectedValues = new List();
  List<Widget> selectedValueList = new List();
  List<String> tagList = [];
  DateTime startDate;
  DateTime endDate;

  /*flags*/
  bool addingMarker = false; //마커 추가하는 중
  bool _useDate = false; //방문 날짜
  bool _useMaps = true; //여행 경로
  bool _openMarkerOption = false; //자동 마커 설정
  bool _autoLocalImgMarker = true; //사진 자동 마커
  bool _autoPostImgMarker = true; //게시물 내 사진 자동 마커

  static final _gwanghwamun = CameraPosition(
      target: LatLng(37.575929, 126.976849), zoom: 19.151926040649414);

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
      addingMarker = true;
    });
    final snackbar = SnackBar(
      content: Text('지도에 새 위치 추가'),
      action: SnackBarAction(
        label: '취소',
        onPressed: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
          setState(() {
            addingMarker = false;
          });
        },
      ),
      duration: Duration(days: 1),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void addMarker(LatLng point, DateTime visit) {
    if (points.containsKey(point)) {
      setState(() {
        points[point].add(visit);
      });
    } else {
      Marker newMarker = Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          onTap: () {
            //TODO: Marker option
            String _place;
            setState(() {
              addingMarker = false;
              _scaffoldKey.currentState.hideCurrentSnackBar();
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
                          Container(
                            height:
                                MediaQuery.of(context).copyWith().size.height /
                                    6,
                            child: ListView.builder(
                              padding: EdgeInsets.all(15.0),
                              itemCount: points[point].length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Wrap(
                                    children: [
                                      InkWell(
                                        child: Text(DateFormat('yyyy. MM. dd')
                                            .format(points[point][index])),
                                        onTap: () async {
                                          DateTime date = await showDatePicker(
                                              context: context,
                                              initialDate: points[point][index],
                                              firstDate: DateTime(1950),
                                              lastDate: DateTime.now());
                                          if (date != null) {
                                            setState(() {
                                              points[point][index] =
                                                  new DateTime(
                                                      date.year,
                                                      date.month,
                                                      date.day,
                                                      points[point][index].hour,
                                                      points[point][index]
                                                          .minute);
                                              updatePolyline();
                                            });
                                          }
                                        },
                                      ),
                                      Text('   '),
                                      InkWell(
                                        child: Text(DateFormat('HH:mm')
                                            .format(points[point][index])),
                                        onTap: () async {
                                          TimeOfDay time = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now());
                                          if (time != null) {
                                            setState(() {
                                              points[point][index] =
                                                  new DateTime(
                                                      points[point][index].year,
                                                      points[point][index]
                                                          .month,
                                                      points[point][index].day,
                                                      time.hour,
                                                      time.minute);
                                              updatePolyline();
                                            });
                                          }
                                        },
                                      ),
                                      Text(' 에 방문'),
                                    ],
                                  ),
                                  trailing: points[point].length > 1
                                      ? InkWell(
                                          child: Icon(Icons.delete_forever),
                                          onTap: () {
                                            setState(() {
                                              points[point].removeAt(index);
                                            });
                                            updatePolyline();
                                          },
                                        )
                                      : Text(''),
                                );
                              },
                            ),
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
                                Navigator.pop(context);
                                _scaffoldKey.currentState.setState(() {
                                  _markers.removeWhere((element) =>
                                      element.markerId ==
                                      MarkerId(point.toString()));
                                  points.remove(point);
                                });
                                updatePolyline();
                              },
                            ),
                          ),
                        ],
                      ));
                });
              },
            );
          });
      setState(() {
        _markers.add(newMarker);
        points[point] = new List<DateTime>();
        points[point].add(visit);
        addingMarker = false;
        _scaffoldKey.currentState.hideCurrentSnackBar();
      });
    }
    if (points.values.length >= 2) {
      updatePolyline();
    }
    _goToTarget(point);
  }

  void addNewTag() {
    TextEditingController textEditingController = new TextEditingController();
    showDialog(
        context: context,
        child: AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  autofocus: true,
                  maxLength: 15,
                  decoration:
                      InputDecoration(labelText: '새 태그', hintText: '새 태그'),
                ),
              )
            ],
          ),
          actions: [
            FlatButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('추가'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  tagList.add(textEditingController.text);
                });
              },
            )
          ],
        ));
  }

  Future<void> addImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    Map<String, double> _imgLocation =
        await ImageData.getLocalImageLocation(image.path);
    DateTime _imgDate = await ImageData.getLocalImageDateTime(image.path);
    int _index = selectedValues.length;

    Container _widget = new Container(
      height: MediaQuery.of(context).size.width * 2 / 6,
      width: MediaQuery.of(context).size.width * 3 / 6,
      padding: EdgeInsets.all(10.0),
      child: InkWell(
        onLongPress: () {
          setState(() {
            selectedValueList.removeAt(_index);
            selectedValues.removeAt(_index);
          });
        },
        child: Card(
            color: Colors.black,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Image.file(
              File(image.path),
              fit: BoxFit.contain,
            )),
      ),
    );
    if (_imgLocation['none'] == 0.0 &&
        _imgDate.compareTo(DateTime.now()) < 0 &&
        _autoLocalImgMarker) {
      addMarker(LatLng(_imgLocation['lat'], _imgLocation['lng']), _imgDate);
    }
    setState(() {
      selectedValues.add(image.path);
      selectedValueList.add(_widget);
    });
  }

  void addPost() {
    //TODO: 게시물 선택 화면
    int _index = selectedValues.length;

    Container _widget = new Container(
      height: MediaQuery.of(context).size.width * 2 / 6,
      width: MediaQuery.of(context).size.width * 3 / 6,
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onLongPress: () {
          setState(() {
            selectedValueList.removeAt(_index);
            selectedValues.removeAt(_index);
          });
        },
        child: Card(
          elevation: 4.0,
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: [
              Center(
                child: Image.network(
                  AddressBook.getSampleImg(),
                  fit: BoxFit.contain,
                ),
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.width * 2 / 6,
                  width: MediaQuery.of(context).size.width * 3 / 6,
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
              Positioned(
                child: Container(
                  child: Text(
                    '여기가 본문',
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
    setState(() {
      selectedValues.add('게시물id');
      selectedValueList.add(_widget);
    });
  }

  void updatePolyline() {
    List<DateTime> date = [];
    List<LatLng> list = [];
    for (List<DateTime> d in points.values) {
      date = date + d;
    }
    date.sort();
    for (DateTime t in date) {
      for (LatLng key in points.keys) {
        if (points[key].contains(t)) {
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
    setState(() {
      _polylines = new Set();
      _polylines.add(polyline);
    });
  }

  void autoDate() {
    List<DateTime> _imgDate = [];
    for (var dt in points.values) {
      _imgDate.addAll(dt);
    }
    if (_imgDate.isEmpty) {
      return;
    } else {
      _imgDate.sort();
      if (_imgDate[0].compareTo(DateTime.now()) < 0) {
        setState(() {
          startDate = _imgDate[0];
        });
        for (DateTime d in _imgDate.reversed) {
          if (d.compareTo(DateTime.now()) < 0) {
            setState(() {
              endDate = d;
            });
            break;
          }
        }
      }
    }
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

  Widget makeTagList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tagList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == tagList.length) {
          return new IconButton(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              icon: Icon(
                Icons.add,
                color: Colors.blue,
              ),
              onPressed: addNewTag);
        } else {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Chip(
              backgroundColor: Colors.lightBlueAccent,
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  tagList.removeAt(index);
                });
              },
              label: Text('#' + tagList[index]),
            ),
          );
        }
      },
    );
  }

  Future<void> _goToTarget(LatLng pos) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition targetPosition = CameraPosition(target: pos, zoom: 14.5);
    controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
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
            SizedBox(
              height: 12.0,
            ),

            ///공개범위 설정
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  child: ListTile(
                    title: Text(
                      '공개 범위',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    trailing: Wrap(
                      children: [
                        Text(
                          scope == 0
                              ? '전체 공개  '
                              : (scope == 1 ? '친구 공개  ' : '비 공개  '),
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black45),
                        ),
                        Icon(scope == 0
                            ? Icons.public
                            : (scope == 1 ? Icons.group : Icons.lock)),
                      ],
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                        ),
                        context: context,
                        builder: (context) {
                          return Container(
                            height: MediaQuery.of(context).size.height / 3,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    '공개 범위 설정',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                InkWell(
                                  child: ListTile(
                                    title: Wrap(
                                      spacing: 8.0,
                                      children: [
                                        Icon(Icons.public),
                                        Text('전체 공개'),
                                      ],
                                    ),
                                    trailing: scope == 0
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                        : SizedBox(),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      scope = 0;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                InkWell(
                                  child: ListTile(
                                    title: Wrap(
                                      spacing: 8.0,
                                      children: [
                                        Icon(Icons.group),
                                        Text('친구 공개'),
                                      ],
                                    ),
                                    trailing: scope == 1
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                        : SizedBox(),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      scope = 1;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                InkWell(
                                  child: ListTile(
                                    title: Wrap(
                                      spacing: 8.0,
                                      children: [
                                        Icon(Icons.lock),
                                        Text('비공개'),
                                      ],
                                    ),
                                    trailing: scope == 2
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                        : SizedBox(),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      scope = 2;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  },
                )),

            ///방문 날짜
            MergeSemantics(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    '방문 날짜',
                    style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: _useDate,
                    onChanged: (bool value) {
                      setState(() {
                        _useDate = value;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _useDate = !_useDate;
                    });
                  },
                ),
              ),
            ),
            AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              height: !_useDate ? 0.0 : 40.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              child: MergeSemantics(
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  title: Wrap(
                    children: [
                      InkWell(
                        child: Text(startDate == null
                            ? DateFormat("yyyy. MM. dd").format(DateTime.now())
                            : DateFormat("yyyy. MM. dd").format(startDate)),
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: MediaQuery.of(context)
                                      .copyWith()
                                      .size
                                      .height /
                                      3,
                                  child: CupertinoDatePicker(
                                    initialDateTime: startDate == null
                                        ? DateTime.now()
                                        : startDate,
                                    onDateTimeChanged: (DateTime picked) {
                                      setState(() {
                                        startDate = picked;
                                      });
                                    },
                                    maximumDate: DateTime.now(),
                                    minimumYear: 1950,
                                    mode: CupertinoDatePickerMode.date,
                                  ),
                                );
                              });
                        },
                      ),
                      Text('  ~  '),
                      InkWell(
                        child: Text(endDate == null
                            ? DateFormat("yyyy. MM. dd").format(DateTime.now())
                            : DateFormat("yyyy. MM. dd").format(endDate)),
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: MediaQuery.of(context)
                                      .copyWith()
                                      .size
                                      .height /
                                      3,
                                  child: CupertinoDatePicker(
                                    initialDateTime: endDate == null
                                        ? DateTime.now()
                                        : endDate,
                                    onDateTimeChanged: (DateTime picked) {
                                      setState(() {
                                        endDate = picked;
                                      });
                                    },
                                    maximumDate: DateTime.now(),
                                    minimumYear: 1950,
                                    mode: CupertinoDatePickerMode.date,
                                  ),
                                );
                              });
                        },
                      )
                    ],
                  ),
                  trailing: InkWell(
                    child: Text(
                      'Auto',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: autoDate,
                  ),
                ),
              ),
            ),

            /// 여행 경로
            MergeSemantics(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: Text(
                    '여행 경로',
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: _useMaps,
                    onChanged: (bool value) {
                      setState(() {
                        _useMaps = value;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _useMaps = !_useMaps;
                    });
                  },
                ),
              ),
            ),
            !_useMaps
                ? SizedBox(
                    height: 0.0,
                  )
                : Container(
                    height: MediaQuery.of(context).copyWith().size.height / 3,
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: Card(
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
                            markers: _markers,
                            polylines: _polylines,
                            onTap: (LatLng point) async {
                              //add custom marker
                              if (addingMarker) {
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
                          ),
                          addingMarker
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
            !_useMaps
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
            !_useMaps
                ? SizedBox(
                    height: 0.0,
                  )
                : AnimatedContainer(
                    height: !_openMarkerOption
                        ? 0.0
                        : 130.0,
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

            /// 태그
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Text(
                '# 태그',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width / 10,
              child: makeTagList(),
            ),

            SizedBox(
              height: 12.0,
            ),

            /// 내용 작성란
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
              child: TextField(
                maxLines: 5,
                maxLength: 25,
                maxLengthEnforced: true,
                decoration: InputDecoration(
                    hintText: '여행의 느낌을 알려주세요!', border: OutlineInputBorder()),
              ),
            ),

            /// 선택된 게시물, 사진
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedValueList,
              ),
            ),

            /*
            Wrap(
              children: selectedValueList,
            ),
             */

            /// 작성완료 버튼
            SizedBox(
              width: MediaQuery.of(context).size.width * 4 / 5,
              child: RaisedButton(
                color: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Text(
                  '작성 완료',
                ),
                onPressed: () {},
              ),
            ),

            SizedBox(
              height: 12.0,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: MediaQuery.of(context).size.width / 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                child: RaisedButton(
                  color: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Icon(Icons.add_photo_alternate_outlined),
                  onPressed: () {
                    /// 사진 추가
                    addImage();
                  },
                ),
              ),
              InkWell(
                child: RaisedButton(
                  color: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Icon(Icons.post_add),
                  onPressed: addPost,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
