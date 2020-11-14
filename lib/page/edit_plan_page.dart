import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reorderables/reorderables.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class EditPlanPage extends StatefulWidget {
  @override
  _EditPlanPageState createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  final Completer<GoogleMapController> _controller = Completer();
  List<DateTime> itinerary = new List();
  Set<Marker> _markers = Set();
  List placeList = [
    ['불국사', '석굴암', '경주월드', '보문단지', '펜션'],
    ['펜션', '기차역', '대릉원']
  ];


  @override
  void initState() {
    itinerary.add(DateTime.now());
  }

  static final _gwanghwamun = CameraPosition(
      target: LatLng(37.575929, 126.976849), zoom: 19.151926040649414);

  List<Widget> buildPlaceList(int i) {
    List result = new List<Widget>();
    for (int index = 0; index < placeList[i].length; index++) {
      Card temp = new Card(
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),

        child: ListTile(
          leading: Text('#${index + 1}'),
          title: Text(placeList[i][index]),
          trailing: IconButton(
            icon: Icon(Icons.remove, color: Colors.red,),
            onPressed: (){},
          ),
        ),
      );
      result.add(temp);
    }
    return result;
  }

  void _onReorder(int index, int oldIndex, int newIndex) {
    setState(() {
      final String item = placeList[index].removeAt(oldIndex);
      placeList[index].insert(newIndex, item);
    });
  }

  Widget buildPlaces() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: placeList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'day${index + 1}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 9 / 10,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 2.0,
                child: Column(
                  children: [
                    ReorderableWrap(
                        padding: EdgeInsets.all(8.0),
                        children: buildPlaceList(index),
                        onReorder: (oldIndex, newIndex) =>
                            _onReorder(index, oldIndex, newIndex)),
                    Container(
                      width: MediaQuery.of(context).size.width * 3 / 4,
                      margin: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 1.0, color: Colors.blueAccent),
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0))),
                      child: IconButton(
                        //padding: EdgeInsets.symmetric(horizontal: 25.0),
                        icon: Icon(
                          Icons.add,
                          color: Colors.blue,
                        ),
                        onPressed: () async {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.0,)
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 일정'),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.centerLeft,
              child: Text(
                '경주 여행!!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              alignment: Alignment.centerLeft,
              child: InkWell(
                child: Text(DateFormat('yyyy. MM. dd').format(itinerary.first) + ' ~ ' + DateFormat('yyyy. MM. dd').format(itinerary.last)),
                onTap: () async {
                  final List<DateTime> picked = await DateRagePicker.showDatePicker(
                      context: context,
                      initialFirstDate: new DateTime.now(),
                      initialLastDate: new DateTime.now(),
                      firstDate: new DateTime(1945),
                      lastDate: new DateTime.now().add(Duration(days: 1825))
                  );
                  if (picked != null && picked.length == 2) {
                    setState(() {
                      itinerary = picked;
                      itinerary.sort();
                    });
                  }
                },
              ),
            ),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Card(
                child: GoogleMap(
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
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(
                      () => new EagerGestureRecognizer(),
                    ),
                  ].toSet(),
                ),
              ),
            ),
            buildPlaces(),
          ],
        ),
      ),
    );
  }
}
